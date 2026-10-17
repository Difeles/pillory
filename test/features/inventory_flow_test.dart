import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/app.dart';
import 'package:pillory/app/providers.dart';

import '../support/fake_inventory_repository.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryRepositoryProvider.overrideWithValue(
            FakeInventoryRepository(),
          ),
        ],
        child: const PilloryApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  IconButton button(WidgetTester tester, String tooltip) => tester.widget(
    find.ancestor(
      of: find.byTooltip(tooltip),
      matching: find.byType(IconButton),
    ),
  );

  testWidgets('empty cabinet, add a medicine, change its quantity', (
    tester,
  ) async {
    await pumpApp(tester);

    // Empty state with a way forward.
    expect(find.text('В аптечке пока пусто'), findsOneWidget);
    await tester.tap(find.text('Добавить лекарство'));
    await tester.pumpAndSettle();

    // The name is required.
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Введите название'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Название *'),
      'Аспирин',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Дозировка или концентрация'),
      '500 мг',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Начальное количество'),
      '1',
    );
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    // Back on the list, the saved medicine is there.
    expect(find.text('В аптечке пока пусто'), findsNothing);
    expect(find.text('Аспирин'), findsOneWidget);
    expect(find.text('500 мг'), findsOneWidget);
    expect(find.text('1 шт.'), findsOneWidget);

    await tester.tap(find.byTooltip('Увеличить остаток'));
    await tester.pumpAndSettle();
    expect(find.text('2 шт.'), findsOneWidget);

    await tester.tap(find.byTooltip('Уменьшить остаток'));
    await tester.tap(find.byTooltip('Уменьшить остаток'));
    await tester.pumpAndSettle();
    expect(find.text('0 шт.'), findsOneWidget);

    // At zero the minus button is disabled: the quantity cannot go negative.
    expect(button(tester, 'Уменьшить остаток').onPressed, isNull);
    expect(find.text('-1 шт.'), findsNothing);
  });
}
