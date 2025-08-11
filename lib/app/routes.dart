import 'package:flutter/material.dart';
import '../features/profile/index.dart';
import '../features/discover/index.dart';
import '../features/feed/index.dart';
import '../features/live/index.dart';
import '../features/create/index.dart';
import '../features/inbox/index.dart';

class RouteNames {
  static const editProfile = '/edit_profile';
  static const tag = '/tag';
  static const videoPost = '/video_post';
  static const liveSetup = '/live_setup';
  static const live = '/live';
  static const upload = '/upload';
  static const chat = '/chat';
}

class AppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case RouteNames.tag:
        final args = settings.arguments as Map<String, dynamic>?;
        final String tag = args?['tag'] ?? '#tag';
        return MaterialPageRoute(builder: (_) => TagScreen(tag: tag));
      case RouteNames.videoPost:
        final args = settings.arguments as Map<String, dynamic>?;
        final String url = args?['url'] ?? '';
        return MaterialPageRoute(builder: (_) => VideoPostScreen(url: url));
      case RouteNames.liveSetup:
        return MaterialPageRoute(builder: (_) => const LiveStreamSetupScreen());
      case RouteNames.live:
        return MaterialPageRoute(builder: (_) => const LiveScreen());
      case RouteNames.upload:
        return MaterialPageRoute(builder: (_) => const UploadClipScreen());
      case RouteNames.chat:
        final args = settings.arguments as Map<String, dynamic>?;
        final String title = args?['title'] ?? 'Chat';
        return MaterialPageRoute(builder: (_) => ChatScreen(title: title));
    }
    return null;
  }
}
