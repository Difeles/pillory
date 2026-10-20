import 'schedule.dart';

/// Whether every intake of [intakes] was taken; false for a day with none.
bool dayComplete(List<DayIntake>? intakes) =>
    intakes != null && intakes.isNotEmpty && intakes.every((i) => i.taken);

/// Consecutive completed days up to [today]. Days without intakes neither add
/// nor break it, and today does not break it until it is over.
int currentStreak(Map<DateTime, List<DayIntake>> history, DateTime today) {
  var streak = 0;
  for (var k = 0; k < historyLookbackDays; k++) {
    final day = DateTime(today.year, today.month, today.day - k);
    final intakes = history[day];
    if (intakes == null || intakes.isEmpty) continue;
    if (dayComplete(intakes)) {
      streak++;
    } else if (k > 0) {
      break;
    }
  }
  return streak;
}

const historyLookbackDays = 60;
