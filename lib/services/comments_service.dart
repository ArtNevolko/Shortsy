import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CommentsService {
  static final CommentsService _i = CommentsService._();
  CommentsService._();
  factory CommentsService() => _i;

  String _key(String postId) => 'comments_v1_' + postId;

  Future<List<String>> getAll(String postId) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key(postId));
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<String>();
  }

  Future<int> count(String postId) async => (await getAll(postId)).length;

  Future<void> add(String postId, String text) async {
    final list = await getAll(postId);
    list.add(text);
    await _save(postId, list);
  }

  Future<void> clear(String postId) async => _save(postId, []);

  Future<void> clearAll() async {
    final p = await SharedPreferences.getInstance();
    final keys =
        p.getKeys().where((k) => k.startsWith('comments_v1_')).toList();
    for (final k in keys) {
      await p.remove(k);
    }
  }

  Future<void> _save(String postId, List<String> list) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key(postId), jsonEncode(list));
  }
}
