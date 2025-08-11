import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/widgets/index.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _index = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [
      _Slide(
          title: 'Добро пожаловать в Shortsy',
          subtitle: 'Создавайте и смотрите короткие видео'),
      _Slide(
          title: 'Лайв и сообщения',
          subtitle: 'Общайтесь и выходите в прямые эфиры'),
      _Slide(
          title: 'Глассморфизм',
          subtitle: 'Современный плавный UI, который радует'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/branding/logo.png',
                  width: MediaQuery.of(context).size.width * 0.6,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: PageView.builder(
                controller: _pc,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: pages.length,
                itemBuilder: (_, i) => pages[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          pages.length,
                          (i) => Container(
                                width: 8,
                                height: 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i == _index
                                      ? Colors.white
                                      : Colors.white24,
                                ),
                              )),
                    ),
                  ),
                  InkWell(
                    onTap: _index == pages.length - 1
                        ? _finish
                        : () => _pc.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut),
                    borderRadius: BorderRadius.circular(22),
                    child: Glass(
                      borderRadius: BorderRadius.circular(22),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child:
                          Text(_index == pages.length - 1 ? 'Готово' : 'Далее'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final String title;
  final String subtitle;
  const _Slide({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
