import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedService {
  static final SavedService _i = SavedService._();
  SavedService._();
  factory SavedService() => _i;

  static const _k = 'saved_posts_v1';

  Future<Set<String>> getIds() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_k);
    if (raw == null) return {};
    final list = (jsonDecode(raw) as List).cast<String>();
    return list.toSet();
  }

  Future<bool> isSaved(String id) async => (await getIds()).contains(id);

  Future<void> toggle(String id) async {
    final p = await SharedPreferences.getInstance();
    final s = await getIds();
    if (!s.add(id)) s.remove(id);
    await p.setString(_k, jsonEncode(s.toList()));
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_k);
  }
}
