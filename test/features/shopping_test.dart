import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/design_system/theme.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/features/shopping/shopping_screen.dart';

import '../support/fake_extras_repository.dart';
import '../support/fake_inventory_repository.dart';

void main() {
  testWidgets('low stock is urgent, the list takes items, the kit knows the '
      'cabinet', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final inventory = FakeInventoryRepository();
    await inventory.createMedicine(
      const NewMedicine(
        name: 'Парацетамол 500',
        initialQuantity: 1,
        unit: 'шт.',
        lowStockThreshold: 5,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryRepositoryProvider.overrideWithValue(inventory),
          extrasRepositoryProvider.overrideWithValue(FakeExtrasRepository()),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const ShoppingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Мало'), findsOneWidget);
    await tester.tap(find.text('В список'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(CheckboxListTile, 'Парацетамол 500'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'Бинт');
    await tester.tap(find.byTooltip('Добавить в список'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(CheckboxListTile, 'Бинт'), findsOneWidget);

    // Paracetamol is in the cabinet, so the kit marks it.
    expect(find.text('В наличии'), findsOneWidget);
  });
}
