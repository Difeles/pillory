import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/app.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/domain/schedule.dart';

import '../support/fake_inventory_repository.dart';

void main() {
  late FakeInventoryRepository inventory;
  late FakeScheduleRepository schedules;

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    inventory = FakeInventoryRepository();
    schedules = FakeScheduleRepository(inventory);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryRepositoryProvider.overrideWithValue(inventory),
          scheduleRepositoryProvider.overrideWithValue(schedules),
        ],
        child: const PilloryApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
  }

  testWidgets('new medicine + daily schedule, mark taken once, stock drops', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('На этот день приёмов нет'), findsOneWidget);

    await tester.tap(find.byTooltip('Добавить приём'));
    await tester.pumpAndSettle();

    // Empty cabinet: a hint and a way to create the first medicine.
    expect(find.textContaining('В аптечке пока нет лекарств'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Дозировка за один приём'),
      '2',
    );
    await tester.tap(find.text('Новое лекарство'));
    await tester.pumpAndSettle();

    // The cabinet's own create screen opens.
    expect(find.text('Новое лекарство'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Название *'),
      'Аспирин',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Начальное количество'),
      '20',
    );
    await save(tester);

    // Back on the schedule form: the new medicine is selected and the dose
    // typed before leaving is intact.
    expect(find.text('Новый приём'), findsOneWidget);
    expect(find.text('Аспирин'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(
            find.widgetWithText(TextFormField, 'Дозировка за один приём'),
          )
          .controller!
          .text,
      '2',
    );
    await save(tester);

    // The tracker shows the intake: 2 шт. per intake, not the 20 in stock.
    expect(find.text('Аспирин'), findsOneWidget);
    expect(find.text('2 шт.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Принято'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Принято'), findsNothing);
    expect(find.text('Принято'), findsOneWidget);

    // The new medicine is in the cabinet with the deducted stock.
    await tab(tester, 'Аптечка');
    expect(find.text('Аспирин'), findsOneWidget);
    expect(find.text('18 шт.'), findsOneWidget);
  });

  testWidgets('weekday schedule for an existing medicine', (tester) async {
    await pumpApp(tester);
    await inventory.createMedicine(
      const NewMedicine(name: 'Нурофен', initialQuantity: 8, unit: 'шт.'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Добавить приём'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Лекарство *'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Нурофен').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('По дням'));
    await tester.pumpAndSettle();
    // No days chosen yet: refused.
    await save(tester);
    expect(find.text('Выберите дни недели'), findsOneWidget);

    final today = DateTime.now();
    const labels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    await tester.tap(find.text(labels[today.weekday - 1]));
    await tester.pumpAndSettle();
    await save(tester);

    expect(find.text('Нурофен'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Принято'), findsOneWidget);
  });

  testWidgets('cancelling new medicine keeps the typed schedule', (
    tester,
  ) async {
    await pumpApp(tester);
    await inventory.createMedicine(
      const NewMedicine(name: 'Нурофен', initialQuantity: 8, unit: 'шт.'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Добавить приём'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Лекарство *'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Нурофен').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Дозировка за один приём'),
      '3',
    );
    await tester.tap(find.text('По дням'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Вт'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Новое лекарство'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Нурофен'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(
            find.widgetWithText(TextFormField, 'Дозировка за один приём'),
          )
          .controller!
          .text,
      '3',
    );
    expect(
      tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Вт')).selected,
      isTrue,
    );
  });

  testWidgets('skip, undo and history show statuses', (tester) async {
    await pumpApp(tester);
    final id = await inventory.createMedicine(
      const NewMedicine(name: 'Аспирин', initialQuantity: 5, unit: 'шт.'),
    );
    await schedules.createSchedule(
      NewSchedule(
        medicineId: id,
        kind: ScheduleKind.daily,
        dose: 1,
        doseUnit: 'шт.',
        startDate: DateTime.now(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Пропустить'));
    await tester.pumpAndSettle();
    expect(find.text('Пропущено'), findsOneWidget);

    await tester.tap(find.byTooltip('Отменить отметку'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Принято'));
    await tester.pumpAndSettle();
    expect(find.text('Принято'), findsOneWidget);
    expect((await inventory.watchStock().first).single.totalQuantity, 4);

    await tester.tap(find.byTooltip('Отменить отметку'));
    await tester.pumpAndSettle();
    expect((await inventory.watchStock().first).single.totalQuantity, 5);
    expect(find.byTooltip('Пропустить'), findsOneWidget);

    await tester.tap(find.byTooltip('Пропустить'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('История'));
    await tester.pumpAndSettle();
    expect(find.text('Пропущено'), findsOneWidget);
    expect(find.textContaining('Аспирин'), findsOneWidget);
  });
}
