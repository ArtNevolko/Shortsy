import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FollowService {
  static final FollowService _i = FollowService._();
  FollowService._();
  factory FollowService() => _i;

  static const _k = 'follows_v1';

  Future<Set<String>> getFollows() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_k);
    if (raw == null) return {};
    final list = (jsonDecode(raw) as List).cast<String>();
    return list.toSet();
  }

  Future<bool> isFollowing(String handle) async {
    final s = await getFollows();
    return s.contains(handle);
  }

  Future<void> toggle(String handle) async {
    final p = await SharedPreferences.getInstance();
    final s = await getFollows();
    if (!s.add(handle)) s.remove(handle);
    await p.setString(_k, jsonEncode(s.toList()));
  }

  Future<void> reset() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_k);
  }
}
