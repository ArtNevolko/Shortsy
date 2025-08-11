import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../shared/widgets/index.dart';
import '../shared/services/index.dart';

class UploadClipScreen extends StatefulWidget {
  const UploadClipScreen({super.key});

  @override
  State<UploadClipScreen> createState() => _UploadClipScreenState();
}

class _UploadClipScreenState extends State<UploadClipScreen> {
  VideoPlayerController? _c;
  bool _ready = false;
  String? _pickedPath;

  Future<void> _pick() async {
    final picker = ImagePicker();
    final x = await picker.pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(minutes: 1));
    if (x == null) return;
    _c?.dispose();
    _c = VideoPlayerController.file(File(x.path))
      ..initialize().then((_) {
        setState(() => _ready = true);
        _c?.setLooping(true);
        _c?.play();
      });
    _pickedPath = x.path;
    setState(() {});
  }

  Future<void> _publish() async {
    final url = _pickedPath;
    if (url == null) return;
    await FeedService().addPost(url: url, author: '@me', caption: 'Новый клип');
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Клип опубликован')));
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const GlassHeader(title: 'Загрузка клипа'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: _ready && _c != null
                            ? AspectRatio(
                                aspectRatio: _c!.value.aspectRatio,
                                child: VideoPlayer(_c!))
                            : const Text('Выберите видео до 60 секунд'),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton.primary(
                            label: 'Выбрать видео',
                            icon: Icons.video_library_rounded,
                            onPressed: _pick,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton.primary(
                            label: 'Опубликовать',
                            icon: Icons.cloud_upload_rounded,
                            onPressed: _ready ? _publish : null,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
