import 'package:camera/camera.dart';

class SimpleCameraService {
  static CameraController? _controller;
  static List<CameraDescription>? _cameras;
  static int _cameraIndex = 0;

  static Future<void> _ensureCameras() async {
    _cameras ??= await availableCameras();
  }

  static CameraController? get controller => _controller;

  static Future<CameraController> createController() async {
    await _ensureCameras();
    if (_controller != null && _controller!.value.isInitialized) {
      return _controller!;
    }
    final cam = _cameras![_cameraIndex];
    _controller = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await _controller!.initialize();
    return _controller!;
  }

  static Future<void> startVideoRecording() async {
    final ctrl = await createController();
    if (!ctrl.value.isRecordingVideo) {
      await ctrl.startVideoRecording();
    }
  }

  static Future<String?> stopVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;
    if (!_controller!.value.isRecordingVideo) return null;
    final XFile file = await _controller!.stopVideoRecording();
    return file.path;
  }

  static Future<CameraController?> switchCamera() async {
    await _ensureCameras();
    if (_cameras == null || _cameras!.length < 2) return _controller;
    _cameraIndex = (_cameraIndex + 1) % _cameras!.length;
    await _controller?.dispose();
    _controller = CameraController(
      _cameras![_cameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );
    await _controller!.initialize();
    return _controller;
  }

  static Future<XFile?> takePicture() async {
    final ctrl = await createController();
    if (!ctrl.value.isInitialized) return null;
    return await ctrl.takePicture();
  }

  static Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
