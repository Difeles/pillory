import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/app.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/design_system/theme.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/domain/schedule.dart';
import 'package:pillory/features/inventory/inventory_screen.dart';
import 'package:pillory/features/inventory/medicine_screen.dart';
import 'package:pillory/features/profile/profile_screen.dart';
import 'package:pillory/features/today/today_screen.dart';

import '../support/fake_inventory_repository.dart';

/// Each main screen at the narrowest supported width with doubled system
/// text: any RenderFlex overflow fails the test. Screens are pumped alone
/// because the shell keeps every tab laid out at once.
void main() {
  late FakeInventoryRepository inventory;
  late FakeScheduleRepository schedules;
  late String medicineId;

  Future<void> pumpSmall(WidgetTester tester, Widget app) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    inventory = FakeInventoryRepository();
    schedules = FakeScheduleRepository(inventory);
    medicineId = await inventory.createMedicine(
      NewMedicine(
        name: 'Ибупрофен форте',
        strength: '400 мг',
        initialQuantity: 2,
        unit: 'шт.',
        expiresOn: DateTime.now().add(const Duration(days: 7)),
      ),
    );
    await schedules.createSchedule(
      NewSchedule(
        medicineId: medicineId,
        kind: ScheduleKind.daily,
        dose: 1,
        doseUnit: 'шт.',
        startDate: DateTime.now(),
        times: const [9 * 60],
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryRepositoryProvider.overrideWithValue(inventory),
          scheduleRepositoryProvider.overrideWithValue(schedules),
        ],
        child: app,
      ),
    );
    await tester.pumpAndSettle();
  }

  Widget screen(Widget Function() build) => MaterialApp(
    theme: buildAppTheme(),
    home: Builder(builder: (_) => build()),
  );

  testWidgets('Today fits', (tester) async {
    await pumpSmall(tester, screen(() => const TodayScreen()));
    expect(find.text('Ибупрофен форте'), findsOneWidget);
  });

  testWidgets('Today fits after a mark, actions stay reachable', (
    tester,
  ) async {
    await pumpSmall(tester, screen(() => const TodayScreen()));
    final take = find.widgetWithText(FilledButton, 'Принято');
    await tester.ensureVisible(take);
    await tester.pumpAndSettle();
    await tester.tap(take);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Принято'), findsNothing);
    expect(find.text('Принято'), findsOneWidget); // the status badge
    for (final tooltip in ['Отменить отметку', 'Управление расписанием']) {
      final action = find.byTooltip(tooltip);
      await tester.ensureVisible(action);
      await tester.pumpAndSettle();
      expect(action.hitTestable(), findsOneWidget, reason: tooltip);
    }

    // Undo works from the narrow layout too.
    await tester.tap(find.byTooltip('Отменить отметку'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Принято'), findsOneWidget);
  });

  testWidgets('Cabinet fits', (tester) async {
    await pumpSmall(tester, screen(() => const InventoryScreen()));
    expect(find.text('Ибупрофен форте'), findsOneWidget);
  });

  testWidgets('Whole app with navigation fits', (tester) async {
    await pumpSmall(tester, const PilloryApp());
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Cabinet: an empty filter offers to show all', (tester) async {
    await pumpSmall(tester, screen(() => const InventoryScreen()));
    final expired = find.widgetWithText(ChoiceChip, 'Просрочено');
    await tester.ensureVisible(expired);
    await tester.tap(expired);
    await tester.pumpAndSettle();
    expect(find.text('Нет лекарств с таким статусом'), findsOneWidget);

    // Below the fold at ×2; the empty state scrolls to it.
    await tester.ensureVisible(find.text('Показать все'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Показать все'));
    await tester.pumpAndSettle();
    expect(find.text('Ибупрофен форте'), findsOneWidget);
  });

  testWidgets('Cabinet: a card with two packages fits, without ±', (
    tester,
  ) async {
    await pumpSmall(tester, screen(() => const InventoryScreen()));
    await inventory.addPackage(
      medicineId: medicineId,
      quantity: 10,
      unit: 'шт.',
      expiresOn: null,
    );
    await tester.pumpAndSettle();
    expect(find.text('12 шт.'), findsOneWidget);
    expect(find.byTooltip('Уменьшить остаток'), findsNothing);
  });

  testWidgets('Archive fits', (tester) async {
    await pumpSmall(tester, screen(() => const InventoryScreen()));
    await inventory.archiveMedicine(medicineId);
    await tester.tap(find.byTooltip('Архив'));
    await tester.pumpAndSettle();
    expect(find.text('Ибупрофен форте'), findsOneWidget);
    expect(find.byTooltip('Уменьшить остаток'), findsNothing);
  });

  testWidgets('Medicine screen fits', (tester) async {
    await pumpSmall(
      tester,
      screen(() => MedicineScreen(medicineId: medicineId)),
    );
    expect(find.text('Упаковки'), findsOneWidget);
  });

  testWidgets('Medicine screen with mixed packages, archived, fits', (
    tester,
  ) async {
    await pumpSmall(
      tester,
      screen(() => MedicineScreen(medicineId: medicineId)),
    );
    await inventory.addPackage(
      medicineId: medicineId,
      quantity: 4,
      unit: 'шт.',
      expiresOn: DateTime(2000, 1, 1),
    );
    await inventory.addPackage(
      medicineId: medicineId,
      quantity: 50,
      unit: 'мл',
    );
    await inventory.archiveMedicine(medicineId);
    await tester.pumpAndSettle();
    expect(find.text('В архиве'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('50 мл'), 100);
    expect(find.byTooltip('Упаковка').hitTestable(), findsWidgets);
  });

  testWidgets('Profile fits', (tester) async {
    await pumpSmall(tester, screen(() => const ProfileScreen()));
    // Below the fold at ×2: it must still be reachable by scrolling.
    await tester.scrollUntilVisible(find.text('Восстановить из копии'), 100);
    expect(find.text('Восстановить из копии'), findsOneWidget);
  });
}
