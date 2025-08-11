import 'package:flutter/material.dart';
import '../theme/design.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool danger;
  final bool outlined;
  final EdgeInsets padding;
  final double radius;
  final Color? labelColor;
  final Color? iconColor;
  const AppButton.primary(
      {super.key,
      required this.label,
      this.onPressed,
      this.icon,
      this.danger = false,
      this.outlined = false,
      this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      this.radius = AppDesign.radius,
      this.labelColor,
      this.iconColor});

  const AppButton.secondary(
      {super.key,
      required this.label,
      this.onPressed,
      this.icon,
      this.danger = false,
      this.outlined = true,
      this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      this.radius = AppDesign.radius,
      this.labelColor,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final gradient =
        danger ? AppDesign.dangerGradient : AppDesign.buttonGradient;
    final lblColor =
        labelColor ?? (outlined ? AppDesign.primary : Colors.white);
    final icColor = iconColor ?? (outlined ? AppDesign.primary : Colors.white);

    final childRow = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: icColor),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: lblColor,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );

    if (outlined) {
      return Opacity(
        opacity: enabled ? 1 : 0.5,
        child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: enabled ? onPressed : null,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                    color: AppDesign.primary.withValues(alpha: 0.6),
                    width: 1.4),
              ),
              child: childRow,
            )),
      );
    }

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: enabled ? onPressed : null,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: gradient,
            boxShadow: const [
              BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 16,
                  offset: Offset(0, 6))
            ],
          ),
          child: Padding(
            padding: padding,
            child: childRow,
          ),
        ),
      ),
    );
  }
}
