import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter/foundation.dart';
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
    final room = Room(roomOptions: const RoomOptions());
    final resp =
        await _fetchToken(identity: identity, room: 'shortsy', publish: true);
    await room.connect(resp.url, resp.token);
    return room;
  }

  Future<Room> viewerJoin({required String identity}) async {
    final room = Room(roomOptions: const RoomOptions());
    final resp =
        await _fetchToken(identity: identity, room: 'shortsy', publish: false);
    await room.connect(resp.url, resp.token);
    return room;
  }

  Future<void> startWebRTC({required String url, required String token}) async {
    await stopWebRTC();
    debugPrint('LiveKit: Connecting as host to $url');
    final room = Room(roomOptions: const RoomOptions());
    await room.connect(url, token);
    debugPrint('LiveKit: Connected, creating camera track...');
    try {
      final cam = await LocalVideoTrack.createCameraTrack(
        const CameraCaptureOptions(params: VideoParametersPresets.h360_169),
      );
      debugPrint('LiveKit: Camera track created');
      final mic = await LocalAudioTrack.create(const AudioCaptureOptions());
      debugPrint('LiveKit: Mic track created');
      await room.localParticipant?.publishVideoTrack(cam);
      debugPrint('LiveKit: Camera published');
      await room.localParticipant?.publishAudioTrack(mic);
      debugPrint('LiveKit: Mic published');
      _activeRoom = room;
      _activeCam = cam;
      _activeMic = mic;
    } catch (e) {
      debugPrint('LiveKit: Camera/mic error: $e');
      rethrow;
    }
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
