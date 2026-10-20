import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/design_system/theme.dart';
import 'package:pillory/design_system/widgets/app_card.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/domain/reminders.dart';
import 'package:pillory/domain/schedule.dart';
import 'package:pillory/features/today/today_providers.dart';
import 'package:pillory/features/today/today_screen.dart';

import '../support/fake_extras_repository.dart';
import '../support/fake_inventory_repository.dart';

void main() {
  late FakeInventoryRepository inventory;
  late FakeScheduleRepository schedules;
  late ProviderContainer container;

  setUp(() {
    inventory = FakeInventoryRepository();
    schedules = FakeScheduleRepository(inventory);
    container = ProviderContainer(
      overrides: [
        inventoryRepositoryProvider.overrideWithValue(inventory),
        extrasRepositoryProvider.overrideWithValue(FakeExtrasRepository()),
        scheduleRepositoryProvider.overrideWithValue(schedules),
      ],
    );
  });
  tearDown(() => container.dispose());

  Future<String> schedule(
    String name, {
    List<int> times = const [],
    DateTime? start,
  }) async {
    final id = await inventory.createMedicine(
      NewMedicine(name: name, initialQuantity: 50, unit: 'шт.'),
    );
    return schedules.createSchedule(
      NewSchedule(
        medicineId: id,
        kind: ScheduleKind.daily,
        dose: 1,
        doseUnit: 'шт.',
        startDate: start ?? DateTime.now(),
        times: times,
      ),
    );
  }

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(800, 1600),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: buildAppTheme(), home: const TodayScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder highlighted() => find.byWidgetPredicate(
    (w) => w is AppCard && w.variant == AppCardVariant.highlighted,
  );

  group('day plan', () {
    testWidgets('counts the taken intakes', (tester) async {
      await schedule('Аспирин', times: const [8 * 60, 20 * 60]);
      await pump(tester);
      expect(find.text('0 из 2 принято'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Принять').first);
      await tester.pumpAndSettle();
      expect(find.text('1 из 2 принято'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      // A taken intake is tinted and offers undo instead of the buttons.
      expect(find.byTooltip('Отменить отметку'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Принять'), findsOneWidget);
    });

    testWidgets('groups intakes by part of the day', (tester) async {
      await schedule('Аспирин', times: const [8 * 60, 13 * 60, 20 * 60]);
      await schedule('Витамин D');
      await pump(tester);
      for (final h in ['Утро  08:00', 'День  13:00', 'Вечер  20:00']) {
        expect(find.text(h), findsOneWidget, reason: h);
      }
      expect(find.text('В течение дня'), findsOneWidget);
    });
  });

  testWidgets('times of one medicine are marked independently', (tester) async {
    await schedule('Аспирин', times: const [0, 1]);
    await pump(tester);

    await tester.tap(find.text('Пропустить').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Принять'));
    await tester.pumpAndSettle();

    expect(find.text('Пропущено'), findsOneWidget);
    expect(find.byTooltip('Отменить отметку'), findsNWidgets(2));
    // Skipped reads differently from taken, not only by its badge.
    final names = tester.widgetList<Text>(find.text('Аспирин')).toList();
    expect(
      names.map((t) => t.style?.decoration == TextDecoration.lineThrough),
      [true, false],
    );
  });

  testWidgets('untimed intakes are grouped after the timed ones', (
    tester,
  ) async {
    await schedule('Витамин D');
    await schedule('Аспирин', times: const [0]);
    await pump(tester);
    expect(find.text('В течение дня'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Аспирин')).dy,
      lessThan(tester.getTopLeft(find.text('В течение дня')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Витамин D')).dy,
      greaterThan(tester.getTopLeft(find.text('В течение дня')).dy),
    );
  });

  group('a reminder', () {
    final tomorrow = () {
      final n = DateTime.now();
      return DateTime(n.year, n.month, n.day + 1);
    }();

    void open(String scheduleId, int minute) => container
        .read(openIntakeProvider.notifier)
        .open(
          OpenIntakeRequest(
            scheduleId: scheduleId,
            day: tomorrow,
            minuteOfDay: minute,
          ),
        );

    /// Enough intakes that the last one starts far below the fold.
    Future<String> longDay() async {
      for (var h = 6; h < 22; h++) {
        await schedule('Лекарство $h', times: [h * 60]);
      }
      return schedule('Последнее', times: const [23 * 60]);
    }

    bool onScreen(WidgetTester tester, Finder f) {
      final r = tester.getRect(f);
      return r.top >= 0 && r.bottom <= 700;
    }

    testWidgets('scrolls its intake into view and highlights it', (
      tester,
    ) async {
      final id = await longDay();
      await pump(tester, size: const Size(400, 700));
      open(id, 23 * 60);
      await tester.pumpAndSettle();

      expect(highlighted(), findsOneWidget);
      expect(
        find.descendant(of: highlighted(), matching: find.text('Последнее')),
        findsOneWidget,
      );
      expect(onScreen(tester, find.text('Последнее')), isTrue);
    });

    testWidgets('sent before the day has loaded still scrolls', (tester) async {
      final id = await longDay();
      open(id, 23 * 60); // read by the screen's initState
      await pump(tester, size: const Size(400, 700));
      expect(highlighted(), findsOneWidget);
      expect(onScreen(tester, find.text('Последнее')), isTrue);
    });

    testWidgets('pointing at nothing is ignored quietly', (tester) async {
      await longDay();
      await pump(tester, size: const Size(400, 700));
      open('no-such-schedule', 23 * 60);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(highlighted(), findsNothing);
      expect(find.text('Лекарство 6'), findsOneWidget);
    });
  });
}
