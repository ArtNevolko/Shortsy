import 'package:flutter/material.dart';
import 'shared/theme/index.dart';
import 'shared/widgets/index.dart';
import 'features/feed/index.dart';
import 'features/discover/index.dart';
import 'features/create/index.dart';
import 'features/inbox/index.dart';
import 'features/profile/index.dart';
import 'features/auth/index.dart';
import 'screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/routes.dart';
import 'shared/services/theme_service.dart';
import 'shared/widgets/theme_switcher.dart';
import 'shared/services/ui_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService().init();
  await UiPrefs().init();
  runApp(const ThemeSwitcher(child: ShortsyApp()));
}

class ShortsyApp extends StatelessWidget {
  const ShortsyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().listenable,
      builder: (context, isLight, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shortsy',
          theme: AppDesign.lightTheme(),
          darkTheme: AppDesign.darkTheme(),
          themeMode: isLight ? ThemeMode.light : ThemeMode.dark,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          home: const _MainShell(),
        );
      },
    );
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _index = 0;
  bool _onboardingChecked = false;
  bool _showOnboarding = false;
  bool _authChecked = false;
  bool _needAuth = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    _onboardingChecked = true;
    _showOnboarding = !done;
    if (!mounted) return;
    setState(() {});
    if (done) {
      _checkAuth();
    }
  }

  Future<void> _checkAuth() async {
    final need = !(await AuthService().isSignedIn());
    if (!mounted) return;
    setState(() {
      _authChecked = true;
      _needAuth = need;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_onboardingChecked) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_showOnboarding) {
      return OnboardingScreen(onDone: () async {
        setState(() {
          _showOnboarding = false;
        });
        await _checkAuth();
      });
    }
    if (!_authChecked) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_needAuth) {
      return SignInScreen(onSignedIn: () => setState(() => _needAuth = false));
    }
    final b = Theme.of(context).brightness;
    final bg = AppDesign.backgroundGradientFor(b);
    final vig = AppDesign.subtleVignetteFor(b);
    return ValueListenableBuilder<bool>(
      valueListenable: UiPrefs().animatedBackdrop,
      builder: (_, anim, __) {
        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              Positioned.fill(
                  child: DecoratedBox(decoration: BoxDecoration(gradient: bg))),
              if (anim)
                const Positioned.fill(child: AnimatedBackdrop(speed: 28)),
              Positioned.fill(child: _buildPage(_index)),
              Positioned.fill(
                  child: IgnorePointer(
                      child: DecoratedBox(
                          decoration: BoxDecoration(gradient: vig)))),
            ],
          ),
          bottomNavigationBar: GlassNavBar(
              currentIndex: _index, onTap: (i) => setState(() => _index = i)),
        );
      },
    );
  }

  Widget _buildPage(int i) {
    switch (i) {
      case 0:
        return HomeFeedScreen();
      case 1:
        return DiscoverScreen();
      case 2:
        return CreateScreen();
      case 3:
        return InboxScreen();
      case 4:
      default:
        return ProfileScreen();
    }
  }
}
