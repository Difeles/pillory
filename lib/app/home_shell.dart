import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/widgets/floating_dock.dart';
import '../features/inventory/inventory_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/shopping/shopping_screen.dart';
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
    return Scaffold(
      // IndexedStack keeps each tab's state (scroll position) when switching.
      body: IndexedStack(
        index: _index,
        children: [
          const TodayScreen(),
          InventoryScreen(active: _index == 1),
          const ShoppingScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: FloatingDock(
        index: _index,
        onSelected: (i) => setState(() => _index = i),
        items: const [
          DockItem(Icons.schedule_outlined, Icons.schedule, 'Приём'),
          DockItem(
            Icons.medical_services_outlined,
            Icons.medical_services,
            'Аптечка',
          ),
          DockItem(Icons.shopping_bag_outlined, Icons.shopping_bag, 'Покупки'),
          DockItem(Icons.face_outlined, Icons.face, 'Профиль'),
        ],
      ),
    );
  }
}
