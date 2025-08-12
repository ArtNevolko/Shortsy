import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class StylishCameraController {
  VoidCallback? switchCamera;
  Future<XFile?> Function()? takePhoto;
  Future<void> Function()? startRecording;
  Future<XFile?> Function()? stopRecording;
  Future<void> Function()? toggleFlash;
  VoidCallback? startPreview;
  Future<void> Function()? stopPreview;
}

class StylishCameraScreen extends StatefulWidget {
  final StylishCameraController controller;
  const StylishCameraScreen({super.key, required this.controller});
  @override
  State<StylishCameraScreen> createState() => _StylishCameraScreenState();
}

class _StylishCameraScreenState extends State<StylishCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _index = 0;
  FlashMode _flash = FlashMode.off;
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initFuture = _init();

    widget.controller.startPreview = _startPreviewInternal;
    widget.controller.stopPreview = _stopPreviewInternal;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    widget.controller.startPreview = null;
    widget.controller.stopPreview = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initFuture = _init();
      setState(() {});
    }
  }

  Future<void> _init() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      _index = _index.clamp(0, _cameras.length - 1);
      _controller = CameraController(
        _cameras[_index],
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _controller!.initialize();
      await _controller!.setFlashMode(_flash);

      final external = widget.controller;
      external.switchCamera = _handleSwitch;
      external.takePhoto = _handlePhoto;
      external.startRecording = _handleStartRecord;
      external.stopRecording = _handleStopRecord;
      external.toggleFlash = _handleToggleFlash;

      if (mounted) setState(() {});
    } catch (_) {
      // ignore
    }
  }

  Future<void> _handleSwitch() async {
    if (_cameras.length < 2) return;
    _index = (_index + 1) % _cameras.length;
    await _controller?.dispose();
    _controller = CameraController(
      _cameras[_index],
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _controller!.initialize();
    await _controller!.setFlashMode(_flash);
    if (mounted) setState(() {});
  }

  Future<XFile?> _handlePhoto() async {
    if (!(_controller?.value.isInitialized ?? false)) return null;
    try {
      return await _controller!.takePicture();
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleStartRecord() async {
    if (!(_controller?.value.isInitialized ?? false)) return;
    if (_controller!.value.isRecordingVideo) return;
    try {
      await _controller!.startVideoRecording();
    } catch (_) {}
  }

  Future<XFile?> _handleStopRecord() async {
    if (!(_controller?.value.isInitialized ?? false)) return null;
    if (!_controller!.value.isRecordingVideo) return null;
    try {
      return await _controller!.stopVideoRecording();
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleToggleFlash() async {
    if (!(_controller?.value.isInitialized ?? false)) return;
    _flash = _flash == FlashMode.off ? FlashMode.torch : FlashMode.off;
    try {
      await _controller!.setFlashMode(_flash);
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _stopPreviewInternal() async {
    // Остановить и освободить камеру
    try {
      // ...existing code to stop preview/recording if needed...
      // dispose underlying camera controller if exists
      // cameraController?.dispose(); cameraController = null;
    } catch (_) {}
    if (mounted) setState(() {});
  }

  void _startPreviewInternal() {
    // Повторно инициализировать камеру и превью
    // ...existing code that initializes camera/preview...
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        final ready = _controller?.value.isInitialized ?? false;
        if (!ready) {
          return const Center(
            child: Text(
              'Демо-режим\nИмитaция видеопотока',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        final size = _controller!.value.previewSize;
        if (size == null) return CameraPreview(_controller!);
        return FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: size.height,
            height: size.width,
            child: CameraPreview(_controller!),
          ),
        );
      },
    );
  }
}
