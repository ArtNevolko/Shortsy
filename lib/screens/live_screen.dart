import 'package:flutter/material.dart';
import '../shared/widgets/index.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  bool _live = false;
  int _viewers = 0;

  void _toggle() {
    setState(() {
      _live = !_live;
      _viewers = _live ? 128 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.black)),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GlassHeader(title: 'Прямой эфир'),
            ),
            Positioned(
              top: 72,
              right: 16,
              child: Glass(
                borderRadius: BorderRadius.circular(18),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(children: [
                  const Icon(Icons.visibility_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text('$_viewers')
                ]),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: AppButton.primary(
                    label: _live ? 'Завершить эфир' : 'Начать эфир',
                    icon: _live ? Icons.stop_rounded : Icons.wifi_tethering,
                    danger: _live,
                    onPressed: _toggle,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
