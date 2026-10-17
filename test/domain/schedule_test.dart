import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/domain/errors.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/domain/schedule.dart';

NewSchedule sched({
  ScheduleKind kind = ScheduleKind.daily,
  Set<int> weekdays = const {},
  List<DateTime> dates = const [],
  DateTime? start,
  DateTime? end,
  double dose = 1,
}) => NewSchedule(
  medicineId: 'm',
  kind: kind,
  dose: dose,
  doseUnit: 'шт.',
  weekdays: weekdays,
  dates: dates,
  startDate: start ?? DateTime(2026, 10, 1),
  endDate: end,
);

void main() {
  group('occursOn', () {
    test('daily respects start and end, inclusive', () {
      final s = sched(
        start: DateTime(2026, 10, 10),
        end: DateTime(2026, 10, 12),
      );
      expect(occursOn(s, DateTime(2026, 10, 9)), isFalse);
      expect(occursOn(s, DateTime(2026, 10, 10, 23, 59)), isTrue);
      expect(occursOn(s, DateTime(2026, 10, 12)), isTrue);
      expect(occursOn(s, DateTime(2026, 10, 13)), isFalse);
    });

    test('weekdays', () {
      // 2026-10-19 is a Monday.
      final s = sched(
        kind: ScheduleKind.weekdays,
        weekdays: {DateTime.monday, DateTime.friday},
      );
      expect(occursOn(s, DateTime(2026, 10, 19)), isTrue);
      expect(occursOn(s, DateTime(2026, 10, 23)), isTrue);
      expect(occursOn(s, DateTime(2026, 10, 20)), isFalse);
    });

    test('specific dates', () {
      final s = sched(
        kind: ScheduleKind.dates,
        dates: [DateTime(2026, 10, 20)],
      );
      expect(occursOn(s, DateTime(2026, 10, 20)), isTrue);
      expect(occursOn(s, DateTime(2026, 10, 21)), isFalse);
    });
  });

  group('validateNewSchedule', () {
    void rejects(NewSchedule s) => expect(
      () => validateNewSchedule(s),
      throwsA(isA<InvalidScheduleException>()),
    );

    test('rejects bad input', () {
      rejects(sched(dose: 0));
      rejects(sched(dose: -1));
      rejects(sched(kind: ScheduleKind.weekdays));
      rejects(sched(kind: ScheduleKind.dates));
      rejects(sched(start: DateTime(2026, 10, 5), end: DateTime(2026, 10, 4)));
    });

    test('dates are deduplicated, date-only and sorted', () {
      final v = validateNewSchedule(
        sched(
          kind: ScheduleKind.dates,
          dates: [
            DateTime(2026, 11, 2, 8),
            DateTime(2026, 11, 1),
            DateTime(2026, 11, 2),
          ],
        ),
      );
      expect(v.dates, [DateTime(2026, 11, 1), DateTime(2026, 11, 2)]);
    });
  });

  group('planDeduction', () {
    final t = DateTime(2026, 10, 17);
    MedicinePackage pkg(String id, double q, DateTime? exp) => MedicinePackage(
      id: id,
      medicineId: 'm',
      initialQuantity: q,
      quantity: q,
      unit: 'шт.',
      createdAt: t,
      expiresOn: exp,
    );

    test('uses earliest in-date expiry first, expired last, spills over', () {
      final plan = planDeduction(
        [
          pkg('expired', 5, DateTime(2026, 1, 1)),
          pkg('late', 5, DateTime(2028, 1, 1)),
          pkg('soon', 2, DateTime(2026, 12, 1)),
        ],
        3,
        t,
      );
      expect(plan.map((s) => (s.packageId, s.amount)), [
        ('soon', 2.0),
        ('late', 1.0),
      ]);
    });

    test('throws when the total is not enough', () {
      expect(
        () => planDeduction([pkg('a', 1, null), pkg('b', 1, null)], 3, t),
        throwsA(isA<InsufficientStockException>()),
      );
    });
  });

  test('intakes sort timed first by time, then untimed by name', () {
    DayIntake i(String name, int? minute) => DayIntake(
      medicineName: name,
      minuteOfDay: minute,
      schedule: Schedule(
        id: name,
        createdAt: DateTime(2026),
        medicineId: 'm',
        kind: ScheduleKind.daily,
        dose: 1,
        doseUnit: 'шт.',
        startDate: DateTime(2026),
      ),
    );
    final l = [i('Б', null), i('А', null), i('В', 600), i('Г', 480)]
      ..sort(compareIntakes);
    expect(l.map((e) => e.medicineName), ['Г', 'В', 'А', 'Б']);
  });
}
