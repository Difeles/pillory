import 'inventory_rules.dart';
import 'schedule.dart';

/// Badges shown on the profile.
enum AppBadge {
  firstWeek,
  cabinetKeeper,
  noExpired,
  month,
  bigCabinet,
  fifty,
  perfectWeek,
  diary,
}

/// The badges earned from the current [streak], the number of cabinet
/// medicines, the number with an expired package, the taken marks in the
/// history window, whether the last week was done in full and the diary size.
Set<AppBadge> earnedBadges({
  required int streak,
  required int medicines,
  required int expired,
  int takenMarks = 0,
  bool perfectWeek = false,
  int diaryEntries = 0,
}) => {
  if (streak >= 7) AppBadge.firstWeek,
  if (medicines >= 3) AppBadge.cabinetKeeper,
  if (medicines > 0 && expired == 0) AppBadge.noExpired,
  if (streak >= 30) AppBadge.month,
  if (medicines >= 10) AppBadge.bigCabinet,
  if (takenMarks >= 50) AppBadge.fifty,
  if (perfectWeek) AppBadge.perfectWeek,
  if (diaryEntries >= 3) AppBadge.diary,
};

/// Streak lengths worth aiming for.
const streakGoals = [7, 14, 30, 60, 100];

/// The nearest goal above [streak], or null once the last is passed.
int? nextStreakGoal(int streak) =>
    streakGoals.where((g) => g > streak).firstOrNull;

/// Taken and planned intakes of [days] days ending [today] (today's open
/// intakes are still ahead and do not count as planned).
({int taken, int planned, int days}) periodSummary(
  Map<DateTime, List<DayIntake>> history,
  DateTime today, {
  required int days,
}) {
  final now = dateOnly(today);
  var taken = 0, planned = 0, withIntakes = 0;
  for (var k = 0; k < days; k++) {
    final day = DateTime(now.year, now.month, now.day - k);
    final list = history[day] ?? const <DayIntake>[];
    if (list.isNotEmpty) withIntakes++;
    for (final i in list) {
      if (i.taken) {
        taken++;
        planned++;
      } else if (i.skipped || k > 0) {
        planned++;
      }
    }
  }
  return (taken: taken, planned: planned, days: withIntakes);
}

/// The last 7 days all done: at least five days with intakes, none missed.
bool isPerfectWeek(Map<DateTime, List<DayIntake>> history, DateTime today) {
  final s = periodSummary(history, today, days: 7);
  return s.days >= 5 && s.planned > 0 && s.taken == s.planned;
}
