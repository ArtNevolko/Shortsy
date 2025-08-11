import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedBackground extends StatelessWidget {
  final double t;

  const AnimatedBackground({Key? key, required this.t}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(math.cos(t) * 0.7, math.sin(t) * 0.7),
          end: Alignment(-math.cos(t) * 0.7, -math.sin(t) * 0.7),
          colors: const [
            Color(0x1A7C3AED), // mystic violet veil
            Color(0x3354517A), // muted lavender smoke
            Color(0x1ABFC7CC), // silver gray mist
          ],
        ),
      ),
    );
  }
}
