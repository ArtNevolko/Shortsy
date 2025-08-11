import 'package:flutter/material.dart';

class AREffects extends StatelessWidget {
  final bool haze;
  final bool lightBeams;
  final bool pulse;
  final Widget child;
  const AREffects(
      {super.key,
      required this.child,
      this.haze = true,
      this.lightBeams = true,
      this.pulse = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        if (haze)
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x22B39DDB), Color(0x00000000)],
                  ),
                ),
              ),
            ),
          ),
        if (lightBeams)
          Positioned(
            left: 24,
            top: 80,
            right: 24,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.35,
                child: Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(120)),
                  ),
                ),
              ),
            ),
          ),
        if (pulse)
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0x11FFFFFF), Color(0x00000000)],
                    radius: 1.0,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
