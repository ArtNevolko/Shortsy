import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _kMuted = 'video_muted_v1';

  Future<bool> isMuted() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kMuted) ?? false;
  }

  Future<void> setMuted(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kMuted, value);
  }
}
