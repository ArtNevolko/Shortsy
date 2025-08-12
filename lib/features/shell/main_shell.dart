import 'package:flutter/material.dart';
import '../feed/home_feed_screen.dart' as f;
import '../discover/discover_screen.dart' as d;
import '../create/create_screen.dart' as c;
import '../inbox/inbox_screen.dart' as i;
import '../profile/profile_screen.dart' as p;

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _pages = const [
    f.HomeFeedScreen(),
    d.DiscoverScreen(),
    c.CreateScreen(),
    i.InboxScreen(),
    p.ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_filled), label: 'Лента'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Поиск'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: 'Создать'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Почта'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
