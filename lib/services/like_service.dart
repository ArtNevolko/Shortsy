import 'api_client.dart';

class LikeService {
  final ApiClient api;
  LikeService(this.api);

  Future<Map<String, int>> toggleLike(String itemId, bool like) async {
    final data =
        await api.postJson('/like/toggle', {'id': itemId, 'like': like});
    return {
      'likes': (data['likes'] as num?)?.toInt() ?? 0,
      'comments': (data['comments'] as num?)?.toInt() ?? 0,
      'saves': (data['saves'] as num?)?.toInt() ?? 0,
      'shares': (data['shares'] as num?)?.toInt() ?? 0,
    };
  }
}
