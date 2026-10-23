import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/app.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/design_system/widgets/floating_dock.dart';
import 'package:pillory/domain/extras.dart';
import 'package:pillory/domain/medicine_form.dart';
import 'package:pillory/domain/models.dart';

import '../support/fake_diary_repository.dart';
import '../support/fake_extras_repository.dart';
import '../support/fake_inventory_repository.dart';

final _cyrillic = RegExp('[А-Яа-яЁё]');

/// Every text the user can read on the current screen.
List<String> _texts(WidgetTester tester) => [
  for (final w in tester.widgetList<Text>(find.byType(Text)))
    if (w.data != null) w.data!,
  for (final w in tester.widgetList<Tooltip>(find.byType(Tooltip)))
    if (w.message != null) w.message!,
];

void main() {
  testWidgets('with English chosen no Russian is left on the main screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final inventory = FakeInventoryRepository();
    await inventory.createMedicine(
      const NewMedicine(
        name: 'Aspirin',
        form: MedicineForm.tablet,
        category: MedicineCategory.painkiller,
        initialQuantity: 3,
        unit: 'шт.',
      ),
    );
    final extras = FakeExtrasRepository();
    await extras.setPref(PrefKey.language, 'en');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryRepositoryProvider.overrideWithValue(inventory),
          extrasRepositoryProvider.overrideWithValue(extras),
          diaryRepositoryProvider.overrideWithValue(FakeDiaryRepository()),
          scheduleRepositoryProvider.overrideWithValue(
            FakeScheduleRepository(inventory),
          ),
        ],
        child: const PilloryApp(),
      ),
    );
    await tester.pumpAndSettle();

    final seen = <String>[];
    void check(String screen) {
      // The language names are written in their own language.
      final bad = _texts(tester)
          .where((t) => _cyrillic.hasMatch(t) && t != 'Русский')
          .toList();
      seen.add(screen);
      expect(bad, isEmpty, reason: '$screen: $bad');
    }

    check('today');
    for (final tab in ['Cabinet', 'Shopping', 'Profile']) {
      await tester.tap(
        find.descendant(
          of: find.byType(FloatingDock),
          matching: find.text(tab),
        ),
      );
      await tester.pumpAndSettle();
      check(tab);
    }

    Future<void> visit(String screen, Finder opener) async {
      await tester.ensureVisible(opener);
      await tester.tap(opener);
      await tester.pumpAndSettle();
      check(screen);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await visit('account', find.byTooltip('Account and cloud'));
    await visit('achievements', find.text('Achievements'));
    await visit('settings', find.text('Settings'));
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    // The settings list, all of it.
    for (var i = 0; i < 4; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      check('settings $i');
    }
    await visit('notifications', find.text('Notifications').first);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await visit('diary', find.text('Wellbeing diary'));
    await visit('report', find.text("Doctor's report"));

    Future<void> tab(String name) async {
      await tester.tap(
        find.descendant(
          of: find.byType(FloatingDock),
          matching: find.text(name),
        ),
      );
      await tester.pumpAndSettle();
    }

    await tab('Cabinet');
    await visit('medicine', find.text('Aspirin'));
    await visit('add medicine', find.byTooltip('Add medicine'));
    await tab('Today');
    await visit('add intake', find.byTooltip('Add an intake'));
    await visit('history', find.byTooltip('History'));
    expect(seen, isNotEmpty);
  });
}
