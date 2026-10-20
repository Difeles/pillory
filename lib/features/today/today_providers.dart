import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/reminders.dart';
import '../../domain/schedule.dart';
import '../../domain/streak.dart';

/// Intakes for one calendar day (date-only key), live from the database.
final dayIntakesProvider = StreamProvider.family<List<DayIntake>, DateTime>(
  (ref, day) => ref.watch(scheduleRepositoryProvider).watchDay(day),
);

/// Intakes of the last [historyDays] days up to today, grouped by day.
const historyDays = historyLookbackDays;

final historyProvider = StreamProvider<Map<DateTime, List<DayIntake>>>((ref) {
  final today = dateOnly(DateTime.now());
  return ref
      .watch(scheduleRepositoryProvider)
      .watchHistory(
        DateTime(today.year, today.month, today.day - historyDays + 1),
        today,
      );
});

/// The intake a tapped notification points at; the day screen shows it.
class OpenIntakeNotifier extends Notifier<OpenIntakeRequest?> {
  @override
  OpenIntakeRequest? build() => null;

  void open(OpenIntakeRequest request) => state = request;
}

final openIntakeProvider =
    NotifierProvider<OpenIntakeNotifier, OpenIntakeRequest?>(
      OpenIntakeNotifier.new,
    );

/// The current streak of fully taken days.
final streakProvider = Provider<int>((ref) {
  final history = ref.watch(historyProvider).value;
  return history == null ? 0 : currentStreak(history, dateOnly(DateTime.now()));
});
