import 'package:flutter/material.dart';
import '../shared/widgets/index.dart';
import '../theme/design.dart';
import '../services/auth_service.dart';
import 'settings_screen.dart';
import 'dart:io';
import '../services/feed_service.dart';
import '../services/saved_service.dart';
import 'package:share_plus/share_plus.dart';
import '../app/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tab = 0;
  String _name = '@you';
  String? _bio;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _name = await AuthService().getUserName();
    _bio = await AuthService().getBio();
    _avatarPath = await AuthService().getAvatarPath();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 88),
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        colors: [AppDesign.secondary, AppDesign.primary]),
                    boxShadow: AppDesign.boxGlow,
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white24,
                    backgroundImage: (_avatarPath != null)
                        ? FileImage(File(_avatarPath!))
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 22)),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded,
                        color: Colors.lightBlueAccent, size: 18),
                  ],
                ),
                if ((_bio ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(_bio!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _metric('2.4M', 'Followers'),
                    _divider(),
                    _metric('189', 'Following'),
                    _divider(),
                    _metric('8.9M', 'Likes'),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppButton.primary(
                      label: 'Edit Profile',
                      icon: Icons.edit_rounded,
                      onPressed: () async {
                        await Navigator.of(context)
                            .pushNamed(RouteNames.editProfile);
                        _load();
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.share_rounded),
                      onPressed: () {
                        Share.share('Мой профиль в Shortsy: $_name');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded),
                      onPressed: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const SettingsScreen()));
                        _load();
                      },
                    )
                  ],
                ),
                const SizedBox(height: 12),
                _tabs(),
                const SizedBox(height: 12),
                _grid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x1412121A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDesign.boxGlow,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(radius: 28, backgroundColor: Colors.white24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Профиль',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                          color: Color(0x55000000),
                          blurRadius: 8,
                          offset: Offset(0, 2))
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text('@handle', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String value, String label) {
    return Column(children: [
      Text(value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ]);
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Container(width: 1, height: 22, color: Colors.white24),
      );

  Widget _tabs() {
    final items = ['Videos', 'Liked', 'Saved', 'Private'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(items.length, (i) {
          final selected = _tab == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => setState(() => _tab = i),
              borderRadius: BorderRadius.circular(18),
              child: Glass(
                borderRadius: BorderRadius.circular(18),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Text(
                  items[i],
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? AppDesign.primary : Colors.white),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _grid() {
    if (_tab == 2) {
      // Saved
      return FutureBuilder<Set<String>>(
        future: SavedService().getIds(),
        builder: (_, snap) {
          final ids = snap.data?.toList() ?? [];
          if (ids.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('Нет сохранённых клипов'),
            );
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemCount: ids.length,
            itemBuilder: (_, i) => FutureBuilder<Post?>(
              future: FeedService().getById(ids[i]),
              builder: (_, s) {
                final post = s.data;
                return InkWell(
                  onTap: post == null
                      ? null
                      : () => Navigator.of(context).pushNamed(
                            RouteNames.videoPost,
                            arguments: {'url': post.url},
                          ),
                  borderRadius: BorderRadius.circular(14),
                  child: Glass(
                    borderRadius: BorderRadius.circular(14),
                    padding: EdgeInsets.zero,
                    child: Container(color: Colors.white10),
                  ),
                );
              },
            ),
          );
        },
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: 12,
      itemBuilder: (_, i) => Glass(
        borderRadius: BorderRadius.circular(14),
        padding: EdgeInsets.zero,
        child: Container(color: Colors.white10),
      ),
    );
  }
}
