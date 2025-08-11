import 'dart:async';
import 'package:livekit_client/livekit_client.dart' as lk;

class LiveService {
  lk.Room? _room;
  lk.LocalVideoTrack? _camTrack;
  lk.LocalAudioTrack? _micTrack;

  Future<void> startWebRTC({required String url, required String token}) async {
    if (_room != null) return;
    final room =
        lk.Room(roomOptions: const lk.RoomOptions(adaptiveStream: true));
    await room.connect(url, token);
    final local = room.localParticipant;
    if (local == null) {
      await room.disconnect();
      return;
    }
    final cam = await lk.LocalVideoTrack.createCameraTrack(
      const lk.CameraCaptureOptions(),
    );
    final mic = await lk.LocalAudioTrack.create(
      const lk.AudioCaptureOptions(),
    );
    await local.publishVideoTrack(cam);
    await local.publishAudioTrack(mic);
    _room = room;
    _camTrack = cam;
    _micTrack = mic;
  }

  Future<void> stopWebRTC() async {
    try {
      await _camTrack?.stop();
      await _micTrack?.stop();
      await _room?.disconnect();
    } finally {
      _camTrack = null;
      _micTrack = null;
      _room = null;
    }
  }

  Future<void> startRTMP({required String rtmpUrl}) async {
    // RTMP push не реализован в текущей версии
    throw UnimplementedError('RTMP push not implemented');
  }

  Future<void> stopRTMP() async {
    // Заглушка
  }
}
