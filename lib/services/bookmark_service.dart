import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feed_item.dart';

class BookmarkService {
  static const _key = 'bookmarks_v1';

  Future<List<FeedItem>> getAll() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_key) ?? const [];
    return raw
        .map((s) => FeedItem.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(FeedItem item) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_key) ?? <String>[];
    list.removeWhere((s) => (jsonDecode(s)['id'] as String?) == item.id);
    list.insert(0, jsonEncode(item.toJson()));
    await sp.setStringList(_key, list);
  }

  Future<void> remove(String id) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_key) ?? <String>[];
    list.removeWhere((s) => (jsonDecode(s)['id'] as String?) == id);
    await sp.setStringList(_key, list);
  }

  Future<bool> contains(String id) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_key) ?? <String>[];
    return list.any((s) => (jsonDecode(s)['id'] as String?) == id);
  }
}
