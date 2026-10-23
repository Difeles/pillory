import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/design_system/widgets/floating_dock.dart';
import 'package:pillory/app/app.dart';
import 'package:pillory/app/providers.dart';

import '../support/fake_extras_repository.dart';
import '../support/fake_inventory_repository.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    // Tall enough that the cards clear the floating add button.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final inventory = FakeInventoryRepository();
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
    // The app opens on "Приём"; this flow lives in the cabinet tab.
    await tester.tap(
      find.descendant(
        of: find.byType(FloatingDock),
        matching: find.text('Аптечка'),
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
    await tester.tap(find.text('Добавить в аптечку'));
    await tester.pumpAndSettle();
    expect(find.text('Введите название'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Название *'),
      'Аспирин',
    );
    await tester.scrollUntilVisible(
      find.widgetWithText(TextFormField, 'Дозировка или концентрация'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Дозировка или концентрация'),
      '500 мг',
    );
    await tester.scrollUntilVisible(
      find.widgetWithText(TextFormField, 'Сколько было в упаковке'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Сколько было в упаковке'),
      '1',
    );
    await tester.tap(find.text('Добавить в аптечку'));
    await tester.pumpAndSettle();

    // Back on the list, the saved medicine is there.
    expect(find.text('В аптечке пока пусто'), findsNothing);
    expect(find.text('Аспирин'), findsOneWidget);
    expect(find.text('500 мг'), findsOneWidget);
    expect(find.text('1 шт.'), findsOneWidget);

    // Mid-screen, clear of the glass dock.
    await Scrollable.ensureVisible(
      tester.element(find.byTooltip('Увеличить остаток')),
      alignment: 0.3,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Увеличить остаток'));
    await tester.pumpAndSettle();
    expect(find.text('2 шт.'), findsOneWidget);

    // Mid-screen, clear of the glass dock.
    await Scrollable.ensureVisible(
      tester.element(find.byTooltip('Уменьшить остаток')),
      alignment: 0.3,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Уменьшить остаток'));
    // Mid-screen, clear of the glass dock.
    await Scrollable.ensureVisible(
      tester.element(find.byTooltip('Уменьшить остаток')),
      alignment: 0.3,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Уменьшить остаток'));
    await tester.pumpAndSettle();
    expect(find.text('0 шт.'), findsOneWidget);

    // At zero the minus button is disabled: the quantity cannot go negative.
    expect(button(tester, 'Уменьшить остаток').onPressed, isNull);
    expect(find.text('-1 шт.'), findsNothing);
  });
}
