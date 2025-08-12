import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../services/permission_service.dart';
import '../../services/live_service.dart';

class LiveEmbeddedController {
  Future<void> Function()? startHost;
  Future<void> Function()? stop;
  Future<void> Function()? switchCamera;
  CameraPosition? desiredCameraPosition;
  final ValueNotifier<bool> connected = ValueNotifier<bool>(false);
}

class LiveEmbedded extends StatefulWidget {
  const LiveEmbedded({super.key, required this.controller});
  final LiveEmbeddedController controller;
  @override
  State<LiveEmbedded> createState() => _LiveEmbeddedState();
}

class _LiveEmbeddedState extends State<LiveEmbedded> {
  Room? _room;
  EventsListener<RoomEvent>? _events;
  LocalVideoTrack? _localVideo;
  CameraPosition _camPos = CameraPosition.front;
  bool _busy = false;
  bool _connecting = false;

  RTCVideoRenderer? _renderer;
  MediaStream? _renderStream;

  @override
  void initState() {
    super.initState();
    _renderer = RTCVideoRenderer()..initialize();
    widget.controller
      ..startHost = _startHost
      ..stop = _stop
      ..switchCamera = _switchCamera;
  }

  @override
  void dispose() {
    widget.controller
      ..startHost = null
      ..stop = null
      ..switchCamera = null;
    _events?.dispose();
    _clearRenderer();
    _room?.disconnect();
    _renderer?.dispose();
    super.dispose();
  }

  void _clearRenderer() {
    try {
      _renderer?.srcObject = null;
      // Не останавливаем исходный video track, только освобождаем временный стрим
      _renderStream?.dispose();
    } catch (_) {}
    _renderStream = null;
  }

  Future<void> _attachRenderer() async {
    final track = _localVideo;
    if (track == null) {
      _clearRenderer();
      return;
    }
    _clearRenderer();
    try {
      final ms = await createLocalMediaStream('lk_preview');
      await ms.addTrack(track.mediaStreamTrack);
      _renderStream = ms;
      _renderer?.srcObject = ms;
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _startHost() async {
    if (_busy) return;
    _busy = true;
    if (mounted) setState(() => _connecting = true);
    try {
      final ok = await PermissionService().requestCameraAndMic();
      if (!ok) return;
      await _stop();
      final room = await LiveService()
          .hostStart(identity: 'host-${DateTime.now().millisecondsSinceEpoch}');
      _room = room;
      _bind(room);
      _camPos = widget.controller.desiredCameraPosition ?? CameraPosition.front;
      await room.localParticipant!.setCameraEnabled(
        true,
        cameraCaptureOptions: CameraCaptureOptions(
          cameraPosition: _camPos,
          params: VideoParametersPresets.h360_169,
        ),
      );
      _localVideo = _firstLocalVideo(room);
      await _attachRenderer();
      widget.controller.connected.value = _localVideo != null;
      if (mounted) setState(() {});
    } catch (_) {
    } finally {
      if (mounted) setState(() => _connecting = false);
      _busy = false;
    }
  }

  Future<void> _stop() async {
    try {
      await _room?.localParticipant?.setCameraEnabled(false);
      await _room?.disconnect();
    } catch (_) {}
    _events?.dispose();
    _events = null;
    _localVideo = null;
    _clearRenderer();
    _room = null;
    widget.controller.connected.value = false;
    if (mounted) setState(() {});
  }

  Future<void> _switchCamera() async {
    if (_busy) return;
    _busy = true;
    try {
      await _switchCameraInternal();
      _camPos = _camPos == CameraPosition.front
          ? CameraPosition.back
          : CameraPosition.front;
      if (mounted) setState(() {});
    } catch (_) {
    } finally {
      _busy = false;
    }
  }

  Future<void> _switchCameraInternal() async {
    final room = _room;
    final lp = room?.localParticipant;
    if (lp == null) return;
    final next = _camPos == CameraPosition.front
        ? CameraPosition.back
        : CameraPosition.front;
    try {
      // Попробуем нативное переключение без пересоздания трека
      if (_localVideo != null) {
        try {
          await _localVideo!.setCameraPosition(next);
          _camPos = next;
          await _attachRenderer();
          if (mounted) setState(() {});
          return;
        } catch (_) {}
      }
      // Fallback: выключаем и включаем с новой позицией камеры
      await lp.setCameraEnabled(false);
      _localVideo = null;
      _clearRenderer();
      if (mounted) setState(() {});
      await Future.delayed(const Duration(milliseconds: 800));
      await lp.setCameraEnabled(
        true,
        cameraCaptureOptions: CameraCaptureOptions(
          cameraPosition: next,
          params: VideoParametersPresets.h360_169,
        ),
      );
      _localVideo = _firstLocalVideo(room!);
      _camPos = next;
      await _attachRenderer();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  void _bind(Room room) {
    _events?.dispose();
    _events = room.createListener()
      ..on<LocalTrackPublishedEvent>((e) {
        final t = e.publication.track;
        if (t is LocalVideoTrack) {
          _localVideo = t;
          _attachRenderer();
          widget.controller.connected.value = true;
          if (mounted) setState(() {});
        }
      })
      ..on<LocalTrackUnpublishedEvent>((e) {
        if (e.publication.kind == TrackType.VIDEO) {
          _localVideo = null;
          _clearRenderer();
          widget.controller.connected.value = false;
          if (mounted) setState(() {});
        }
      });
  }

  LocalVideoTrack? _firstLocalVideo(Room room) {
    final pubs = room.localParticipant?.videoTrackPublications;
    if (pubs == null) return null;
    for (final p in pubs) {
      final t = p.track;
      if (t is LocalVideoTrack) return t;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Colors.black)),
          if (_renderer != null && _renderer!.srcObject != null)
            Positioned.fill(
              child: RTCVideoView(
                _renderer!,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                mirror: _camPos == CameraPosition.front,
              ),
            ),
          if (_connecting)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  _camPos == CameraPosition.front ? 'Фронтальная' : 'Тыльная',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
