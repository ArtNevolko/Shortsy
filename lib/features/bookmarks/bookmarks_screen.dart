import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../models/feed_item.dart';
import '../../services/bookmark_service.dart';
import 'video_preview_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});
  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final _bm = BookmarkService();
  List<FeedItem> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _bm.getAll();
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<Uint8List?> _thumb(String url) async {
    try {
      return await VideoThumbnail.thumbnailData(
          video: url,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 300,
          timeMs: 1000,
          quality: 70);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: const Text('Закладки'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Text('Нет сохранённых видео',
                      style: TextStyle(color: Colors.white70)))
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 9 / 16,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final it = _items[i];
                    return FutureBuilder<Uint8List?>(
                      future: _thumb(it.url),
                      builder: (context, snap) {
                        final bytes = snap.data;
                        return GestureDetector(
                          onLongPress: () async {
                            await _bm.remove(it.id);
                            await _load();
                          },
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      VideoPreviewScreen(item: it))),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(fit: StackFit.expand, children: [
                              if (bytes != null)
                                Image.memory(bytes, fit: BoxFit.cover)
                              else
                                const ColoredBox(color: Colors.white12),
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.center,
                                      colors: [
                                        Color(0xAA000000),
                                        Color(0x00000000)
                                      ]),
                                ),
                              ),
                              Positioned(
                                  left: 6,
                                  right: 6,
                                  bottom: 6,
                                  child: Text(it.caption,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 11))),
                            ]),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
