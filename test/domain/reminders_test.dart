import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/domain/reminders.dart';
import 'package:pillory/domain/schedule.dart';

void main() {
  // Monday 2026-10-19, 07:00.
  final now = DateTime(2026, 10, 19, 7);

  Schedule schedule({
    String id = 's',
    ScheduleKind kind = ScheduleKind.daily,
    List<int> times = const [8 * 60],
    Set<int> weekdays = const {},
    List<DateTime> dates = const [],
    DateTime? start,
    DateTime? end,
  }) => Schedule(
    id: id,
    createdAt: now,
    medicineId: 'm',
    kind: kind,
    dose: 1,
    doseUnit: 'шт.',
    startDate: start ?? DateTime(2026, 10, 1),
    endDate: end,
    weekdays: weekdays,
    dates: dates,
    times: times,
  );

  ReminderSource source(List<Schedule> s, {Set<String> settled = const {}}) =>
      ReminderSource(
        schedules: [for (final x in s) ReminderSchedule(x, 'Аспирин')],
        settled: settled,
      );

  List<DateTime> fires(ReminderSource s, {int limit = reminderLimit}) => [
    for (final r in planReminders(s, now, limit: limit)) r.fireAt,
  ];

  test('daily with several times, past times of today are skipped', () {
    final f = fires(
      source([
        schedule(times: [6 * 60, 20 * 60, 8 * 60]),
      ]),
      limit: 4,
    );
    expect(f, [
      DateTime(2026, 10, 19, 8),
      DateTime(2026, 10, 19, 20),
      DateTime(2026, 10, 20, 6),
      DateTime(2026, 10, 20, 8),
    ]);
  });

  test('untimed schedules get no reminders', () {
    expect(planReminders(source([schedule(times: [])]), now), isEmpty);
  });

  test('chosen weekdays only', () {
    final f = fires(
      source([
        schedule(
          kind: ScheduleKind.weekdays,
          weekdays: {DateTime.wednesday, DateTime.friday},
        ),
      ]),
      limit: 3,
    );
    expect(f.map((d) => d.day), [21, 23, 28]);
  });

  test('start and end dates bound the reminders', () {
    final f = fires(
      source([
        schedule(start: DateTime(2026, 10, 21), end: DateTime(2026, 10, 22)),
      ]),
    );
    expect(f, [DateTime(2026, 10, 21, 8), DateTime(2026, 10, 22, 8)]);
  });

  test('specific dates: all future ones count, even far away', () {
    final far = DateTime(2030, 5, 1);
    final f = fires(
      source([
        schedule(
          kind: ScheduleKind.dates,
          dates: [far, DateTime(2026, 10, 18), DateTime(2026, 10, 25)],
          start: DateTime(2026, 10, 18),
        ),
      ]),
    );
    expect(f, [DateTime(2026, 10, 25, 8), DateTime(2030, 5, 1, 8)]);
  });

  test('takes the nearest 60 across schedules, not a fixed number of days', () {
    final plan = planReminders(
      source([
        schedule(id: 'a', times: [8 * 60, 20 * 60]),
        schedule(
          id: 'w',
          kind: ScheduleKind.weekdays,
          weekdays: {DateTime.sunday},
          times: [9 * 60],
        ),
      ]),
      now,
    );
    expect(plan, hasLength(reminderLimit));
    final sorted = [...plan]..sort((a, b) => a.fireAt.compareTo(b.fireAt));
    expect(plan.map((r) => r.fireAt), sorted.map((r) => r.fireAt));
    // Beyond two weeks, so a 14-day window would have missed these.
    expect(plan.last.fireAt.isAfter(DateTime(2026, 11, 10)), isTrue);
    expect(plan.where((r) => r.scheduleId == 'w'), isNotEmpty);
  });

  test('a sparse weekly schedule still fills the limit within the horizon', () {
    final plan = planReminders(
      source([
        schedule(kind: ScheduleKind.weekdays, weekdays: {DateTime.monday}),
      ]),
      now,
    );
    expect(plan, hasLength(reminderLimit));
    final last = plan.last.fireAt;
    expect(last.difference(now).inDays, lessThan(reminderMaxDays));
  });

  test('the horizon limit applies to recurring schedules', () {
    final plan = planReminders(
      source([schedule()]),
      now,
      limit: 1000,
      maxDays: 10,
    );
    expect(plan, hasLength(11)); // today's 08:00 and the next 10 days
  });

  test('settled intakes get no reminder, other times of the day do', () {
    final plan = planReminders(
      source(
        [
          schedule(times: [8 * 60, 20 * 60]),
        ],
        settled: {intakeKey('s', DateTime(2026, 10, 19), 8 * 60)},
      ),
      now,
      limit: 2,
    );
    expect(plan.map((r) => r.fireAt), [
      DateTime(2026, 10, 19, 20),
      DateTime(2026, 10, 20, 8),
    ]);
  });

  test('ids are stable, unique and fit 31 bits', () {
    final a = planReminders(source([schedule()]), now);
    final b = planReminders(source([schedule()]), now);
    expect(a.map((r) => r.id), b.map((r) => r.id));
    expect(a.map((r) => r.id).toSet(), hasLength(a.length));
    expect(a.every((r) => r.id >= 0 && r.id <= 0x7FFFFFFF), isTrue);
  });

  test('the payload round-trips; bad payloads are ignored', () {
    final r = planReminders(source([schedule()]), now).first;
    final back = OpenIntakeRequest.fromPayload(jsonEncode(r.request.toJson()))!;
    expect(back.scheduleId, 's');
    expect(back.day, DateTime(2026, 10, 19));
    expect(back.minuteOfDay, 480);
    for (final bad in [null, '', 'x', '{}', '{"s":"a","d":"1-2","m":1}']) {
      expect(OpenIntakeRequest.fromPayload(bad), isNull);
    }
  });

  group('SnoozePlan', () {
    final payload = jsonEncode({
      's': 'sid',
      'd': '2026-10-19',
      'm': 480,
      't': 'Аспирин',
      'b': '2 шт.',
      'ss': false,
      'sv': true,
    });

    test('a later button repeats the reminder and drops its follow-up', () {
      final plan = SnoozePlan.from(
        id: 100,
        payload: payload,
        actionId: 'snooze30',
      )!;
      expect(plan.after, const Duration(minutes: 30));
      expect(plan.cancelId, 100 ^ followUpBit);
      expect(plan.newId, isNot(100));
      expect(plan.title, 'Аспирин');
      expect(plan.body, '2 шт.');
      expect(plan.style.sound, isFalse);
      expect(plan.style.vibration, isTrue);
      // The postponed one is marked, and still opens the same intake.
      expect(jsonDecode(plan.payload)['z'], 1);
      expect(OpenIntakeRequest.fromPayload(plan.payload)!.scheduleId, 'sid');
      expect(
        SnoozePlan.from(id: 100, payload: payload, actionId: 'snooze')!.after,
        const Duration(minutes: 10),
      );
    });

    test('other buttons and broken payloads do not postpone', () {
      expect(
        SnoozePlan.from(id: 1, payload: payload, actionId: 'taken'),
        isNull,
      );
      expect(SnoozePlan.from(id: 1, payload: payload, actionId: null), isNull);
      expect(
        SnoozePlan.from(id: null, payload: payload, actionId: 'snooze'),
        isNull,
      );
      expect(
        SnoozePlan.from(id: 1, payload: 'nope', actionId: 'snooze'),
        isNull,
      );
      expect(SnoozePlan.from(id: 1, payload: '{}', actionId: 'snooze'), isNull);
    });
  });
}
