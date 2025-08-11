import 'dart:math' as math;
import 'package:flutter/material.dart';

class ReactionsOverlay extends StatefulWidget {
  final bool active;
  const ReactionsOverlay({super.key, required this.active});
  @override
  ReactionsOverlayState createState() => ReactionsOverlayState();
}

class ReactionsOverlayState extends State<ReactionsOverlay>
    with TickerProviderStateMixin {
  final List<_Bubble> _bubbles = [];

  void add(String emoji) {
    final ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    final bubble =
        _Bubble(emoji: emoji, ctrl: ctrl, dx: math.Random().nextDouble());
    setState(() => _bubbles.add(bubble));
    ctrl.forward().whenComplete(() => setState(() => _bubbles.remove(bubble)));
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Stack(children: _bubbles.map((b) => _BubbleWidget(b: b)).toList()),
    );
  }
}

class _Bubble {
  final String emoji;
  final AnimationController ctrl;
  final double dx; // 0..1
  _Bubble({required this.emoji, required this.ctrl, required this.dx});
}

class _BubbleWidget extends StatelessWidget {
  final _Bubble b;
  const _BubbleWidget({required this.b});
  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
        parent: b.ctrl, curve: const Interval(0.0, 0.8, curve: Curves.easeOut));
    final up = CurvedAnimation(parent: b.ctrl, curve: Curves.easeOutCubic);
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: b.ctrl,
        builder: (_, __) {
          final y = 1.0 - up.value;
          return Opacity(
            opacity: fade.value,
            child: Transform.translate(
              offset: Offset((b.dx - 0.5) * 120, y * 220),
              child: Align(
                alignment: Alignment(lerpDouble(-0.8, 0.8, b.dx)!, 1.0),
                child: Text(b.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
          );
        },
      ),
    );
  }

  double? lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
