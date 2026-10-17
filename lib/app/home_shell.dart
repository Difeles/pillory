import 'package:flutter/material.dart';

import '../features/inventory/inventory_screen.dart';
import '../features/placeholder_screen.dart';
import '../features/today/today_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    // IndexedStack keeps each tab's state (scroll position) when switching.
    body: IndexedStack(
      index: _index,
      children: [
        const TodayScreen(),
        const InventoryScreen(),
        const PlaceholderScreen(
          title: 'Покупки',
          icon: Icons.shopping_basket_outlined,
        ),
        const PlaceholderScreen(title: 'Профиль', icon: Icons.person_outline),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.today_outlined), label: 'Приём'),
        NavigationDestination(
          icon: Icon(Icons.medication_outlined),
          label: 'Аптечка',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_basket_outlined),
          label: 'Покупки',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Профиль',
        ),
      ],
    ),
  );
}
