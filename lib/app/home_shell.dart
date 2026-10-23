import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/motion.dart';
import '../l10n/l10n.dart';
import '../domain/extras.dart';
import '../domain/inventory_rules.dart';
import '../features/inventory/inventory_providers.dart';
import '../features/onboarding/onboarding_screen.dart';
import 'providers.dart';
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

class _HomeShellState extends ConsumerState<HomeShell>
    with WidgetsBindingObserver {
  int _index = 0;
  DateTime _day = dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // These read "today" once when they are created: after midnight they are
  // rebuilt for the new day.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final today = dateOnly(DateTime.now());
    if (state != AppLifecycleState.resumed || today == _day) return;
    _day = today;
    ref
      ..invalidate(historyProvider)
      ..invalidate(endingCoursesProvider)
      ..invalidate(activeSchedulesProvider);
  }

  @override
  Widget build(BuildContext context) {
    // A tapped reminder shows the intake tab (the day screen picks the intake).
    ref.listen(openIntakeProvider, (_, request) {
      if (request != null) setState(() => _index = 0);
    });
    final prefs = ref.watch(prefsProvider).value;
    final stock = ref.watch(medicineStockProvider).value;
    if (prefs != null && stock != null && !prefs.onboarded) {
      // A cabinet that already has data is not a first launch.
      if (stock.isNotEmpty) {
        ref.read(extrasRepositoryProvider).setPref(PrefKey.onboarded, 'true');
      } else {
        return const OnboardingScreen();
      }
    }
    return Scaffold(
      // The dock is glass: the tabs scroll underneath it.
      extendBody: true,
      // Keeps each tab's state (scroll position) and glides between them.
      body: TabStack(
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
        items: [
          DockItem(
            Icons.schedule_outlined,
            Icons.schedule,
            context.l10n.tabToday,
          ),
          DockItem(
            Icons.medical_services_outlined,
            Icons.medical_services,
            context.l10n.tabCabinet,
          ),
          DockItem(
            Icons.shopping_bag_outlined,
            Icons.shopping_bag,
            context.l10n.tabShopping,
          ),
          DockItem(Icons.face_outlined, Icons.face, context.l10n.tabProfile),
        ],
      ),
    );
  }
}
