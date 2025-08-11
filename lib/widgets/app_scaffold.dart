import 'package:flutter/material.dart';
import '../theme/design.dart';
import 'animated_backdrop.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget child;
  const AppScaffold({super.key, this.title, this.actions, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppDesign.backgroundGradient),
            ),
          ),
          Positioned.fill(child: AnimatedBackdrop(speed: 28)),
          Positioned.fill(child: child),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppDesign.subtleVignette),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
