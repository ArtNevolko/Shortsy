import 'package:flutter/material.dart';
import '../shared/widgets/index.dart';

class TagScreen extends StatelessWidget {
  final String tag;
  const TagScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final urls = const [
      'https://sample-videos.com/video321/mp4/480/big_buck_bunny_480p_10mb.mp4',
      'https://sample-videos.com/video321/mp4/480/big_buck_bunny_480p_1mb.mp4',
    ];
    return AppScaffold(
      title: tag,
      child: VerticalVideoPager(urls: urls),
    );
  }
}
