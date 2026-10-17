import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/schedule.dart';

/// Intakes for one calendar day (date-only key), live from the database.
final dayIntakesProvider = StreamProvider.family<List<DayIntake>, DateTime>(
  (ref, day) => ref.watch(scheduleRepositoryProvider).watchDay(day),
);

/// Intakes of the last [historyDays] days up to today, grouped by day.
const historyDays = 30;

final historyProvider = StreamProvider<Map<DateTime, List<DayIntake>>>((ref) {
  final today = dateOnly(DateTime.now());
  return ref
      .watch(scheduleRepositoryProvider)
      .watchHistory(
        DateTime(today.year, today.month, today.day - historyDays + 1),
        today,
      );
});
