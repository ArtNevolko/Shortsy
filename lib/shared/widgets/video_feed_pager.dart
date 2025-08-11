import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shimmer_tile.dart';

class VideoFeedPager extends StatefulWidget {
  final List<String> urls;
  final List<String>? posters;
  final ValueChanged<int>? onIndexChanged;
  const VideoFeedPager(
      {super.key, required this.urls, this.posters, this.onIndexChanged});

  @override
  State<VideoFeedPager> createState() => _VideoFeedPagerState();
}

class _VideoFeedPagerState extends State<VideoFeedPager>
    with WidgetsBindingObserver {
  final _page = PageController();
  final _cache = DefaultCacheManager();
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, String> _errors = {};
  int _index = 0;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initIndex(0);
    _page.addListener(() {
      final i = _page.page?.round() ?? 0;
      if (i != _index) {
        setState(() => _index = i);
        widget.onIndexChanged?.call(i);
        _ensureWindow(i);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _play(_index);
    } else {
      for (final c in _controllers.values) {
        try {
          c.pause();
        } catch (_) {}
      }
    }
  }

  Future<void> _initIndex(int i) async {
    await _ensureController(i);
    _ensureWindow(i);
    _play(i);
  }

  Future<void> _ensureController(int i, {int attempt = 0}) async {
    if (_controllers.containsKey(i)) return;
    if (i < 0 || i >= widget.urls.length) return;
    final src = widget.urls[i];
    try {
      _errors.remove(i);
      final ctrl =
          await _createController(src).timeout(const Duration(seconds: 8));
      if (_disposed) {
        await ctrl.dispose();
        return;
      }
      await ctrl.initialize().timeout(const Duration(seconds: 8));
      ctrl.setLooping(true);
      _controllers[i] = ctrl;
      if (mounted) setState(() {});
    } catch (e) {
      if (attempt < 2) {
        final delay = Duration(milliseconds: 400 * (1 << attempt));
        await Future.delayed(delay);
        await _ensureController(i, attempt: attempt + 1);
      } else {
        _errors[i] = e.toString();
        if (mounted) setState(() {});
      }
    }
  }

  Future<VideoPlayerController> _createController(String src) async {
    final lower = src.toLowerCase();
    final isHls = lower.contains('.m3u8');
    if (lower.startsWith('http')) {
      if (isHls) {
        // Используем ExoPlayer через video_player — ABR включён по умолчанию для HLS
        return VideoPlayerController.networkUrl(Uri.parse(src));
      }
      try {
        final file =
            await _cache.getSingleFile(src).timeout(const Duration(seconds: 6));
        return VideoPlayerController.file(file);
      } catch (_) {
        return VideoPlayerController.networkUrl(Uri.parse(src));
      }
    } else {
      final path =
          lower.startsWith('file://') ? src.replaceFirst('file://', '') : src;
      return VideoPlayerController.file(File(path));
    }
  }

  void _ensureWindow(int center) {
    final keep = {center};
    for (final i in keep) {
      _ensureController(i);
    }
    final toDrop = _controllers.keys.where((k) => !keep.contains(k)).toList();
    for (final k in toDrop) {
      final c = _controllers.remove(k);
      _errors.remove(k);
      c?.pause();
      c?.dispose();
    }
    for (final entry in _controllers.entries) {
      if (entry.key == center) {
        _play(entry.key);
      } else {
        entry.value.pause();
      }
    }
  }

  void _play(int i) {
    final c = _controllers[i];
    if (c != null && c.value.isInitialized) {
      c.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposed = true;
    for (final c in _controllers.values) {
      try {
        c.pause();
      } catch (_) {}
      c.dispose();
    }
    _controllers.clear();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _page,
      scrollDirection: Axis.vertical,
      itemCount: widget.urls.length,
      itemBuilder: (context, i) {
        if (_errors.containsKey(i)) {
          return _ErrorTile(
            message: _errors[i]!,
            onRetry: () async {
              _controllers.remove(i)?.dispose();
              _errors.remove(i);
              await _ensureController(i);
              if (mounted) setState(() {});
            },
          );
        }
        final c = _controllers[i];
        if (c == null || !c.value.isInitialized) {
          final poster =
              (widget.posters != null && i < (widget.posters!.length))
                  ? widget.posters![i]
                  : '';
          if (poster.isNotEmpty) {
            return CachedNetworkImage(
              imageUrl: poster,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ShimmerTile(),
              errorWidget: (_, __, ___) => const ShimmerTile(),
            );
          }
          return const ShimmerTile();
        }
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: c.value.size.width,
            height: c.value.size.height,
            child: VideoPlayer(c),
          ),
        );
      },
    );
  }
}

class _ErrorTile extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorTile({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Colors.black)),
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.report_gmailerrorred,
                    color: Colors.white70, size: 36),
                const SizedBox(height: 8),
                Text('Видео недоступно',
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 6),
                Text(message,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Повторить')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
