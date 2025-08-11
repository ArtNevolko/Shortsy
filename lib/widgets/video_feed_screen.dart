import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _likeController;
  late AnimationController _shareController;
  late AnimationController _followController;

  late Animation<double> _likeAnimation;
  late Animation<double> _shareAnimation;
  late Animation<double> _followAnimation;

  bool _isLiked = false;
  bool _isFollowing = false;

  final List<VideoData> _videos = [
    VideoData(
      username: 'john',
      displayName: 'John D.',
      description: 'Awesome day #shorts',
      likes: 1234,
      comments: 120,
      shares: 35,
      isVerified: true,
      musicName: 'Nice Beat',
      hashtags: const ['#fun', '#shorts'],
    ),
    VideoData(
      username: 'kate',
      displayName: 'Kate',
      description: 'Travel vlog',
      likes: 532,
      comments: 45,
      shares: 10,
      isVerified: false,
      musicName: 'Summer',
      hashtags: const ['#travel'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.9,
      upperBound: 1.1,
    );
    _shareController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.9,
      upperBound: 1.1,
    );
    _followController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.9,
      upperBound: 1.1,
    );

    _likeAnimation =
        CurvedAnimation(parent: _likeController, curve: Curves.easeOut);
    _shareAnimation =
        CurvedAnimation(parent: _shareController, curve: Curves.easeOut);
    _followAnimation =
        CurvedAnimation(parent: _followController, curve: Curves.easeOut);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _likeController.dispose();
    _shareController.dispose();
    _followController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onLike() {
    setState(() => _isLiked = !_isLiked);
    _likeController.forward(from: 0.9);
  }

  void _onShare() {
    _shareController.forward(from: 0.9);
    _showShareBottomSheet();
  }

  void _onFollow() {
    setState(() => _isFollowing = !_isFollowing);
    _followController.forward(from: 0.9);
  }

  void _showShareBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildShareBottomSheet(),
    );
  }

  Widget _buildShareBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.5),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareOption(Icons.share, 'Share', Colors.purple),
              _buildShareOption(Icons.link, 'Copy link', Colors.blue),
              _buildShareOption(Icons.sms, 'Message', Colors.green),
              _buildShareOption(Icons.more_horiz, 'More', Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [color.withValues(alpha: 0.8), color]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _videos.length,
            scrollDirection: Axis.vertical,
            onPageChanged: (i) {},
            itemBuilder: (context, index) => _buildVideoPage(_videos[index]),
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: _buildTopBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text('Following', style: TextStyle(color: Colors.white70)),
        Text('For You',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Icon(Icons.search, color: Colors.white),
      ],
    );
  }

  Widget _buildVideoPage(VideoData video) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.grey.shade900),
        Align(
          alignment: Alignment.bottomLeft,
          child: _buildVideoInfo(video),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: _buildSideActions(video),
        ),
        Positioned.fill(child: _buildDoubleTapArea()),
      ],
    );
  }

  Widget _buildVideoInfo(VideoData video) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text('@${video.username}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(video.description,
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildSideActions(VideoData video) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            animation: _likeAnimation,
            child: IconButton(
              icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white),
              onPressed: _onLike,
            ),
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            animation: _shareAnimation,
            child: IconButton(
              icon: const Icon(Icons.ios_share, color: Colors.white),
              onPressed: _onShare,
            ),
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            animation: _followAnimation,
            child: IconButton(
              icon: Icon(_isFollowing ? Icons.person_off : Icons.person_add,
                  color: Colors.white),
              onPressed: _onFollow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    Animation<double>? animation,
    required Widget child,
  }) {
    return ScaleTransition(
        scale: animation ?? const AlwaysStoppedAnimation(1.0), child: child);
  }

  Widget _buildDoubleTapArea() {
    return GestureDetector(
      onDoubleTap: _onLike,
      child: Container(color: Colors.transparent),
    );
  }
}

class VideoData {
  final String username;
  final String displayName;
  final String description;
  int likes;
  final int comments;
  final int shares;
  final bool isVerified;
  final String musicName;
  final List<String> hashtags;

  VideoData({
    required this.username,
    required this.displayName,
    required this.description,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isVerified,
    required this.musicName,
    required this.hashtags,
  });
}
