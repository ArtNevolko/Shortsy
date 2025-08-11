import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  static final WebRTCService _i = WebRTCService._();
  WebRTCService._();
  factory WebRTCService() => _i;

  Future<RTCPeerConnection> _createPeer() async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan',
    };
    final pc = await createPeerConnection(config);
    await pc.setConfiguration({'iceCandidatePoolSize': 0});
    return pc;
  }

  Future<({RTCPeerConnection pc, MediaStream stream, String sdp})>
      createHostOffer() async {
    final pc = await _createPeer();
    final stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});
    for (final track in stream.getTracks()) {
      await pc.addTrack(track, stream);
    }
    final offer = await pc.createOffer(
        {'offerToReceiveAudio': false, 'offerToReceiveVideo': false});
    await pc.setLocalDescription(offer);
    await _waitIceGathering(pc);
    final local = await pc.getLocalDescription();
    final sdp = jsonEncode({'sdp': local?.sdp, 'type': local?.type});
    return (pc: pc, stream: stream, sdp: sdp);
  }

  Future<void> applyViewerAnswer(
      RTCPeerConnection pc, String answerJson) async {
    final map = jsonDecode(answerJson) as Map<String, dynamic>;
    final desc =
        RTCSessionDescription(map['sdp'] as String?, map['type'] as String?);
    await pc.setRemoteDescription(desc);
  }

  Future<({RTCPeerConnection pc, MediaStream? remote, String sdp})>
      createViewerAnswer(String offerJson) async {
    final pc = await _createPeer();
    MediaStream? remote;
    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remote = event.streams.first;
      }
    };
    final map = jsonDecode(offerJson) as Map<String, dynamic>;
    await pc.setRemoteDescription(
        RTCSessionDescription(map['sdp'] as String?, map['type'] as String?));
    final answer = await pc.createAnswer(
        {'offerToReceiveAudio': true, 'offerToReceiveVideo': true});
    await pc.setLocalDescription(answer);
    await _waitIceGathering(pc);
    final local = await pc.getLocalDescription();
    final sdp = jsonEncode({'sdp': local?.sdp, 'type': local?.type});
    return (pc: pc, remote: remote, sdp: sdp);
  }

  Future<void> _waitIceGathering(RTCPeerConnection pc) async {
    if (pc.iceGatheringState ==
        RTCIceGatheringState.RTCIceGatheringStateComplete) return;
    final c = Completer<void>();
    pc.onIceGatheringState = (state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete &&
          !c.isCompleted) {
        c.complete();
      }
    };
    await c.future.timeout(const Duration(seconds: 8), onTimeout: () {});
  }

  Future<void> stop(RTCPeerConnection pc, [MediaStream? stream]) async {
    try {
      stream?.getTracks().forEach((t) async {
        try {
          await t.stop();
        } catch (_) {}
      });
      await pc.close();
    } catch (_) {}
  }
}
