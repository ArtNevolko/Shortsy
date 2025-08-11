import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';
import '../config.dart';

class LiveService {
  static final LiveService _i = LiveService._();
  LiveService._();
  factory LiveService() => _i;

  Room? _activeRoom;
  LocalVideoTrack? _activeCam;
  LocalAudioTrack? _activeMic;

  Future<({String token, String url})> _fetchToken(
      {required String identity,
      required String room,
      required bool publish}) async {
    final uri =
        Uri.parse(AppConfig.livekitTokenEndpoint).replace(queryParameters: {
      'identity': identity,
      'room': room,
      'publish': publish ? '1' : '0',
    });
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Token error: ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (
      token: data['token'] as String,
      url: (data['url'] as String?) ?? AppConfig.livekitUrl
    );
  }

  Future<Room> hostStart({required String identity}) async {
    final t = await _fetchToken(
        identity: identity, room: AppConfig.liveRoom, publish: true);
    final room =
        Room(connectOptions: const ConnectOptions(autoSubscribe: true));
    await room.connect(t.url, t.token);
    final cam = await LocalVideoTrack.createCameraTrack(
      const CameraCaptureOptions(params: VideoParametersPresets.h540_169),
    );
    final mic = await LocalAudioTrack.create(AudioCaptureOptions());
    await room.localParticipant?.publishVideoTrack(cam);
    await room.localParticipant?.publishAudioTrack(mic);
    return room;
  }

  Future<Room> viewerJoin({required String identity}) async {
    final t = await _fetchToken(
        identity: identity, room: AppConfig.liveRoom, publish: false);
    final room =
        Room(connectOptions: const ConnectOptions(autoSubscribe: true));
    await room.connect(t.url, t.token);
    return room;
  }

  Future<void> startWebRTC({required String url, required String token}) async {
    await stopWebRTC();
    final room =
        Room(connectOptions: const ConnectOptions(autoSubscribe: true));
    await room.connect(url, token);
    final cam = await LocalVideoTrack.createCameraTrack(
      const CameraCaptureOptions(params: VideoParametersPresets.h540_169),
    );
    final mic = await LocalAudioTrack.create(AudioCaptureOptions());
    await room.localParticipant?.publishVideoTrack(cam);
    await room.localParticipant?.publishAudioTrack(mic);
    _activeRoom = room;
    _activeCam = cam;
    _activeMic = mic;
  }

  Future<void> stopWebRTC() async {
    try {
      await _activeRoom?.disconnect();
    } catch (_) {}
    try {
      await _activeCam?.stop();
    } catch (_) {}
    try {
      await _activeMic?.stop();
    } catch (_) {}
    _activeRoom = null;
    _activeCam = null;
    _activeMic = null;
  }

  Future<void> startRTMP({required String rtmpUrl}) async {
    // Пока не реализовано: прямой RTMP-пуш с устройства требует нативной реализации или сторонней библиотеки
    throw Exception('RTMP push пока не реализован');
  }

  Future<void> stopRTMP() async {
    // Заглушка
  }
}
