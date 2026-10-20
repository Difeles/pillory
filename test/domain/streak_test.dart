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
    expect(
      earnedBadges(streak: 7, medicines: 3, expired: 0),
      AppBadge.values.toSet(),
    );
    expect(earnedBadges(streak: 1, medicines: 3, expired: 1), {
      AppBadge.cabinetKeeper,
    });
  });
}
