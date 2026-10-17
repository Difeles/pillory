import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../data/drift_inventory_repository.dart';
import '../data/drift_schedule_repository.dart';
import '../domain/inventory_repository.dart';
import '../domain/schedule.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final inventoryRepositoryProvider = Provider<InventoryRepository>(
  (ref) => DriftInventoryRepository(ref.watch(appDatabaseProvider)),
);

final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) => DriftScheduleRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(inventoryRepositoryProvider),
  ),
);
