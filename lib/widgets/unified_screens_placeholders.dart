import 'package:flutter/material.dart';
import 'video_feed_screen.dart';

class UnifiedVideoFeed extends StatelessWidget {
  const UnifiedVideoFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return const VideoFeedScreen();
  }
}

class UnifiedSearchScreen extends StatelessWidget {
  const UnifiedSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade900,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Search',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Text(
              'Find creators and videos',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class UnifiedLiveScreen extends StatelessWidget {
  const UnifiedLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple.shade900,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.live_tv, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text('Live',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class UnifiedProfileScreen extends StatelessWidget {
  const UnifiedProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green.shade900,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text('Profile',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
