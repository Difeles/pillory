import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/inventory/inventory_screen.dart';
import '../features/placeholder_screen.dart';
import '../features/today/today_providers.dart';
import '../features/today/today_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // A tapped reminder shows the intake tab (the day screen picks the intake).
    ref.listen(openIntakeProvider, (_, request) {
      if (request != null) setState(() => _index = 0);
    });
    return _scaffold();
  }

  Widget _scaffold() => Scaffold(
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
