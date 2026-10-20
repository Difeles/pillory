import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/design_system/widgets/floating_dock.dart';
import 'package:pillory/app/app.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/domain/models.dart';

import '../support/fake_extras_repository.dart';
import '../support/fake_inventory_repository.dart';

void main() {
  late FakeInventoryRepository inventory;
  final now = DateTime.now();
  DateTime inDays(int n) => DateTime(now.year, now.month, now.day + n);

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    inventory = FakeInventoryRepository();
    Future<void> add(
      String name,
      double qty, {
      double? initial,
      DateTime? expires,
      double? threshold,
    }) async {
      final id = await inventory.createMedicine(
        NewMedicine(
          name: name,
          initialQuantity: initial ?? qty,
          unit: 'шт.',
          expiresOn: expires,
          lowStockThreshold: threshold,
        ),
      );
      if (initial != null && initial != qty) {
        final p = (await inventory.watchStock().first)
            .firstWhere((s) => s.medicine.id == id)
            .primaryPackage;
        await inventory.correctQuantity(
          packageId: p.id,
          from: initial,
          to: qty,
        );
      }
    }

    await add('Аспирин', 30, expires: inDays(400));
    await add('Бром', 30, expires: inDays(-3));
    await add('Глицин', 30, expires: inDays(10));
    await add('Ибупрофен', 0, initial: 10);
    await add('Кеторол', 1, initial: 10);
    await add('Лоратадин', 10, initial: 100, threshold: 12);
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
  }

  Future<void> choose(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(ChoiceChip, label));
    await tester.pumpAndSettle();
  }

  bool shown(String name) => find.text(name).evaluate().isNotEmpty;

  testWidgets('cards show one status each', (tester) async {
    await pump(tester);
    expect(find.textContaining('Просрочено с'), findsOneWidget);
    expect(find.textContaining('Скоро истекает: до'), findsOneWidget);
    expect(find.text('Закончилось'), findsOneWidget);
    // Кеторол: 1 of the 20% default (2); Лоратадин: 10 of its own 12.
    expect(find.text('Мало: осталось 1 шт.'), findsOneWidget);
    expect(find.text('Мало: осталось 10 шт.'), findsOneWidget);
    expect(find.textContaining('Годен до'), findsOneWidget); // Аспирин
  });

  testWidgets('the filters pick and order the medicines', (tester) async {
    await pump(tester);
    expect(
      [
        'Аспирин',
        'Бром',
        'Глицин',
        'Ибупрофен',
        'Кеторол',
        'Лоратадин',
      ].every(shown),
      isTrue,
    );

    await choose(tester, 'Просрочено');
    expect(shown('Бром'), isTrue);
    expect(shown('Аспирин') || shown('Глицин'), isFalse);

    await choose(tester, 'Скоро истекает');
    expect(shown('Глицин'), isTrue);
    expect(shown('Бром') || shown('Аспирин'), isFalse);

    await choose(tester, 'Мало или нет');
    expect(
      shown('Ибупрофен') && shown('Кеторол') && shown('Лоратадин'),
      isTrue,
    );
    // Бром has only expired stock, so no usable stock: it is out as well.
    expect(shown('Бром'), isTrue);
    expect(shown('Аспирин') || shown('Глицин'), isFalse);
    // Out first, then the emptiest: Бром, Ибупрофен, then Кеторол, Лоратадин.
    final y = [
      for (final n in ['Бром', 'Ибупрофен', 'Кеторол', 'Лоратадин'])
        tester.getTopLeft(find.text(n)).dy,
    ];
    expect(y, [...y]..sort());

    await choose(tester, 'Все');
    expect(shown('Аспирин') && shown('Лоратадин'), isTrue);
  });

  testWidgets('an empty filter says so', (tester) async {
    await pump(tester);
    await inventory.archiveMedicine(
      (await inventory.watchStock().first)
          .firstWhere((s) => s.medicine.name == 'Бром')
          .medicine
          .id,
    );
    await tester.pumpAndSettle();
    await choose(tester, 'Просрочено');
    expect(find.text('Нет лекарств с таким статусом'), findsOneWidget);
  });

  testWidgets('the filter bar is not shown in the archive', (tester) async {
    await pump(tester);
    await tester.tap(find.byTooltip('Архив'));
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceChip), findsNothing);
  });
}
