import 'package:flutter/material.dart';

class AvatarPresence extends StatelessWidget {
  final Color color;
  final String label;
  final bool online;
  const AvatarPresence(
      {super.key,
      required this.color,
      required this.label,
      this.online = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.8),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 14)
            ],
          ),
          child: Stack(
            children: [
              const Center(child: Icon(Icons.person, color: Colors.white)),
              if (online)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        color: Colors.limeAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.limeAccent.withValues(alpha: 0.6),
                              blurRadius: 8)
                        ]),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
