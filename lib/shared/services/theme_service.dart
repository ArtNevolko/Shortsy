import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ThemeService _i = ThemeService._();
  ThemeService._();
  factory ThemeService() => _i;

  static const _key = 'theme_light';

  final ValueNotifier<bool> _light = ValueNotifier<bool>(false);
  ValueListenable<bool> get listenable => _light;
  bool get isLight => _light.value;

  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    _light.value = p.getBool(_key) ?? false;
  }

  Future<void> setLight(bool v) async {
    _light.value = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key, v);
  }

  Future<void> toggle() => setLight(!isLight);
}
