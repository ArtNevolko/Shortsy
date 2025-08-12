import 'dart:async';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' show CameraPosition;
import '../live/live_screen.dart' show LiveEmbedded, LiveEmbeddedController;
import '../../widgets/stylish_camera_screen.dart';

enum CreateMode { video, live }

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  CreateMode _mode = CreateMode.video;
  bool _isRecording = false;
  Duration _elapsed = Duration.zero;
  Timer? _recTimer;
  final StylishCameraController _cam = StylishCameraController();
  final LiveEmbeddedController _live = LiveEmbeddedController();
  bool _onAir = false;
  CameraPosition _previewCamPos = CameraPosition.front;

  @override
  void dispose() {
    _recTimer?.cancel();
    super.dispose();
  }

  void _toggleRecord() {
    if (_isRecording) {
      _recTimer?.cancel();
      setState(() => _isRecording = false);
      return;
    }
    setState(() {
      _isRecording = true;
      _elapsed = Duration.zero;
    });
    _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackground()),
          if (_mode == CreateMode.live)
            Positioned(
              top: MediaQuery.of(context).padding.top + 48,
              left: 16,
              child: ValueListenableBuilder<bool>(
                valueListenable: _live.connected,
                builder: (_, connected, __) =>
                    _LivePreviewBadge(connected: connected),
              ),
            ),
          // Верхняя панель
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const Expanded(
                  child: Center(
                    child: Text('Создание видео',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24)),
                  child: Row(children: [
                    Icon(
                        _mode == CreateMode.video
                            ? Icons.videocam_rounded
                            : Icons.wifi_tethering,
                        color: Colors.white,
                        size: 14),
                    const SizedBox(width: 6),
                    Text(_mode == CreateMode.video ? 'Видео' : 'Стрим',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  ]),
                )
              ],
            ),
          ),
          // Live preview badge при режиме Live
          if (_mode == CreateMode.live)
            Positioned(
              top: MediaQuery.of(context).padding.top + 48,
              left: 16,
              child: ValueListenableBuilder<bool>(
                valueListenable: _live.connected,
                builder: (_, connected, __) =>
                    _LivePreviewBadge(connected: connected),
              ),
            ),
          // Нижняя панель
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomPanel(
              mode: _mode,
              isRecording: _isRecording,
              elapsed: _elapsed,
              onModeChanged: (m) => setState(() => _mode = m),
              onPrimary: () async {
                if (_mode == CreateMode.video) {
                  if (_isRecording) {
                    await _cam.stopRecording?.call();
                    _toggleRecord();
                  } else {
                    await _cam.startRecording?.call();
                    _toggleRecord();
                  }
                } else {
                  if (_onAir) {
                    await _live.stop?.call();
                    if (mounted) setState(() => _onAir = false);
                  } else {
                    // прокинем желаемую камеру
                    _live.desiredCameraPosition = _previewCamPos;
                    if (mounted) setState(() => _onAir = true);
                    // ждём, пока LiveEmbedded смонтируется и привяжет колбэки
                    await WidgetsBinding.instance.endOfFrame;
                    // небольшая пауза для корректного закрытия предыдущей Camera2-сессии
                    await Future.delayed(const Duration(milliseconds: 500));
                    await _live.startHost?.call();
                  }
                }
              },
              onSwitchCamera: () {
                if (_mode == CreateMode.live && _onAir) {
                  _live.switchCamera?.call();
                } else {
                  _cam.switchCamera?.call();
                  setState(() {
                    _previewCamPos = _previewCamPos == CameraPosition.front
                        ? CameraPosition.back
                        : CameraPosition.front;
                  });
                }
              },
              onOpenSettings: () {},
              onFilters: () {},
              onPhoto: () => _cam.takePhoto?.call(),
              onTimer: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    if (_mode == CreateMode.live && _onAir) {
      return LiveEmbedded(controller: _live);
    }
    return StylishCameraScreen(controller: _cam);
  }
}

class _BottomPanel extends StatelessWidget {
  final CreateMode mode;
  final bool isRecording;
  final Duration elapsed;
  final ValueChanged<CreateMode> onModeChanged;
  final VoidCallback onPrimary;
  final VoidCallback onSwitchCamera;
  final VoidCallback onOpenSettings;
  final VoidCallback onFilters;
  final VoidCallback onPhoto;
  final VoidCallback onTimer;
  const _BottomPanel({
    required this.mode,
    required this.isRecording,
    required this.elapsed,
    required this.onModeChanged,
    required this.onPrimary,
    required this.onSwitchCamera,
    required this.onOpenSettings,
    required this.onFilters,
    required this.onPhoto,
    required this.onTimer,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Переключатель
            Container(
              decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.all(6),
              child: Row(children: [
                _seg('Запись видео', mode == CreateMode.video,
                    () => onModeChanged(CreateMode.video)),
                const SizedBox(width: 6),
                _seg('Live Stream', mode == CreateMode.live,
                    () => onModeChanged(CreateMode.live)),
              ]),
            ),
            const SizedBox(height: 12),
            // Таймер/состояние
            if (mode == CreateMode.video && isRecording)
              Column(
                children: [
                  const SizedBox(height: 4),
                  Text(
                    _fmt(elapsed),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFeatures: [FontFeature.tabularFigures()]),
                  ),
                  const SizedBox(height: 2),
                  const Text('Запись идёт',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                ],
              ),
            // Кнопка
            SizedBox(
              width: 80,
              height: 80,
              child: ElevatedButton(
                onPressed: onPrimary,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: mode == CreateMode.video
                      ? (isRecording ? Colors.white : Colors.red)
                      : const Color(0xFF6C5CE7),
                  padding: EdgeInsets.zero,
                ),
                child: Icon(
                  mode == CreateMode.video
                      ? (isRecording ? Icons.stop : Icons.fiber_manual_record)
                      : Icons.wifi_tethering,
                  size: 30,
                  color: mode == CreateMode.video && isRecording
                      ? Colors.red
                      : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Доп. кнопки
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                _tool('Настройки', Icons.settings, onOpenSettings),
                _tool('Камера', Icons.cameraswitch, onSwitchCamera),
                _tool('Фильтры', Icons.auto_awesome, onFilters),
                _tool('Фото', Icons.photo_camera_outlined, onPhoto),
                _tool('Таймер', Icons.timer, onTimer),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Expanded _seg(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _tool(String label, IconData icon, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _LivePreviewBadge extends StatelessWidget {
  final bool connected;
  const _LivePreviewBadge({required this.connected});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 8,
            height: 8,
            child: DecoratedBox(
              decoration:
                  BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Live Preview',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          Text(connected ? 'Подключено' : 'Не подключено',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
