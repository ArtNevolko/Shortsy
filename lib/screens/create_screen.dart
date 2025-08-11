import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import '../shared/widgets/index.dart';
import 'upload_clip_screen.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  bool _permChecked = false;
  bool _hasPerm = false;
  bool _camInitializing = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsOnce();
  }

  Future<void> _initCamera() async {
    if (_controller?.value.isInitialized == true) return;
    if (mounted) setState(() => _camInitializing = true);
    // Проверяем статус без запроса
    final has = await PermissionService().hasCameraAndMic();
    if (!has) {
      if (mounted)
        setState(() {
          _hasPerm = false;
          _camInitializing = false;
        });
      return;
    }
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) setState(() => _camInitializing = false);
        return;
      }
      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.medium,
        enableAudio: true,
      );
      await _controller!.initialize();
    } finally {
      if (mounted) setState(() => _camInitializing = false);
    }
  }

  Future<void> _checkPermissionsOnce() async {
    final service = PermissionService();
    final ok = await service.requestIfNeededOnce();
    if (!mounted) return;
    setState(() {
      _hasPerm = ok;
      _permChecked = true;
      _camInitializing = ok; // сразу показываем индикатор, пока инициализируем
    });
    if (ok) {
      await _initCamera();
    }
  }

  Future<void> _requestAgain() async {
    final ok = await PermissionService().requestCameraAndMic();
    if (!mounted) return;
    setState(() => _hasPerm = ok);
    if (ok) {
      await _initCamera();
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
        AppButton.primary(
          label: 'Проверить снова',
          icon: Icons.refresh_rounded,
          onPressed: _requestAgain,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isRecording) {
      final file = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Видео сохранено: ${file.path}')));
    } else {
      await _controller!.prepareForVideoRecording();
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    final current = _controller?.description;
    final next = _cameras!.firstWhere((c) => c != current);
    await _controller?.dispose();
    _controller =
        CameraController(next, ResolutionPreset.medium, enableAudio: true);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              GlassHeader(
                title: 'Create',
                actions: [
                  InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const UploadClipScreen())),
                    child: const Icon(Icons.cloud_upload_rounded),
                  )
                ],
              ),
              Expanded(
                child: Stack(
                  children: [
                    if (_controller?.value.isInitialized == true)
                      CameraPreview(_controller!)
                    else if (_hasPerm && _camInitializing)
                      const Center(child: CircularProgressIndicator())
                    else if (_hasPerm)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Glass(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.videocam_rounded,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 12),
                                const Text('Камера не инициализирована'),
                                const SizedBox(height: 12),
                                AppButton.primary(
                                  label: 'Проверить снова',
                                  icon: Icons.refresh_rounded,
                                  onPressed:
                                      _camInitializing ? null : _initCamera,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox.expand(),
                    // затемнение снизу
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 220,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xAA000000), Color(0x00000000)],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 120,
                      left: 20,
                      right: 20,
                      child: SafeArea(
                        top: false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FloatingActionButton(
                              heroTag: 'switch',
                              onPressed: _switchCamera,
                              child: const Icon(Icons.cameraswitch_rounded),
                            ),
                            FloatingActionButton(
                              heroTag: 'rec',
                              backgroundColor: _isRecording ? Colors.red : null,
                              onPressed: _toggleRecord,
                              child: Icon(_isRecording
                                  ? Icons.stop_rounded
                                  : Icons.circle),
                            ),
                            FloatingActionButton(
                              heroTag: 'effects',
                              onPressed: () => ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                      content: Text('Эффекты скоро!'))),
                              child: const Icon(Icons.auto_awesome_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_permChecked && !_hasPerm)
            Align(
              alignment: Alignment.center,
              child: Glass(
                borderRadius: BorderRadius.circular(24),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: _permissionCard(),
              ),
            ),
        ],
      ),
    );
  }
}
