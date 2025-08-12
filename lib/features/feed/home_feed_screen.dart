import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/feed_item.dart';
import '../../services/bookmark_service.dart';
import '../../services/settings_service.dart';
import '../../services/cache_service.dart';
import '../comments/comments_sheet.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../../services/feed_service.dart';
import '../../services/like_service.dart';
import '../../services/api_client.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});
  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final PageController _pager = PageController();
  int _tab = 1; // 0 – Подписки, 1 – Рекомендации
  List<FeedItem> _items = List.generate(12, (i) => FeedItem.mock(i));
  final SettingsService _settings = SettingsService();
  bool _muted = false;
  final CacheService _cache = CacheService();
  final ValueNotifier<int> _current = ValueNotifier<int>(0);
  final ApiClient _api = const ApiClient('https://api.shortsy.local');

  @override
  void initState() {
    super.initState();
    _settings.isMuted().then((v) {
      if (!mounted) return;
      setState(() => _muted = v);
    });
    _pager.addListener(_onScroll);
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      final service = RemoteFeedService(_api);
      final items = await service.fetchFeed(page: 1);
      if (!mounted) return;
      setState(() => _items = items.isNotEmpty ? items : _items);
    } catch (_) {}
    // префетч стартовых роликов
    for (final i in [0, 1]) {
      if (i < _items.length) {
        _cache.prefetch(_items[i].url);
      }
    }
  }

  void _onScroll() {
    final raw = _pager.page ?? 0.0;
    final page = raw.round();
    if (_current.value != page) _current.value = page;
    for (final i in [page - 1, page + 1]) {
      if (i >= 0 && i < _items.length) {
        _cache.prefetch(_items[i].url);
      }
    }
  }

  @override
  void dispose() {
    _pager.removeListener(_onScroll);
    _pager.dispose();
    super.dispose();
  }

  Future<void> _toggleMuteAll() async {
    final v = !_muted;
    setState(() => _muted = v);
    await _settings.setMuted(v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        PageView.builder(
          controller: _pager,
          scrollDirection: Axis.vertical,
          itemCount: _items.length,
          itemBuilder: (context, index) => VideoPage(
            item: _items[index],
            muted: _muted,
            index: index,
            currentIndex: _current,
          ),
        ),
        // верхние табы по центру
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                TabChip(
                    text: 'Подписки',
                    active: _tab == 0,
                    onTap: () => setState(() => _tab = 0)),
                const SizedBox(width: 6),
                TabChip(
                    text: 'Рекомендации',
                    active: _tab == 1,
                    onTap: () => setState(() => _tab = 1)),
              ]),
            ),
          ),
        ),
        // mute слева сверху
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: IconButton(
            icon: Icon(_muted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white),
            onPressed: _toggleMuteAll,
          ),
        ),
        // кнопка Закладки справа сверху
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BookmarksScreen()),
              );
            },
          ),
        ),
        // индикаторы справа
        Positioned(
          right: 6,
          top: MediaQuery.of(context).size.height * 0.2,
          bottom: MediaQuery.of(context).size.height * 0.2,
          child: DotsIndicator(count: _items.length, controller: _pager),
        ),
      ]),
    );
  }
}

