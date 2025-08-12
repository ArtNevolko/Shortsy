import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../shared/services/network_service.dart';

typedef IndexChanged = void Function(int index);

class VerticalVideoPager extends StatefulWidget {
  final List<String> urls;
  final IndexChanged? onIndexChanged;
  const VerticalVideoPager(
      {super.key, required this.urls, this.onIndexChanged});

  @override
  State<VerticalVideoPager> createState() => _VerticalVideoPagerState();
}

class _VerticalVideoPagerState extends State<VerticalVideoPager> {
  final PageController _pc = PageController();
  final Map<int, VideoPlayerController> _controllers = {};
  int _current = 0;

  final _cache = DefaultCacheManager();
  StreamSubscription<NetworkProfile>? _netSub;

  @override
  void initState() {
    super.initState();
    NetworkService().start();
    _netSub = NetworkService().stream.listen((_) {});
    _initFor(_current);
  }

  Future<void> _initFor(int index) async {
    await _ensureController(index);
    _play(index);
    // Предзагрузка соседей
    _ensureController(index + 1);
    _ensureController(index - 1);
    _disposeExcept({index, index + 1, index - 1});
  }

  Future<VideoPlayerController> _createController(String source) async {
    if (source.startsWith('http')) {
      final file = await _cache.getSingleFile(source);
      return VideoPlayerController.file(file);
    } else {
      final path = source.startsWith('file://')
          ? source.replaceFirst('file://', '')
          : source;
      return VideoPlayerController.file(File(path));
    }
  }

  Future<void> _ensureController(int index) async {
    if (index < 0 || index >= widget.urls.length) return;
    if (_controllers.containsKey(index)) return;
    final url = widget.urls[index];
    final VideoPlayerController controller = await _createController(url);
    await controller.initialize();
    controller.setLooping(true);
    _controllers[index] = controller;
    if (mounted) setState(() {});
  }

  void _disposeExcept(Set<int> keep) {
    final keys = _controllers.keys.toList();
    for (final k in keys) {
      if (!keep.contains(k)) {
        _controllers[k]?.dispose();
        _controllers.remove(k);
      }
    }
  }

  void _play(int index) {
    for (final e in _controllers.entries) {
      if (e.key == index) {
        e.value.play();
      } else {
        e.value.pause();
      }
    }
  }

  @override
  void dispose() {
    _netSub?.cancel();
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pc,
      scrollDirection: Axis.vertical,
      itemCount: widget.urls.length,
      onPageChanged: (i) {
        _current = i;
        widget.onIndexChanged?.call(i);
        _initFor(i);
      },
      itemBuilder: (_, i) {
        final c = _controllers[i];
        if (c == null || !c.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        return GestureDetector(
          onTap: () => c.value.isPlaying ? c.pause() : c.play(),
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: c.value.size.width,
              height: c.value.size.height,
              child: VideoPlayer(c),
            ),
          ),
        );
      },
    );
  }
}
