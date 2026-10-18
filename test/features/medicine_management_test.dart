import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/app.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/domain/medicine_form.dart';
import 'package:pillory/domain/models.dart';

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
        of: find.byType(NavigationBar),
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
    expect(find.text('Остаток: 10 шт.'), findsOneWidget);

    await tester.tap(find.text('Добавить упаковку'));
    await tester.pumpAndSettle();
    expect(find.text('шт.'), findsOneWidget); // the unit is fixed, not asked
    await tester.enterText(find.widgetWithText(TextField, 'Количество'), '5');
    await tester.tap(find.text('Добавить'));
    await tester.pumpAndSettle();

    expect(find.text('Остаток: 15 шт.'), findsOneWidget);
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
    expect(find.text('Остаток: 7 шт.'), findsOneWidget);

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
    expect(find.text('Остаток: 10 шт.'), findsOneWidget);
  });

  testWidgets('editing renames the medicine', (tester) async {
    await openMedicine(tester);
    await menu(tester, 'Лекарство', 'Изменить');
    expect(find.text('Начальное количество'), findsNothing);
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
}
