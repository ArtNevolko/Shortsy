import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  static const _askedOnceKey = 'permissions_asked_once_v1';

  static Future<bool> ensureCameraAndMic([dynamic _]) async {
    return await PermissionService().requestCameraAndMic();
  }

  Future<bool> hasCameraAndMic() async {
    final cam = await Permission.camera.status;
    final mic = await Permission.microphone.status;
    return cam.isGranted && mic.isGranted;
  }

  Future<bool> requestIfNeededOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final askedOnce = prefs.getBool(_askedOnceKey) ?? false;
    // Если уже проверяли один раз — не автозапрашиваем
    if (askedOnce) {
      return await hasCameraAndMic();
    }
    final result = await requestCameraAndMic();
    await prefs.setBool(_askedOnceKey, true);
    return result;
  }

  Future<bool> requestCameraAndMic() async {
    final req = await [Permission.camera, Permission.microphone].request();
    final cam = req[Permission.camera]?.isGranted ?? false;
    final mic = req[Permission.microphone]?.isGranted ?? false;
    return cam && mic;
  }
}
