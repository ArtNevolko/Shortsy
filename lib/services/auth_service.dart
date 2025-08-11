import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _i = AuthService._();
  AuthService._();
  factory AuthService() => _i;

  static const _kUserName = 'auth_username';
  static const _kBio = 'profile_bio';
  static const _kLink = 'profile_link';
  static const _kAvatarPath = 'profile_avatar_path';

  Future<bool> isSignedIn() async {
    final p = await SharedPreferences.getInstance();
    return (p.getString(_kUserName) ?? '').isNotEmpty;
  }

  Future<void> signIn(String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUserName, name.trim());
  }

  Future<void> signOut() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kUserName);
  }

  Future<String> getUserName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kUserName) ?? '@you';
  }

  Future<void> saveProfile(
      {required String name,
      String? bio,
      String? link,
      String? avatarPath}) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUserName, name.trim());
    if (bio != null) await p.setString(_kBio, bio);
    if (link != null) await p.setString(_kLink, link);
    if (avatarPath != null) await p.setString(_kAvatarPath, avatarPath);
  }

  Future<String?> getBio() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kBio);
  }

  Future<String?> getLink() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kLink);
  }

  Future<String?> getAvatarPath() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kAvatarPath);
  }
}
