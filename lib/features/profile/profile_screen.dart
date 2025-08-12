import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../models/feed_item.dart';
import '../../services/bookmark_service.dart';
import '../bookmarks/video_preview_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text('Профиль',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const CircleAvatar(
                      radius: 36, backgroundColor: Colors.white24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('@creator',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18)),
                        SizedBox(height: 4),
                        Text('О себе: создаю классный контент!',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24)),
                    child: const Text('Редактировать'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Stat(value: '1.2M', label: 'Подписчики'),
                  _Stat(value: '256', label: 'Подписки'),
                  _Stat(value: '84.5K', label: 'Лайки'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabs,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: const [Tab(text: 'Видео'), Tab(text: 'Закладки')],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: const [
                  _GridTab(seed: 'v'),
                  _GridTab(seed: 'b'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ]);
  }
}

class _GridTab extends StatefulWidget {
  final String seed;
  const _GridTab({required this.seed});
  @override
  State<_GridTab> createState() => _GridTabState();
}

class _GridTabState extends State<_GridTab> {
  final _bm = BookmarkService();
  List<FeedItem> _items = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.seed == 'b') _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
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
    if (widget.seed != 'b') {
      // старый мок для «Видео»
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 9 / 16),
        itemCount: 30,
        itemBuilder: (context, i) => ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: const ColoredBox(color: Colors.white12),
        ),
      );
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty)
      return const Center(
          child: Text('Пока нет закладок',
              style: TextStyle(color: Colors.white70)));
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 9 / 16),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final it = _items[i];
        return FutureBuilder<Uint8List?>(
          future: _thumb(it.url),
          builder: (context, snap) {
            final bytes = snap.data;
            return GestureDetector(
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (_) => VideoPreviewScreen(item: it)))
                  .then((_) => _load()),
              onLongPress: () async {
                await _bm.remove(it.id);
                await _load();
              },
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
                          colors: [Color(0xAA000000), Color(0x00000000)]),
                    ),
                  ),
                ]),
              ),
            );
          },
        );
      },
    );
  }
}