class TabChip extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;
  const TabChip(
      {super.key,
      required this.text,
      required this.active,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                color: active ? Colors.black : Colors.white,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class VideoPage extends StatefulWidget {
  final FeedItem item;
  final bool muted;
  final int index;
  final ValueNotifier<int> currentIndex;
  const VideoPage(
      {super.key,
      required this.item,
      required this.muted,
      required this.index,
      required this.currentIndex});
  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  VideoPlayerController? _vc;
  bool _ready = false;
  bool _saved = false;
  final _bm = BookmarkService();
  bool _showHeart = false;
  bool _disposed = false;

  late final LikeService _likes =
      LikeService(const ApiClient('https://api.shortsy.local'));
  int _likeCount = 0;
  bool _liked = false;
  bool _userPaused = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.item.likes;
    _initController();
    _bm.contains(widget.item.id).then((v) {
      if (mounted) setState(() => _saved = v);
    });
    WidgetsBinding.instance.addObserver(this);
    widget.currentIndex.addListener(_onIndexChange);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _vc;
    if (c == null || !_ready) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _syncPlayState();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        c.pause();
        break;
    }
  }

  void _onIndexChange() {
    if (!mounted) return;
    if (widget.currentIndex.value == widget.index) {
      // Новая карточка попала в фокус — снимаем пользовательскую паузу и синхронизируем воспроизведение
      _userPaused = false;
    }
    _syncPlayState();
  }

  Future<void> _initController() async {
    // Закрываем предыдущий контроллер, если был
    final prev = _vc;
    if (prev != null) {
      await prev.pause();
      await prev.dispose();
    }
    _vc = null;
    _ready = false;
    if (mounted) setState(() {});
    final cache = CacheService();
    File? file;
    try {
      file = await cache.prefetch(widget.item.url);
    } catch (_) {}
    if (_disposed) return;
    final c = (file != null && await file.exists())
        ? VideoPlayerController.file(file)
        : VideoPlayerController.networkUrl(Uri.parse(widget.item.url));
    _vc = c;
    await c.setLooping(true);
    await c.initialize();
    if (_disposed || !mounted) {
      try {
        await c.dispose();
      } catch (_) {}
      return;
    }
    _ready = true;
    _applyMute(widget.muted);
    _syncPlayState();
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPlayState();
  }

  void _syncPlayState() {
    final c = _vc;
    if (!_ready || c == null) return;
    final tickersOn = TickerMode.of(context);
    final routeActive = ModalRoute.of(context)?.isCurrent ?? true;
    if (!tickersOn || !routeActive) {
      c.pause();
      return;
    }
    final isCurrent = widget.currentIndex.value == widget.index;
    if (isCurrent && !_userPaused) {
      c.play();
    } else {
      c.pause();
    }
  }

  @override
  void didUpdateWidget(covariant VideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.muted != widget.muted) _applyMute(widget.muted);
    if (oldWidget.currentIndex != widget.currentIndex) {
      oldWidget.currentIndex.removeListener(_syncPlayState);
      widget.currentIndex.addListener(_syncPlayState);
      _syncPlayState();
    }
  }

  void _applyMute(bool v) {
    final c = _vc;
    if (!_ready || c == null) return;
    c.setVolume(v ? 0 : 1);
  }

  @override
  void dispose() {
    widget.currentIndex.removeListener(_onIndexChange);
    WidgetsBinding.instance.removeObserver(this);
    final c = _vc;
    _vc = null;
    if (c != null) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _toggleSave() async {
    if (_saved) {
      await _bm.remove(widget.item.id);
    } else {
      await _bm.add(widget.item);
    }
    if (mounted) setState(() => _saved = !_saved);
  }

  void _onDoubleTap() async {
    if (!mounted) return;
    setState(() => _showHeart = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showHeart = false);
    });
    // оптимистичный лайк
    setState(() {
      _liked = true;
      _likeCount = (_likeCount + 1);
    });
    try {
      final counters = await _likes.toggleLike(widget.item.id, true);
      if (!mounted) return;
      setState(() => _likeCount = counters['likes'] ?? _likeCount);
    } catch (_) {}
  }

  void _share() {
    Share.share(widget.item.url);
  }

  void _openComments() async {
    if (!mounted) return;
    final c = _vc;
    if (_ready && c != null) {
      await c.pause();
    }
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      builder: (_) => CommentsSheet(itemId: widget.item.id),
    );
    if (!mounted) return;
    _syncPlayState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _syncPlayState();
    final c = _vc;
    final isPlaying = _ready && c != null && c.value.isPlaying;
    return GestureDetector(
      onTap: () async {
        final ctrl = _vc;
        if (!_ready || ctrl == null) return;
        if (ctrl.value.isPlaying) {
          await ctrl.pause();
          if (mounted) setState(() => _userPaused = true);
        } else {
          if (mounted) setState(() => _userPaused = false);
          await ctrl.play();
        }
      },
      onDoubleTap: _onDoubleTap,
      child: Stack(children: [
        Positioned.fill(
            child: (_ready && c != null)
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                        width: c.value.size.width,
                        height: c.value.size.height,
                        child: VideoPlayer(c)),
                  )
                : const ColoredBox(color: Colors.black)),
        if (!isPlaying)
          const Center(
              child: Icon(Icons.play_arrow_rounded,
                  size: 72, color: Colors.white70)),
        const Positioned.fill(child: IgnorePointer(child: SubtleVignette())),
        if (_showHeart)
          const Positioned.fill(
              child: IgnorePointer(
                  child: Center(
                      child: Icon(Icons.favorite,
                          color: Colors.white70, size: 80)))),
        Positioned(
          right: 8,
          bottom: 90,
          child: ActionsColumn(
            item: widget.item,
            saved: _saved,
            onSave: _toggleSave,
            onComments: _openComments,
            onShare: _share,
            likes: _likeCount,
            liked: _liked,
          ),
        ),
        Positioned(
            left: 12,
            right: 90,
            bottom: 24,
            child: CaptionBar(item: widget.item)),
      ]),
    );
  }
}

