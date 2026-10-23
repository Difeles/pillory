import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/design_system/widgets/floating_dock.dart';
import 'package:pillory/app/app.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/domain/medicine_form.dart';
import 'package:pillory/domain/models.dart';

import '../support/fake_extras_repository.dart';
import '../support/fake_inventory_repository.dart';

void main() {
  late FakeInventoryRepository inventory;

  Future<void> openMedicine(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    inventory = FakeInventoryRepository();
    await inventory.createMedicine(
      const NewMedicine(
        name: 'Аспирин',
        form: MedicineForm.tablet,
        strength: '500 мг',
        initialQuantity: 10,
        unit: 'шт.',
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryRepositoryProvider.overrideWithValue(inventory),
          extrasRepositoryProvider.overrideWithValue(FakeExtrasRepository()),
          scheduleRepositoryProvider.overrideWithValue(
            FakeScheduleRepository(inventory),
          ),
        ],
        child: const PilloryApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(FloatingDock),
        matching: find.text('Аптечка'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Аспирин'));
    await tester.pumpAndSettle();
  }

  // pageBack looks for the English 'Back' tooltip; the app is Russian.
  Future<void> back(WidgetTester tester) => tester.tap(find.byTooltip('Назад'));

  Future<void> menu(WidgetTester tester, String tooltip, String item) async {
    await tester.tap(find.byTooltip(tooltip).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(item));
    await tester.pumpAndSettle();
  }

  testWidgets('adding a package keeps the unit and sums the stock', (
    tester,
  ) async {
    await openMedicine(tester);
    expect(find.bySemanticsLabel('Остаток: 10 шт.'), findsOneWidget);

    await tester.tap(find.text('Добавить упаковку'));
    await tester.pumpAndSettle();
    expect(find.text('шт.'), findsNWidgets(2)); // fixed, not asked: two suffixes
    await tester.enterText(
      find.widgetWithText(TextField, 'Сколько было в упаковке'),
      '5',
    );
    await tester.tap(find.text('Добавить'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Остаток: 15 шт.'), findsOneWidget);
    expect(find.text('5 шт.'), findsOneWidget);
  });

  testWidgets('correcting the stock shows up in the movement history', (
    tester,
  ) async {
    await openMedicine(tester);
    await menu(tester, 'Упаковка', 'Скорректировать остаток');
    await tester.enterText(
      find.widgetWithText(TextField, 'Фактический остаток'),
      '7',
    );
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Остаток: 7 шт.'), findsOneWidget);

    await menu(tester, 'Упаковка', 'История движения');
    expect(find.textContaining('Коррекция'), findsOneWidget);
    expect(find.textContaining('−3'), findsOneWidget);
  });

  testWidgets('a negative stock is refused', (tester) async {
    await openMedicine(tester);
    await menu(tester, 'Упаковка', 'Скорректировать остаток');
    await tester.enterText(
      find.widgetWithText(TextField, 'Фактический остаток'),
      '-1',
    );
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Введите число 0 или больше'), findsOneWidget);
    expect(find.bySemanticsLabel('Остаток: 10 шт.'), findsOneWidget);
  });

  testWidgets('editing renames the medicine', (tester) async {
    await openMedicine(tester);
    await menu(tester, 'Лекарство', 'Изменить');
    expect(find.text('Сколько было в упаковке'), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Название *'),
      'Аспирин Кардио',
    );
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Аспирин Кардио'), findsOneWidget);
  });

  testWidgets('archiving asks first and moves the medicine to the archive', (
    tester,
  ) async {
    await openMedicine(tester);
    await menu(tester, 'Лекарство', 'В архив');
    expect(find.text('Убрать в архив?'), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(find.text('В архиве'), findsNothing);

    await menu(tester, 'Лекарство', 'В архив');
    await tester.tap(find.widgetWithText(FilledButton, 'В архив'));
    await tester.pumpAndSettle();
    expect(find.text('В архиве'), findsOneWidget);

    await back(tester);
    await tester.pumpAndSettle();
    expect(find.text('В аптечке пока пусто'), findsOneWidget);
    await tester.tap(find.byTooltip('Архив'));
    await tester.pumpAndSettle();
    expect(find.text('Аспирин'), findsOneWidget);

    // Back from the archive: the medicine returns to the cabinet.
    await tester.tap(find.text('Аспирин'));
    await tester.pumpAndSettle();
    await menu(tester, 'Лекарство', 'Вернуть из архива');
    await back(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Вернуться в аптечку'));
    await tester.pumpAndSettle();
    expect(find.text('Аспирин'), findsOneWidget);
  });

  testWidgets('quick +/- are offered only for a single package', (
    tester,
  ) async {
    await openMedicine(tester);
    await back(tester);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Уменьшить остаток'), findsOneWidget);

    await tester.tap(find.text('Аспирин'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Добавить упаковку'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Добавить'));
    await tester.pumpAndSettle();
    await back(tester);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Уменьшить остаток'), findsNothing);
  });

  testWidgets('several packages: one card each, the total sums them', (
    tester,
  ) async {
    await openMedicine(tester);
    final id = (await inventory.watchStock().first).single.medicine.id;
    await inventory.addPackage(
      medicineId: id,
      quantity: 4,
      unit: 'шт.',
      expiresOn: DateTime(2000, 1, 1),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Остаток: 14 шт.'), findsOneWidget);
    expect(find.text('10 шт.'), findsOneWidget);
    expect(find.text('4 шт.'), findsOneWidget);
    expect(find.text('Срок годности истёк 01.01.2000'), findsOneWidget);
    expect(find.byTooltip('Упаковка'), findsNWidgets(2));
  });

  testWidgets('a package in another unit is flagged and left out', (
    tester,
  ) async {
    await openMedicine(tester);
    final id = (await inventory.watchStock().first).single.medicine.id;
    // Legacy data: the repository no longer accepts a foreign unit.
    await inventory.addPackage(medicineId: id, quantity: 50, unit: 'мл');
    await tester.pumpAndSettle();

    expect(find.text('50 мл'), findsOneWidget);
    expect(
      find.text(
        'Другая единица: не входит в остаток и не расходуется приёмами',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Остаток: 10 шт.'), findsOneWidget);
  });

  testWidgets('the package menu keeps every action', (tester) async {
    await openMedicine(tester);
    await tester.tap(find.byTooltip('Упаковка'));
    await tester.pumpAndSettle();
    for (final item in [
      'Скорректировать остаток',
      'Срок годности',
      'История движения',
    ]) {
      expect(find.text(item), findsOneWidget);
    }
    // Clearing is offered only once there is a date.
    expect(find.text('Убрать срок годности'), findsNothing);
  });

  testWidgets('an archived medicine keeps its packages and history', (
    tester,
  ) async {
    await openMedicine(tester);
    await menu(tester, 'Лекарство', 'В архив');
    await tester.tap(find.widgetWithText(FilledButton, 'В архив'));
    await tester.pumpAndSettle();

    expect(find.text('В архиве'), findsOneWidget);
    expect(find.byTooltip('Упаковка'), findsOneWidget);
    // Adding is refused for the archive, so it is not offered.
    expect(find.text('Добавить упаковку'), findsNothing);
    await menu(tester, 'Упаковка', 'История движения');
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('История движения'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the medicine menu offers edit and archive', (tester) async {
    await openMedicine(tester);
    await tester.tap(find.byTooltip('Лекарство'));
    await tester.pumpAndSettle();
    expect(find.text('Изменить'), findsOneWidget);
    expect(find.text('В архив'), findsOneWidget);
  });

  testWidgets('an intake outside the schedule takes from the stock', (
    tester,
  ) async {
    await openMedicine(tester);
    await tester.ensureVisible(find.text('Принять сейчас'));
    await tester.tap(find.text('Принять сейчас'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '2');
    await tester.tap(find.text('Записать'));
    await tester.pumpAndSettle();

    expect(find.text('Записано: 2 шт.'), findsOneWidget);
    expect(find.text('8 шт.'), findsWidgets);
  });

  testWidgets('more than the stock is refused without leaving a schedule', (
    tester,
  ) async {
    await openMedicine(tester);
    await tester.ensureVisible(find.text('Принять сейчас'));
    await tester.tap(find.text('Принять сейчас'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '11');
    await tester.tap(find.text('Записать'));
    await tester.pumpAndSettle();

    expect(find.text('Остаток не может быть отрицательным'), findsOneWidget);
    expect(find.text('10 шт.'), findsWidgets);
  });
}
