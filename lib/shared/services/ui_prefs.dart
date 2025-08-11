import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UiPrefs {
  static final UiPrefs _i = UiPrefs._();
  UiPrefs._();
  factory UiPrefs() => _i;

  static const _kAnimBackdrop = 'anim_backdrop';

  final ValueNotifier<bool> animatedBackdrop = ValueNotifier<bool>(true);

  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    animatedBackdrop.value = p.getBool(_kAnimBackdrop) ?? true;
  }

  Future<void> setAnimatedBackdrop(bool v) async {
    animatedBackdrop.value = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kAnimBackdrop, v);
  }
}
