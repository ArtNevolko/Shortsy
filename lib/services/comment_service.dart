import '../models/comment.dart';
import 'api_client.dart';

class CommentService {
  final ApiClient api;
  CommentService(this.api);

  Future<List<Comment>> list(String itemId) async {
    final data = await api.getJson('/comments?item=$itemId');
    final list = (data['items'] as List?) ?? const [];
    return list
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Comment> add(String itemId, String text) async {
    final data =
        await api.postJson('/comments/add', {'id': itemId, 'text': text});
    return Comment.fromJson(data as Map<String, dynamic>);
  }
}
