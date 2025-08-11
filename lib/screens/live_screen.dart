import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../shared/widgets/reactions_overlay.dart';
import '../services/live_service.dart';
import '../services/permission_service.dart';
import 'package:livekit_client/livekit_client.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});
  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final _chat = ChatService();
  final _controller = TextEditingController();
  final _reactionsKey = GlobalKey<ReactionsOverlayState>();
  bool _reactions = true;

  Room? _room;
  EventsListener<RoomEvent>? _listener;
  final Map<String, RemoteVideoTrack> _remoteVideos = {};
  bool _connecting = false;

  @override
  void dispose() {
    _controller.dispose();
    _listener?.dispose();
    _room?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _remoteVideos.isEmpty
                ? const ColoredBox(color: Colors.black)
                : Stack(
                    children: _remoteVideos.entries
                        .map((e) => Positioned.fill(
                              key: ValueKey(e.key),
                              child: VideoTrackRenderer(e.value),
                            ))
                        .toList(),
                  ),
          ),
          if (_remoteVideos.isEmpty && !_connecting && _room == null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Прямой эфир',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, children: [
                    ElevatedButton.icon(
                      onPressed: _onStartHost,
                      icon: const Icon(Icons.wifi_tethering),
                      label: const Text('Стать ведущим'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _onStartViewer,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Смотреть'),
                    ),
                  ]),
                ],
              ),
            ),
          if (_connecting)
            const Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Color(0x66000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          Positioned.fill(
              child: ReactionsOverlay(key: _reactionsKey, active: _reactions)),
          _buildChatInput(),
          _buildTopBar(),
        ],
      ),
    );
  }

  Future<void> _onStartHost() async {
    try {
      setState(() => _connecting = true);
      final ok = await PermissionService().requestCameraAndMic();
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Нет разрешений камеры/микрофона')));
        }
        return;
      }
      await _disconnect();
      final room = await LiveService()
          .hostStart(identity: 'host-${DateTime.now().millisecondsSinceEpoch}');
      _room = room;
      _bindRoom(room);
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Ошибка подключения: $e')));
      }
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _onStartViewer() async {
    try {
      setState(() => _connecting = true);
      await _disconnect();
      final room = await LiveService().viewerJoin(
          identity: 'viewer-${DateTime.now().millisecondsSinceEpoch}');
      _room = room;
      _bindRoom(room);
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Ошибка подключения: $e')));
      }
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop()),
          const Text('Live',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const Spacer(),
          TextButton(
              onPressed: _onStartHost,
              child: const Text('Стать ведущим',
                  style: TextStyle(color: Colors.white))),
          const SizedBox(width: 8),
          TextButton(
              onPressed: _onStartViewer,
              child: const Text('Смотреть',
                  style: TextStyle(color: Colors.white))),
          IconButton(
              icon: const Icon(Icons.favorite, color: Colors.white),
              onPressed: () => _reactionsKey.currentState?.add('💜')),
        ],
      ),
    );
  }

  void _bindRoom(Room room) {
    _remoteVideos.clear();
    _listener?.dispose();
    final l = room.createListener();
    _listener = l
      ..on<TrackSubscribedEvent>((e) {
        final t = e.track;
        if (t is RemoteVideoTrack) {
          setState(() => _remoteVideos[e.publication.sid] = t);
        }
      })
      ..on<TrackUnsubscribedEvent>((e) {
        setState(() => _remoteVideos.remove(e.publication.sid));
      });

    // Подхватить уже опубликованные видео
    for (final p in room.remoteParticipants.values) {
      for (final pub in p.trackPublications.values) {
        if (pub.kind == TrackType.VIDEO) {
          final t = pub.track;
          if (t is RemoteVideoTrack) {
            _remoteVideos[pub.sid] = t;
          }
        }
      }
    }
    setState(() {});
  }

  Future<void> _disconnect() async {
    try {
      await _room?.disconnect();
    } catch (_) {}
    _listener?.dispose();
    _remoteVideos.clear();
  }

  Widget _buildChatInput() {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      hintText: 'Сообщение...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none),
                  onSubmitted: _send,
                ),
              ),
            ),
            IconButton(
                icon: const Icon(Icons.emoji_emotions, color: Colors.white),
                onPressed: () => setState(() => _reactions = !_reactions)),
          ],
        ),
      ),
    );
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    _chat.send('@you', text.trim());
    _controller.clear();
  }
}
