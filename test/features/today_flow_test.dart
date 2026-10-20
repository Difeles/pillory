import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/design_system/widgets/week_strip.dart';
import 'package:pillory/design_system/widgets/floating_dock.dart';
import 'package:pillory/app/app.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/design_system/widgets/app_card.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/domain/reminders.dart';
import 'package:pillory/domain/schedule.dart';
import 'package:pillory/features/today/today_providers.dart';

import '../support/fake_extras_repository.dart';
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
          extrasRepositoryProvider.overrideWithValue(FakeExtrasRepository()),
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
        of: find.byType(FloatingDock),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    final label = [
      'Сохранить приём',
      'Добавить в аптечку',
      'Сохранить',
    ].firstWhere((l) => find.text(l).evaluate().isNotEmpty);
    await tester.tap(find.text(label));
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
    expect(find.widgetWithText(ChoiceChip, 'Аспирин'), findsOneWidget);
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

    await tester.tap(find.widgetWithText(FilledButton, 'Принять'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Принять'), findsNothing);
    expect(find.byTooltip('Отменить отметку'), findsOneWidget);

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
    await tester.tap(find.text('Нурофен'));
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
    expect(find.widgetWithText(FilledButton, 'Принять'), findsOneWidget);
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

    await tester.tap(find.text('Нурофен'));
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

    expect(find.widgetWithText(ChoiceChip, 'Нурофен'), findsOneWidget);
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

    await tester.tap(find.text('Пропустить'));
    await tester.pumpAndSettle();
    expect(find.text('Пропущено'), findsOneWidget);

    await tester.tap(find.byTooltip('Отменить отметку'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Принять'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Отменить отметку'), findsOneWidget);
    expect((await inventory.watchStock().first).single.totalQuantity, 4);

    await tester.tap(find.byTooltip('Отменить отметку'));
    await tester.pumpAndSettle();
    expect((await inventory.watchStock().first).single.totalQuantity, 5);
    expect(find.text('Пропустить'), findsOneWidget);

    await tester.tap(find.text('Пропустить'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('История'));
    await tester.pumpAndSettle();
    expect(find.text('Пропущено'), findsOneWidget);
    expect(find.textContaining('Аспирин'), findsOneWidget);
  });

  testWidgets('a tapped reminder opens its intake on the intake tab', (
    tester,
  ) async {
    await pumpApp(tester);
    final id = await inventory.createMedicine(
      const NewMedicine(name: 'Аспирин', initialQuantity: 5, unit: 'шт.'),
    );
    final sid = await schedules.createSchedule(
      NewSchedule(
        medicineId: id,
        kind: ScheduleKind.daily,
        dose: 1,
        doseUnit: 'шт.',
        startDate: DateTime.now(),
        times: const [8 * 60],
      ),
    );
    await tab(tester, 'Аптечка');

    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day + 2);
    ProviderScope.containerOf(tester.element(find.byType(FloatingDock)))
        .read(openIntakeProvider.notifier)
        .open(
          OpenIntakeRequest(scheduleId: sid, day: day, minuteOfDay: 8 * 60),
        );
    await tester.pumpAndSettle();

    expect(find.textContaining('08:00'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is AppCard && w.variant == AppCardVariant.highlighted,
      ),
      findsOneWidget,
    );
  });

  group('managing a schedule', () {
    Future<void> setUpStarted(WidgetTester tester) async {
      await pumpApp(tester);
      final id = await inventory.createMedicine(
        const NewMedicine(name: 'Аспирин', initialQuantity: 9, unit: 'шт.'),
      );
      final now = DateTime.now();
      await schedules.createSchedule(
        NewSchedule(
          medicineId: id,
          kind: ScheduleKind.daily,
          dose: 1,
          doseUnit: 'шт.',
          startDate: DateTime(now.year, now.month, now.day - 3),
        ),
      );
      await tester.pumpAndSettle();
    }

    /// Selects yesterday on the week strip, swiping to last week on a Monday.
    Future<void> yesterday(WidgetTester tester) async {
      final now = DateTime.now();
      final y = DateTime(now.year, now.month, now.day - 1);
      Finder cell() => find.descendant(
        of: find.byType(WeekStrip),
        matching: find.text('${y.day}'),
      );
      if (now.weekday == DateTime.monday) {
        await tester.fling(find.byType(WeekStrip), const Offset(300, 0), 1000);
        await tester.pumpAndSettle();
      }
      await tester.tap(cell());
      await tester.pumpAndSettle();
    }

    Future<void> menu(WidgetTester tester, String item) async {
      await tester.tap(find.byTooltip('Управление расписанием'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(item));
      await tester.pumpAndSettle();
    }

    testWidgets('changing the dose applies from today, yesterday stays', (
      tester,
    ) async {
      await setUpStarted(tester);
      expect(find.text('1 шт.'), findsOneWidget);

      await menu(tester, 'Изменить расписание');
      expect(find.text('Расписание'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Дозировка за один приём'),
        '3',
      );
      await save(tester);
      expect(find.text('3 шт.'), findsOneWidget);

      await yesterday(tester);
      expect(find.text('1 шт.'), findsOneWidget);
      // The earlier version offers no way to edit, only a reason.
      await tester.tap(find.byTooltip('Управление расписанием'));
      await tester.pumpAndSettle();
      expect(
        find.text('Расписание уже изменено или завершено'),
        findsOneWidget,
      );
      expect(find.text('Изменить расписание'), findsNothing);
      expect(find.text('Завершить расписание'), findsNothing);
    });

    testWidgets('ending asks first and keeps the past', (tester) async {
      await setUpStarted(tester);

      await menu(tester, 'Завершить расписание');
      expect(find.text('Завершить расписание?'), findsOneWidget);
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      expect(find.text('1 шт.'), findsOneWidget);

      await menu(tester, 'Завершить расписание');
      await tester.tap(find.text('Завершить'));
      await tester.pumpAndSettle();
      expect(find.text('На этот день приёмов нет'), findsOneWidget);

      await yesterday(tester);
      expect(find.text('1 шт.'), findsOneWidget);
    });

    testWidgets('the medicine cannot be changed while editing', (tester) async {
      await setUpStarted(tester);
      await menu(tester, 'Изменить расписание');
      expect(find.text('Новое лекарство'), findsNothing);
      final chip = tester.widget<ChoiceChip>(find.byType(ChoiceChip));
      expect(chip.onSelected, isNull);
    });
  });

  testWidgets('a schedule cannot be saved without a medicine', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Добавить приём'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить приём'));
    await tester.pumpAndSettle();
    expect(find.text('Сначала создайте лекарство'), findsOneWidget);
    expect(find.text('Сохранить приём'), findsOneWidget); // still on the form

    await inventory.createMedicine(
      const NewMedicine(name: 'Нурофен', initialQuantity: 8, unit: 'шт.'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить приём'));
    await tester.pumpAndSettle();
    expect(find.text('Выберите лекарство'), findsWidgets);
    expect(find.text('Сохранить приём'), findsOneWidget);
  });
}
