import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feed_item.dart';
import 'api_client.dart';

class Post {
  final String id;
  final String url;
  final String author;
  final String caption;
  int likes;
  bool liked;
  String? poster;
  Post({
    required this.id,
    required this.url,
    required this.author,
    required this.caption,
    required this.likes,
    required this.liked,
    this.poster,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'author': author,
        'caption': caption,
        'likes': likes,
        'liked': liked,
        'poster': poster,
      };
  static Post fromJson(Map<String, dynamic> m) => Post(
        id: m['id'],
        url: m['url'],
        author: m['author'],
        caption: m['caption'],
        likes: m['likes'] ?? 0,
        liked: m['liked'] ?? false,
        poster: m['poster'],
      );
}

/// Локальное хранилище (синглтон) для мокового фида и лайков
class LocalFeedStore {
  static final LocalFeedStore _i = LocalFeedStore._();
  LocalFeedStore._();
  factory LocalFeedStore() => _i;

  static const _kFeed = 'feed_posts_v1';
  List<Post>? _cache;

  Future<List<Post>> getPosts({bool force = false}) async {
    if (!force && _cache != null) return _cache!;
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kFeed);
    if (raw != null) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _cache = list.map(Post.fromJson).toList();
      return _cache!;
    }
    final seeded = _seed();
    await _save(seeded);
    return _cache!;
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
    _cache = posts;
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
          poster: 'https://i.imgur.com/8Km9tLL.jpg',
        ),
        Post(
          id: 'p2',
          url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
          author: '@creator2',
          caption: 'Mux test stream',
          likes: 420,
          liked: false,
          poster:
              'https://image.mux.com/7xKSBsQJu01yR7Jv013D5yZ3w3r01nHy/thumbnail.jpg',
        ),
        Post(
          id: 'p3',
          url:
              'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8',
          author: '@creator3',
          caption: 'Sintel HLS',
          likes: 940,
          liked: false,
          poster: 'https://bitdash-a.akamaihd.net/content/sintel/poster.png',
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
    final id = 'p${DateTime.now().millisecondsSinceEpoch}';
    final post = Post(
        id: id,
        url: url,
        author: author,
        caption: caption,
        likes: 0,
        liked: false);
    list.insert(0, post);
    await _save(list);
    return post;
  }
}

/// Совместимая обёртка со старым API
class FeedService {
  static final FeedService _i = FeedService._();
  FeedService._();
  factory FeedService() => _i;

  final LocalFeedStore _store = LocalFeedStore();

  Future<List<Post>> getPosts({bool force = false}) =>
      _store.getPosts(force: force);
  Future<void> toggleLike(String id) => _store.toggleLike(id);
  Future<void> resetLikes() => _store.resetLikes();
  Future<void> resetFeed() => _store.resetFeed();
  Future<Post?> getById(String id) => _store.getById(id);
  Future<Post> addPost(
          {required String url, required String author, String caption = ''}) =>
      _store.addPost(url: url, author: author, caption: caption);
}

/// Удалённый сервис фида (новый)
class RemoteFeedService {
  final ApiClient api;
  RemoteFeedService(this.api);

  Future<List<FeedItem>> fetchFeed({int page = 1}) async {
    final data = await api.getJson('/feed?page=$page') as Map<String, dynamic>;
    final list = (data['items'] as List?) ?? const [];
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return FeedItem(
        id: m['id'] as String,
        url: m['videoUrl'] as String,
        author: m['author'] as String? ?? '',
        caption: m['caption'] as String? ?? '',
        sound: m['sound'] as String? ?? '',
        likes: (m['likes'] as num?)?.toInt() ?? 0,
        comments: (m['comments'] as num?)?.toInt() ?? 0,
        saves: (m['saves'] as num?)?.toInt() ?? 0,
        shares: (m['shares'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }
}
