import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedBackdrop extends StatefulWidget {
  final double speed;
  const AnimatedBackdrop({super.key, this.speed = 20});
  @override
  State<AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<AnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: Duration(seconds: widget.speed.toInt()))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value * 2 * math.pi;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(math.cos(t) * 0.6, math.sin(t) * 0.6),
              end: Alignment(-math.cos(t) * 0.6, -math.sin(t) * 0.6),
              colors: const [
                Color(0x332BA1FF),
                Color(0x3315C9B8),
                Color(0x3321D4FD),
              ],
            ),
          ),
        );
      },
    );
  }
}
