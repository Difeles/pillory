import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/app.dart';
import 'package:pillory/app/providers.dart';

import '../support/fake_diary_repository.dart';
import '../support/fake_extras_repository.dart';
import '../support/fake_inventory_repository.dart';
import '../support/fake_reminder_scheduler.dart';

void main() {
  testWidgets('a denied permission can be asked for again from settings', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final inventory = FakeInventoryRepository();
    final scheduler = FakeReminderScheduler()..allowed = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryRepositoryProvider.overrideWithValue(inventory),
          extrasRepositoryProvider.overrideWithValue(FakeExtrasRepository()),
          diaryRepositoryProvider.overrideWithValue(FakeDiaryRepository()),
          scheduleRepositoryProvider.overrideWithValue(
            FakeScheduleRepository(inventory),
          ),
          reminderSchedulerProvider.overrideWithValue(scheduler),
        ],
        child: const PilloryApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Настройки'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Уведомления'),
      200,
      maxScrolls: 100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Уведомления'));
    await tester.pumpAndSettle();
    expect(find.text('Напоминания выключены'), findsOneWidget);

    await tester.tap(find.text('Разрешить уведомления'));
    await tester.pumpAndSettle();
    expect(scheduler.requests, 1);
    expect(find.text('Напоминания включены'), findsOneWidget);
    expect(find.text('Разрешить уведомления'), findsNothing);
  });
}
