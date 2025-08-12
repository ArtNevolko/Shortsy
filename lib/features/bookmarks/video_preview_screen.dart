import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/feed_item.dart';
import '../../services/bookmark_service.dart';

class VideoPreviewScreen extends StatefulWidget {
  final FeedItem item;
  const VideoPreviewScreen({super.key, required this.item});
  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late final VideoPlayerController _vc;
  bool _ready = false;
  final _bm = BookmarkService();

  @override
  void initState() {
    super.initState();
    _vc = VideoPlayerController.networkUrl(Uri.parse(widget.item.url))
      ..setLooping(true)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _vc.play();
      });
  }

  @override
  void dispose() {
    _vc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('Предпросмотр')),
      body: Stack(children: [
        Positioned.fill(
            child: _ready
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                        width: _vc.value.size.width,
                        height: _vc.value.size.height,
                        child: VideoPlayer(_vc)))
                : const ColoredBox(color: Colors.black)),
        Positioned(
          right: 16,
          bottom: 24,
          child: Column(children: [
            ElevatedButton.icon(
              onPressed: () async {
                await _bm.remove(widget.item.id);
                if (mounted) Navigator.of(context).pop(true);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              icon: const Icon(Icons.delete),
              label: const Text('Удалить из закладок'),
            ),
          ]),
        ),
      ]),
    );
  }
}
