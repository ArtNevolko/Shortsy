import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/saved_service.dart';
import '../shared/widgets/index.dart';

class VideoPostScreen extends StatefulWidget {
  final String url;
  const VideoPostScreen({super.key, required this.url});

  @override
  State<VideoPostScreen> createState() => _VideoPostScreenState();
}

class _VideoPostScreenState extends State<VideoPostScreen> {
  VideoPlayerController? _c;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() => _ready = true);
        _c?.setLooping(true);
        _c?.play();
      });
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const CommentsSheet(postId: 'video_post_single'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ready && _c != null
          ? Stack(
              children: [
                Center(
                    child: AspectRatio(
                        aspectRatio: _c!.value.aspectRatio,
                        child: VideoPlayer(_c!))),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.more_vert_rounded),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 120,
                  child: Column(
                    children: [
                      _Action(icon: Icons.favorite, label: '12.3K'),
                      const SizedBox(height: 12),
                      _Action(
                          icon: Icons.comment,
                          label: '245',
                          onTap: _openComments),
                      const SizedBox(height: 12),
                      FutureBuilder<bool>(
                        future: SavedService().isSaved(widget.url),
                        builder: (_, s) {
                          final saved = s.data ?? false;
                          return _Action(
                            icon:
                                saved ? Icons.bookmark : Icons.bookmark_border,
                            label: saved ? 'Saved' : 'Save',
                            onTap: () async {
                              await SavedService().toggle(widget.url);
                              if (mounted) setState(() {});
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _Action(icon: Icons.share, label: 'Поделиться'),
                    ],
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: SafeArea(
                    top: false,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                            radius: 16, backgroundColor: Colors.white24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '@creator • Описание клипа, #хэштеги',
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
                    ),
                  ),
                )
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _Action({required this.icon, required this.label, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Glass(
            padding: const EdgeInsets.all(12),
            borderRadius: BorderRadius.circular(28),
            child: Icon(icon, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}
