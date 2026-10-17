import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/schedule.dart';

/// Intakes for one calendar day (date-only key), live from the database.
final dayIntakesProvider = StreamProvider.family<List<DayIntake>, DateTime>(
  (ref, day) => ref.watch(scheduleRepositoryProvider).watchDay(day),
);
