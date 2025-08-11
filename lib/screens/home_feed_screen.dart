import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../shared/services/index.dart';
import '../shared/widgets/video_feed_pager.dart';
import '../widgets/comments_sheet.dart';
import '../app/routes.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  late Future<List<Post>> _future;
  int _current = 0;
  List<Post> _postsCache = [];
  @override
  void initState() {
    super.initState();
    _future = FeedService().getPosts();
  }

  Future<void> _toggleLike(Post p) async {
    // оптимистичное обновление UI
    final ix = _postsCache.indexWhere((e) => e.id == p.id);
    if (ix != -1) {
      final wasLiked = _postsCache[ix].liked;
      setState(() {
        _postsCache[ix].liked = !wasLiked;
        _postsCache[ix].likes += wasLiked ? -1 : 1;
      });
    } else {
      setState(() {
        p.liked = !p.liked;
        p.likes += p.liked ? 1 : -1;
      });
    }
    // persist
    await FeedService().toggleLike(p.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasData && _postsCache.isEmpty) {
          _postsCache = List<Post>.from(snap.data!);
        }
        final posts = _postsCache.isNotEmpty
            ? _postsCache
            : (snap.data ?? const <Post>[]);
        final ready =
            (posts).isNotEmpty && snap.connectionState == ConnectionState.done;
        return Stack(
          children: [
            // Собственный тёмный фон под ленту (перекрывает общую анимацию)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0A0A0A), Color(0xFF12121A)],
                  ),
                ),
              ),
            ),
            // Видео-лента и двойной тап по видео
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onDoubleTap: () {
                  if (!ready) return;
                  _toggleLike(posts[_current]);
                },
                child: VideoFeedPager(
                  key: ValueKey(_current),
                  urls: posts.map((e) => e.url).toList(),
                  posters: posts.map((e) => e.poster ?? '').toList(),
                  onIndexChanged: (i) => setState(() => _current = i),
                ),
              ),
            ),
            // Простой верхний бар (без стекла)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Row(
                    children: [
                      const Text(
                        'Shortsy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.wifi_tethering,
                            color: Colors.white),
                        onPressed: () =>
                            Navigator.of(context).pushNamed(RouteNames.live),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded,
                            color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _future = FeedService().getPosts(force: true);
                            _postsCache = [];
                            _current = 0;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Правая панель действий
            if (ready)
              Positioned(
                right: 12,
                bottom: 140,
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Builder(builder: (_) {
                        final p = posts[_current];
                        return IconButton(
                          iconSize: 28,
                          icon: Icon(
                            p.liked ? Icons.favorite : Icons.favorite_border,
                            color: p.liked ? Colors.redAccent : Colors.white,
                          ),
                          onPressed: () => _toggleLike(p),
                        );
                      }),
                      const SizedBox(height: 8),
                      Builder(builder: (_) {
                        final p = posts[_current];
                        return FutureBuilder<int>(
                          future: CommentsService().count(p.id),
                          builder: (_, s) => IconButton(
                            iconSize: 28,
                            icon:
                                const Icon(Icons.comment, color: Colors.white),
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (_) => CommentsSheet(postId: p.id),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      Builder(builder: (_) {
                        final p = posts[_current];
                        return FutureBuilder<bool>(
                          future: SavedService().isSaved(p.id),
                          builder: (_, s) => IconButton(
                            iconSize: 28,
                            icon: Icon(
                              (s.data ?? false)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              await SavedService().toggle(p.id);
                              if (mounted) setState(() {});
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      Builder(builder: (_) {
                        final p = posts[_current];
                        return IconButton(
                          iconSize: 28,
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () => Share.share(
                              'Смотри ${p.author}: ${p.url} — через Shortsy'),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            // Нижняя строка автора/описания
            if (ready)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: SafeArea(
                  top: false,
                  child: Builder(builder: (_) {
                    final p = posts[_current];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                            radius: 16, backgroundColor: Colors.white24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${p.author} • ${p.caption}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                    color: Colors.black54,
                                    blurRadius: 6,
                                    offset: Offset(0, 1)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
          ],
        );
      },
    );
  }
}
