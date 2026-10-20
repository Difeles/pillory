import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../data/drift_backup_repository.dart';
import '../data/drift_extras_repository.dart';
import '../data/drift_inventory_repository.dart';
import '../data/drift_schedule_repository.dart';
import '../domain/extras.dart';
import '../domain/inventory_repository.dart';
import '../domain/reminder_scheduler.dart';
import '../domain/schedule.dart';
import 'reminder_sync.dart';

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

/// Replaced in `main` with the real one; tests run without notifications.
final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => const NoopReminderScheduler(),
);

final backupRepositoryProvider = Provider<DriftBackupRepository>(
  (ref) => DriftBackupRepository(ref.watch(appDatabaseProvider)),
);

final reminderSyncProvider = Provider<ReminderSync>((ref) {
  final sync = ReminderSync(
    ref.watch(scheduleRepositoryProvider),
    ref.watch(reminderSchedulerProvider),
  );
  ref.onDispose(sync.dispose);
  return sync;
});

final extrasRepositoryProvider = Provider<ExtrasRepository>(
  (ref) => DriftExtrasRepository(ref.watch(appDatabaseProvider)),
);

final shoppingProvider = StreamProvider<List<ShoppingItem>>(
  (ref) => ref.watch(extrasRepositoryProvider).watchShopping(),
);

/// Settings; the defaults until the first read.
final prefsProvider = StreamProvider<AppPrefs>(
  (ref) => ref.watch(extrasRepositoryProvider).watchPrefs(),
);
