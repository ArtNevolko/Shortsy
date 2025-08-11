import 'package:flutter/material.dart';

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const GlassNavBar(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xEE12121A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.06), width: 1.2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 6))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _item(icon: Icons.home_rounded, i: 0),
            _item(icon: Icons.search_rounded, i: 1),
            _item(icon: Icons.add_rounded, i: 2, isAccent: true),
            _item(icon: Icons.chat_bubble_rounded, i: 3),
            _item(icon: Icons.person_rounded, i: 4),
          ],
        ),
      ),
    );
  }

  Widget _item(
      {required IconData icon, required int i, bool isAccent = false}) {
    final bool active = currentIndex == i;
    final Color color = active ? Colors.white : Colors.white70;
    final double size = isAccent ? 26 : 22;
    return InkResponse(
      onTap: () => onTap(i),
      radius: 28,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: isAccent
            ? BoxDecoration(
                color: const Color(0xFF5B43D6),
                borderRadius: BorderRadius.circular(14))
            : null,
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}
