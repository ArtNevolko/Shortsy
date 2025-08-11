import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Post {
  final String id;
  final String url;
  final String author;
  final String caption;
  int likes;
  bool liked;
  Post(
      {required this.id,
      required this.url,
      required this.author,
      required this.caption,
      required this.likes,
      required this.liked});

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'author': author,
        'caption': caption,
        'likes': likes,
        'liked': liked,
      };
  static Post fromJson(Map<String, dynamic> m) => Post(
        id: m['id'],
        url: m['url'],
        author: m['author'],
        caption: m['caption'],
        likes: m['likes'] ?? 0,
        liked: m['liked'] ?? false,
      );
}

class FeedService {
  static final FeedService _i = FeedService._();
  FeedService._();
  factory FeedService() => _i;

  static const _kFeed = 'feed_posts_v1';

  Future<List<Post>> getPosts() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kFeed);
    if (raw != null) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(Post.fromJson).toList();
    }
    final seeded = _seed();
    await _save(seeded);
    return seeded;
  }

  Future<void> toggleLike(String id) async {
    final list = await getPosts();
    final ix = list.indexWhere((e) => e.id == id);
    if (ix < 0) return;
    final p = list[ix];
    if (p.liked) {
      p.liked = false;
      p.likes = (p.likes - 1).clamp(0, 1 << 31);
    } else {
      p.liked = true;
      p.likes += 1;
    }
    await _save(list);
  }

  Future<void> resetLikes() async {
    final list = await getPosts();
    for (final p in list) {
      p.liked = false;
    }
    await _save(list);
  }

  Future<void> resetFeed() async {
    final seeded = _seed();
    await _save(seeded);
  }

  Future<void> _save(List<Post> posts) async {
    final p = await SharedPreferences.getInstance();
    final raw = jsonEncode(posts.map((e) => e.toJson()).toList());
    await p.setString(_kFeed, raw);
  }

  List<Post> _seed() => [
        Post(
          id: 'p1',
          url:
              'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear3/prog_index.m3u8',
          author: '@creator',
          caption: 'BipBop sample',
          likes: 12300,
          liked: false,
        ),
        Post(
          id: 'p2',
          url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
          author: '@creator2',
          caption: 'Mux test stream',
          likes: 420,
          liked: false,
        ),
        Post(
          id: 'p3',
          url:
              'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8',
          author: '@creator3',
          caption: 'Sintel HLS',
          likes: 940,
          liked: false,
        ),
      ];

  Future<Post?> getById(String id) async {
    final list = await getPosts();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Post> addPost(
      {required String url,
      required String author,
      String caption = ''}) async {
    final list = await getPosts();
    final id = 'p' + DateTime.now().millisecondsSinceEpoch.toString();
    final post = Post(
      id: id,
      url: url,
      author: author,
      caption: caption,
      likes: 0,
      liked: false,
    );
    list.insert(0, post);
    await _save(list);
    return post;
  }
}
