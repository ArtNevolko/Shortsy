import 'package:flutter/material.dart';

class Glass extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;
  final double opacity;
  final Gradient? borderGradient;
  final Color? tint;
  final double borderWidth;

  const Glass({
    super.key,
    this.child,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.opacity = 0.10,
    this.borderGradient,
    this.tint,
    this.borderWidth = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: (tint ?? const Color(0xFF12121A)).withValues(alpha: 0.85),
        borderRadius: borderRadius,
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.06), width: borderWidth),
        boxShadow: const [
          BoxShadow(
              color: Color(0x11000000), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}
