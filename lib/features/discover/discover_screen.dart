import 'package:flutter/material.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildGrid()),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Tab(
                        text: 'Все',
                        active: _tab == 0,
                        onTap: () => setState(() => _tab = 0)),
                    const SizedBox(width: 6),
                    _Tab(
                        text: 'Музыка',
                        active: _tab == 1,
                        onTap: () => setState(() => _tab = 1)),
                    const SizedBox(width: 6),
                    _Tab(
                        text: 'Танцы',
                        active: _tab == 2,
                        onTap: () => setState(() => _tab = 2)),
                    const SizedBox(width: 6),
                    _Tab(
                        text: 'Игры',
                        active: _tab == 3,
                        onTap: () => setState(() => _tab = 3)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 64, 8, 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 9 / 16,
      ),
      itemCount: 30,
      itemBuilder: (context, i) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.network(
                  'https://picsum.photos/seed/${_tab}_$i/300/600',
                  fit: BoxFit.cover,
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [Color(0xAA000000), Color(0x00000000)],
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: 6,
                right: 6,
                bottom: 6,
                child: Text(
                  '#trend',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tab extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.text, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.black : Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
