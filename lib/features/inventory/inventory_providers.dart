import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/models.dart';
import '../../domain/schedule.dart';

/// The cabinet list, live from the database.
final medicineStockProvider = StreamProvider<List<MedicineStock>>(
  (ref) => ref.watch(inventoryRepositoryProvider).watchStock(),
);

/// Archived medicines, live from the database.
final archivedStockProvider = StreamProvider<List<MedicineStock>>(
  (ref) => ref.watch(inventoryRepositoryProvider).watchArchived(),
);

/// The schedules that are not archived with their medicine.
final activeSchedulesProvider = StreamProvider<List<Schedule>>(
  (ref) => ref
      .watch(scheduleRepositoryProvider)
      .watchReminderSource(dateOnly(DateTime.now()))
      .map((s) => [for (final r in s.schedules) r.schedule]),
);
