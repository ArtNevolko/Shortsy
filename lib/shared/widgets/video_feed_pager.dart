import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoFeedPager extends StatefulWidget {
  final List<String> urls;
  final ValueChanged<int>? onIndexChanged;
  const VideoFeedPager({super.key, required this.urls, this.onIndexChanged});

  @override
  State<VideoFeedPager> createState() => _VideoFeedPagerState();
}

class _VideoFeedPagerState extends State<VideoFeedPager> {
  final _page = PageController();
  final _cache = DefaultCacheManager();
  final Map<int, VideoPlayerController> _controllers = {};
  int _index = 0;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _initIndex(int i) async {
    await _ensureController(i);
    _ensureWindow(i);
    _play(i);
  }

  Future<void> _ensureController(int i) async {
    if (_controllers.containsKey(i)) return;
    if (i < 0 || i >= widget.urls.length) return;
    final src = widget.urls[i];
    try {
      final ctrl =
          await _createController(src).timeout(const Duration(seconds: 8));
      if (_disposed) {
        await ctrl.dispose();
        return;
      }
      await ctrl.initialize().timeout(const Duration(seconds: 8));
      ctrl.setLooping(true);
      _controllers[i] = ctrl;
      setState(() {});
    } catch (_) {
      // оставим без контроллера — покажем Retry
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
    final keep = {center, center - 1, center + 1}
        .where((i) => i >= 0 && i < widget.urls.length)
        .toSet();
    // create neighbors
    for (final i in keep) {
      _ensureController(i);
    }
    // dispose far controllers
    final toDrop = _controllers.keys.where((k) => !keep.contains(k)).toList();
    for (final k in toDrop) {
      _controllers.remove(k)?.dispose();
    }
    // play current, pause others
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
    _disposed = true;
    for (final c in _controllers.values) {
      c.dispose();
    }
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
        final c = _controllers[i];
        if (c == null || !c.value.isInitialized) {
          return _LoadingTile(
            onRetry: () async {
              await _ensureController(i);
              setState(() {});
            },
          );
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

class _LoadingTile extends StatelessWidget {
  final VoidCallback onRetry;
  const _LoadingTile({required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: Center(child: CircularProgressIndicator()),
        ),
        Positioned(
          right: 12,
          bottom: 24,
          child: ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Повторить'),
          ),
        ),
      ],
    );
  }
}
