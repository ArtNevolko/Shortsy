import 'package:flutter/material.dart';
import '../theme/design.dart';

class GradientPill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final EdgeInsets padding;
  const GradientPill(
      {super.key,
      required this.text,
      this.icon,
      this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesign.radius),
        gradient:
            LinearGradient(colors: [AppDesign.secondary, AppDesign.primary]),
        boxShadow: const [
          BoxShadow(
              color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.black),
            const SizedBox(width: 6)
          ],
          Text(text,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
