import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/auth_service.dart';
import '../services/feed_service.dart';
import '../services/follow_service.dart';
import '../services/saved_service.dart';
import '../shared/services/ui_prefs.dart';
import 'edit_profile_screen.dart';
import 'privacy_screen.dart';
import '../shared/widgets/index.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Future<void> _resetOnboarding(BuildContext context) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('onboarding_done', false);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Онбординг будет показан снова')));
    }
  }

  Future<void> _about(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    showAboutDialog(
      context: context,
      applicationName: info.appName,
      applicationVersion: info.version,
      children: [
        const Text('Shortsy — демо версия 1.0. Видео, сообщения, профиль.'),
        TextButton(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
          child: const Text('Политика конфиденциальности'),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    return AppScaffold(
      title: 'Настройки',
      child: ListView(
        padding: const EdgeInsets.only(top: 0),
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6_rounded),
            title: const Text('Тема приложения'),
            subtitle: Text(isLight ? 'Светлая' : 'Тёмная'),
            trailing: Switch(
              value: isLight,
              onChanged: (v) => _ThemeSwitcher.of(context).toggle(),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Редактировать профиль'),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.settings_applications_rounded),
            title: const Text('Системные настройки приложения'),
            onTap: openAppSettings,
          ),
          ListTile(
            leading: const Icon(Icons.replay_rounded),
            title: const Text('Показать онбординг снова'),
            onTap: () => _resetOnboarding(context),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('О приложении'),
            onTap: () => _about(context),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Политика конфиденциальности'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_rounded),
            title: const Text('Сбросить лайки'),
            onTap: () async {
              await FeedService().resetLikes();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Лайки сброшены')));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh_rounded),
            title: const Text('Перегенерировать фид'),
            onTap: () async {
              await FeedService().resetFeed();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Фид обновлён')));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_remove_rounded),
            title: const Text('Очистить подписки'),
            onTap: () async {
              await FollowService().reset();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Подписки очищены')));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_remove_rounded),
            title: const Text('Очистить сохранённые'),
            onTap: () async {
              await SavedService().clear();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Сохранённые очищены')));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded),
            title: const Text('Очистить все данные (кроме темы)'),
            onTap: () async {
              final p = await SharedPreferences.getInstance();
              final theme = p.getBool('theme_light');
              await p.clear();
              if (theme != null) await p.setBool('theme_light', theme);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Данные очищены')));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Выйти'),
            onTap: () async {
              await AuthService().signOut();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          SwitchListTile(
            title: const Text('Анимированный фон'),
            value: UiPrefs().animatedBackdrop.value,
            onChanged: (v) => UiPrefs().setAnimatedBackdrop(v),
          ),
        ],
      ),
    );
  }
}

class _ThemeSwitcher extends InheritedWidget {
  const _ThemeSwitcher({
    required this.toggle,
    required super.child,
  });

  final VoidCallback toggle;

  static _ThemeSwitcher of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<_ThemeSwitcher>();
    assert(result != null, 'No _ThemeSwitcher found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant _ThemeSwitcher oldWidget) => false;
}
