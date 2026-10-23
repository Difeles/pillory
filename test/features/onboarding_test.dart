import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/app.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/domain/extras.dart';

import '../support/fake_diary_repository.dart';
import '../support/fake_extras_repository.dart';
import '../support/fake_inventory_repository.dart';
import '../support/fake_reminder_scheduler.dart';

void main() {
  testWidgets('an empty first launch shows the welcome once', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final inventory = FakeInventoryRepository();
    final extras = FakeExtrasRepository();
    await extras.setPref(PrefKey.onboarded, 'false');
    final scheduler = FakeReminderScheduler()..allowed = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryRepositoryProvider.overrideWithValue(inventory),
          extrasRepositoryProvider.overrideWithValue(extras),
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
    expect(find.text('Привет! Я PillPal'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Аня');
    await tester.tap(find.text('Включить напоминания'));
    await tester.pumpAndSettle();
    expect(scheduler.requests, 1);
    expect(find.text('Привет! Я PillPal'), findsNothing);
    expect(find.text('Приём'), findsWidgets);

    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    expect(find.text('Аня'), findsOneWidget);
  });
}
