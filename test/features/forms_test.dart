import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/design_system/widgets/floating_dock.dart';
import 'package:pillory/app/app.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/design_system/widgets/date_field.dart';
import 'package:pillory/domain/inventory_rules.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/domain/schedule.dart';

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

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    if (finder.evaluate().isNotEmpty) await tester.ensureVisible(finder.first);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> openCabinet(WidgetTester tester) => tap(
    tester,
    find.descendant(
      of: find.byType(FloatingDock),
      matching: find.text('Аптечка'),
    ),
  );

  group('medicine form', () {
    testWidgets('saves unit, expiry and threshold from the stock section', (
      tester,
    ) async {
      await pumpApp(tester);
      await openCabinet(tester);
      await tap(tester, find.text('Добавить лекарство'));
      expect(find.text('Основное'), findsOneWidget);
      expect(find.text('Запас'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Название *'),
        'Сироп',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Начальное количество'),
        '100',
      );
      await tap(tester, find.text('мл'));
      await tap(tester, find.byType(DateField));
      await tap(tester, find.text('Готово')); // today, the picker's default
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Порог низкого остатка (необязательно)',
        ),
        '20',
      );
      await tap(tester, find.text('Добавить в аптечку'));

      final stock = (await inventory.watchStock().first).single;
      expect(stock.medicine.name, 'Сироп');
      expect(stock.unit, 'мл');
      expect(stock.totalQuantity, 100);
      expect(stock.medicine.lowStockThreshold, 20);
      expect(stock.nearestExpiry, dateOnly(DateTime.now()));
    });

    testWidgets('errors are spelled out, not only coloured', (tester) async {
      await pumpApp(tester);
      await openCabinet(tester);
      await tap(tester, find.text('Добавить лекарство'));
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Начальное количество'),
        '-1',
      );
      await tap(tester, find.text('Добавить в аптечку'));

      expect(find.text('Введите название'), findsOneWidget);
      expect(find.text('Введите число 0 или больше'), findsOneWidget);
      expect(await inventory.watchStock().first, isEmpty);
    });

    testWidgets('editing offers no package fields', (tester) async {
      await pumpApp(tester);
      await inventory.createMedicine(
        const NewMedicine(name: 'Аспирин', initialQuantity: 5, unit: 'шт.'),
      );
      await openCabinet(tester);
      await tap(tester, find.text('Аспирин'));
      await tap(tester, find.byTooltip('Лекарство'));
      await tap(tester, find.text('Изменить'));

      expect(find.text('Запас'), findsOneWidget); // the threshold stays
      expect(find.text('Начальное количество'), findsNothing);
      expect(find.text('Единица'), findsNothing);
      expect(find.text('Срок годности'), findsNothing);
    });
  });

  group('schedule form', () {
    Future<String> medicine() => inventory.createMedicine(
      const NewMedicine(name: 'Аспирин', initialQuantity: 9, unit: 'шт.'),
    );

    testWidgets('dates: a dates section and no period', (tester) async {
      await pumpApp(tester);
      await medicine();
      await tap(tester, find.byTooltip('Добавить приём'));
      expect(find.text('Период'), findsOneWidget);

      await tap(tester, find.text('По датам'));
      expect(find.text('Даты'), findsOneWidget);
      expect(find.text('Добавить дату'), findsOneWidget);
      expect(find.text('Период'), findsNothing);
      // Times stay optional for any kind.
      expect(find.text('Добавить время (необязательно)'), findsOneWidget);
    });

    testWidgets('a started schedule keeps its start; the end can change', (
      tester,
    ) async {
      await pumpApp(tester);
      final id = await medicine();
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
      await tap(tester, find.byTooltip('Управление расписанием'));
      await tap(tester, find.text('Изменить расписание'));

      await tap(tester, find.widgetWithText(DateField, 'Начало'));
      expect(find.text('Выберите дату'), findsNothing);

      await tap(
        tester,
        find.widgetWithText(DateField, 'Окончание (необязательно)'),
      );
      expect(find.text('Выберите дату'), findsOneWidget);
      await tap(tester, find.text('Готово'));
      expect(find.byTooltip('Очистить'), findsOneWidget);
      await tap(tester, find.byTooltip('Очистить'));
      expect(find.text('Не указано'), findsOneWidget);
    });
  });
}
