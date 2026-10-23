import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/domain/achievements.dart';
import 'package:pillory/domain/schedule.dart';
import 'package:pillory/domain/streak.dart';

DayIntake _i(IntakeStatus s) => DayIntake(
  schedule: Schedule(
    id: 's',
    createdAt: DateTime(2026),
    medicineId: 'm',
    kind: ScheduleKind.daily,
    dose: 1,
    doseUnit: 'шт.',
    startDate: DateTime(2026),
  ),
  medicineName: 'A',
  status: s,
);

void main() {
  final today = DateTime(2026, 10, 20);
  DateTime ago(int n) => DateTime(2026, 10, 20 - n);
  final taken = [_i(IntakeStatus.taken)];
  final pending = [_i(IntakeStatus.pending)];

  test('counts consecutive completed days', () {
    expect(
      currentStreak({today: taken, ago(1): taken, ago(2): taken}, today),
      3,
    );
  });

  test('today unfinished does not break it, a missed past day does', () {
    expect(currentStreak({today: pending, ago(1): taken}, today), 1);
    expect(
      currentStreak({today: taken, ago(1): pending, ago(2): taken}, today),
      1,
    );
    expect(
      currentStreak({
        ago(1): [_i(IntakeStatus.skipped)],
      }, today),
      0,
    );
  });

  test('days without intakes neither add nor break', () {
    expect(currentStreak({today: taken, ago(2): taken}, today), 2);
    expect(currentStreak({}, today), 0);
  });

  test('badges', () {
    expect(earnedBadges(streak: 0, medicines: 0, expired: 0), isEmpty);
    expect(earnedBadges(streak: 7, medicines: 3, expired: 0), {
      AppBadge.firstWeek,
      AppBadge.cabinetKeeper,
      AppBadge.noExpired,
    });
    expect(
      earnedBadges(
        streak: 30,
        medicines: 10,
        expired: 0,
        takenMarks: 50,
        perfectWeek: true,
        diaryEntries: 3,
      ),
      AppBadge.values.toSet(),
    );
    expect(earnedBadges(streak: 1, medicines: 3, expired: 1), {
      AppBadge.cabinetKeeper,
    });
  });

  test('goals and summaries', () {
    expect(nextStreakGoal(0), 7);
    expect(nextStreakGoal(7), 14);
    expect(nextStreakGoal(100), isNull);

    final done = taken;
    final missed = pending;
    final week = {for (var k = 0; k < 7; k++) ago(k): done};
    expect(periodSummary(week, today, days: 7).taken, 7);
    expect(isPerfectWeek(week, today), isTrue);
    week[ago(3)] = missed;
    expect(isPerfectWeek(week, today), isFalse);
    // Today's open intake is still ahead.
    expect(periodSummary({today: missed}, today, days: 1).planned, 0);
  });
}
