import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../services/live_service.dart';
import '../shared/widgets/index.dart';
import '../services/permission_service.dart';
import '../shared/services/network_service.dart';

class LiveStreamSetupScreen extends StatefulWidget {
  const LiveStreamSetupScreen({super.key});

  @override
  State<LiveStreamSetupScreen> createState() => _LiveStreamSetupScreenState();
}

class _LiveStreamSetupScreenState extends State<LiveStreamSetupScreen>
    with WidgetsBindingObserver {
  final _live = LiveService();
  bool _webrtc = true;
  bool _busy = false;
  bool _running = false;

  bool _permChecked = false;
  bool _hasPerm = false;

  final _url = TextEditingController(text: 'wss://your-livekit-server');
  final _token = TextEditingController(text: 'token_here');
  final _rtmp =
      TextEditingController(text: 'rtmp://a.rtmp.youtube.com/live2/stream_key');

  @override
  void initState() {
    super.initState();
    NetworkService().start();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    NetworkService().stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPerms();
  }

  Future<void> _checkPerms() async {
    // Проверяем статус без запроса, чтобы не всплывало окно повторно
    final ok = await PermissionService().hasCameraAndMic();
    if (mounted) setState(() => _hasPerm = ok);
  }

  Future<void> _requestAgain() async {
    final ok = await PermissionService().requestCameraAndMic();
    setState(() => _hasPerm = ok);
  }

  Future<void> _start() async {
    await WakelockPlus.enable();
    final p = await NetworkService().currentProfile();
    final quality = switch (p) {
      NetworkProfile.good => '1080p',
      NetworkProfile.average => '720p',
      NetworkProfile.poor => '480p',
      NetworkProfile.offline => 'offline'
    };
    debugPrint('LIVE quality preset: ' + quality);

    setState(() => _busy = true);
    try {
      if (_webrtc) {
        await _live.startWebRTC(
            url: _url.text.trim(), token: _token.text.trim());
      } else {
        await _live.startRTMP(rtmpUrl: _rtmp.text.trim());
      }
      setState(() => _running = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Ошибка старта: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stop() async {
    setState(() => _busy = true);
    try {
      if (_webrtc) {
        await _live.stopWebRTC();
      } else {
        await _live.stopRTMP();
      }
      setState(() => _running = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Ошибка стопа: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Widget _permissionCard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.videocam, size: 32, color: Color(0xFF2BA1FF)),
        const SizedBox(height: 12),
        const Text('Нужны разрешения камеры и микрофона'),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _requestAgain,
          child: const Text('Проверить снова'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_permChecked && !_hasPerm) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const GlassHeader(title: 'Go Live'),
              const Spacer(),
              _permissionCard(),
              const Spacer(),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          children: [
            const GlassHeader(title: 'Go Live'),
            const SizedBox(height: 12),
            Glass(
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(18),
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      value: true,
                      groupValue: _webrtc,
                      onChanged: (v) => setState(() => _webrtc = v ?? true),
                      title: const Text('WebRTC (LiveKit)'),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      value: false,
                      groupValue: _webrtc,
                      onChanged: (v) => setState(() => _webrtc = v ?? false),
                      title: const Text('RTMP Push'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_webrtc) ...[
              Glass(
                borderRadius: BorderRadius.circular(18),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                        controller: _url,
                        decoration: const InputDecoration(
                            labelText: 'LiveKit URL (wss://...)')),
                    const SizedBox(height: 8),
                    TextField(
                        controller: _token,
                        decoration: const InputDecoration(labelText: 'Token'),
                        obscureText: true),
                  ],
                ),
              ),
            ] else ...[
              Glass(
                borderRadius: BorderRadius.circular(18),
                padding: const EdgeInsets.all(12),
                child: TextField(
                    controller: _rtmp,
                    decoration: const InputDecoration(labelText: 'RTMP URL')),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppButton.primary(
                    label: 'Начать эфир',
                    icon: Icons.wifi_tethering,
                    onPressed: !_running && !_busy ? _start : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton.primary(
                    label: 'Завершить',
                    icon: Icons.stop_rounded,
                    danger: true,
                    onPressed: _running && !_busy ? _stop : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_running)
              const Text(
                  'Эфир идёт... (демо). Видео/аудио публикуются в комнату или RTMP-поток.'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
