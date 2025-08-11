import 'package:flutter/material.dart';

class GlassHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  const GlassHeader({super.key, required this.title, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xCC12121A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          ...actions.map((w) =>
              Padding(padding: const EdgeInsets.only(left: 8), child: w)),
        ],
      ),
    );
  }
}
