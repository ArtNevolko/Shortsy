import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ThemeSwitcher extends InheritedWidget {
  const ThemeSwitcher({super.key, required super.child});

  static ThemeController of(BuildContext context) {
    final ctrl = ThemeController._();
    return ctrl;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

class ThemeController {
  ThemeController._();
  bool get isLight => ThemeService().isLight;
  Future<void> toggle() => ThemeService().toggle();
  Future<void> setLight(bool v) => ThemeService().setLight(v);
}
