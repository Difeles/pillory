import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/app.dart';
import 'package:pillory/app/home_shell.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/design_system/tokens.dart';

import '../support/fake_extras_repository.dart';
import '../support/fake_inventory_repository.dart';

void main() {
  testWidgets('the theme choice in settings switches the whole app', (
    tester,
  ) async {
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
    final shell = find.byType(HomeShell);
    expect(Theme.of(tester.element(shell)).brightness, Brightness.light);

    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Тёмная'));
    await tester.tap(find.text('Тёмная'));
    await tester.pumpAndSettle();
    final theme = Theme.of(tester.element(shell));
    expect(theme.brightness, Brightness.dark);
    expect(theme.extension<AppPalette>(), AppPalette.dark);
    expect(theme.scaffoldBackgroundColor, AppPalette.dark.background);

    await tester.tap(find.text('Светлая'));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(shell)).brightness, Brightness.light);
  });
}
