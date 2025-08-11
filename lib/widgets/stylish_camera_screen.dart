import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/simple_camera_service.dart';
import '../services/permission_service.dart';

class StylishCameraScreen extends StatefulWidget {
  const StylishCameraScreen({super.key});

  @override
  State<StylishCameraScreen> createState() => _StylishCameraScreenState();
}

class _StylishCameraScreenState extends State<StylishCameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final granted = await PermissionService.ensureCameraAndMic(context);
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissions not granted')),
        );
      }
      return;
    }
    final ctrl = await SimpleCameraService.createController();
    if (mounted) {
      setState(() {
        _controller = ctrl;
        _isInitialized = ctrl.value.isInitialized;
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_controller == null) return;
    if (_isRecording) {
      await SimpleCameraService.stopVideoRecording();
      if (mounted) {
        setState(() => _isRecording = false);
      }
    } else {
      await SimpleCameraService.startVideoRecording();
      if (mounted) {
        setState(() => _isRecording = true);
      }
    }
  }

  Future<void> _takePhoto() async {
    final file = await SimpleCameraService.takePicture();
    if (file != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo saved: ${file.path.split('/').last}')),
      );
    }
  }

  Future<void> _switchCamera() async {
    final newCtrl = await SimpleCameraService.switchCamera();
    if (mounted && newCtrl != null) {
      setState(() {
        _controller = newCtrl;
        _isInitialized = newCtrl.value.isInitialized;
      });
    }
  }

  @override
  void dispose() {
    SimpleCameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isInitialized && _controller != null
            ? Stack(
                children: [
                  Positioned.fill(
                    child: CameraPreview(_controller!),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: _buildBottomBar(),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 90), // выше нижнего стеклянного меню
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _roundButton(
            onTap: _switchCamera,
            icon: Icons.cameraswitch,
            tooltip: 'Switch',
          ),
          GestureDetector(
            onTap: _isRecording ? _toggleRecording : _takePhoto,
            onLongPress: _toggleRecording,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isRecording
                      ? [Colors.red.shade400, Colors.red.shade700]
                      : [Colors.white, Colors.grey.shade200],
                ),
                border: Border.all(
                  color: _isRecording ? Colors.red.shade300 : Colors.white,
                  width: 6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.red : Colors.black)
                        .withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _isRecording
                      ? Container(
                          key: const ValueKey('stop'),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 36,
                        ),
                ),
              ),
            ),
          ),
          _roundButton(
            onTap: _takePhoto,
            icon: Icons.flash_off,
            tooltip: 'Flash',
          ),
        ],
      ),
    );
  }

  Widget _roundButton({
    required VoidCallback onTap,
    required IconData icon,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