class ActionsColumn extends StatelessWidget {
  final FeedItem item;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onComments;
  final VoidCallback onShare;
  final int likes;
  final bool liked;
  const ActionsColumn(
      {super.key,
      required this.item,
      required this.saved,
      required this.onSave,
      required this.onComments,
      required this.onShare,
      required this.likes,
      required this.liked});
  @override
  Widget build(BuildContext context) {
    final TextStyle counter =
        const TextStyle(color: Colors.white, fontSize: 12);
    return Column(children: [
      _roundBtn(liked ? Icons.favorite : Icons.favorite_border,
          onTap: () {}, color: liked ? Colors.pinkAccent : Colors.white),
      const SizedBox(height: 6),
      Text('$likes', style: counter),
      const SizedBox(height: 14),
      _roundBtn(Icons.mode_comment_rounded, onTap: onComments),
      const SizedBox(height: 6),
      Text('${item.comments}', style: counter),
      const SizedBox(height: 14),
      _roundBtn(saved ? Icons.bookmark : Icons.bookmark_border, onTap: onSave),
      const SizedBox(height: 6),
      Text('${item.saves}', style: counter),
      const SizedBox(height: 14),
      _roundBtn(Icons.share_rounded, onTap: onShare),
      const SizedBox(height: 6),
      Text('${item.shares}', style: counter),
    ]);
  }

  Widget _roundBtn(IconData icon, {VoidCallback? onTap, Color? color}) =>
      InkResponse(
        onTap: onTap,
        radius: 26,
        child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: Colors.black38, borderRadius: BorderRadius.circular(22)),
            child: Icon(icon, color: color ?? Colors.white)),
      );
}

class CaptionBar extends StatelessWidget {
  final FeedItem item;
  const CaptionBar({super.key, required this.item});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const CircleAvatar(radius: 16, backgroundColor: Colors.white24),
        const SizedBox(width: 8),
        Expanded(
            child: Text('@${item.author}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700))),
        const SizedBox(width: 8),
        TextButton(onPressed: () {}, child: const Text('Подписаться')),
      ]),
      const SizedBox(height: 6),
      Text(item.caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white)),
      const SizedBox(height: 4),
      const Text('♪ Original Sound',
          style: TextStyle(color: Colors.white70, fontSize: 12)),
    ]);
  }
}

class DotsIndicator extends StatefulWidget {
  final int count;
  final PageController controller;
  const DotsIndicator(
      {super.key, required this.count, required this.controller});
  @override
  State<DotsIndicator> createState() => _DotsIndicatorState();
}

class _DotsIndicatorState extends State<DotsIndicator> {
  double _page = 0;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  void _listener() => setState(() => _page =
      widget.controller.page ?? widget.controller.initialPage.toDouble());
  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.count, (i) {
        final active = (i - _page).abs() < 0.5;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(vertical: 4),
          width: 6,
          height: active ? 22 : 10,
          decoration: BoxDecoration(
              color: active ? Colors.white : Colors.white38,
              borderRadius: BorderRadius.circular(4)),
        );
      }),
    );
  }
}

class SubtleVignette extends StatelessWidget {
  const SubtleVignette({super.key});
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
              center: const Alignment(0, -0.3),
              radius: 1.2,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.25)
              ],
              stops: const [
                0.7,
                1.0
              ]),
        ),
      ),
    );
  }
}
