import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cloud/cloud_service.dart';
import '../data/app_database.dart';
import '../data/drift_backup_repository.dart';
import '../data/drift_cycle_repository.dart';
import '../data/drift_diary_repository.dart';
import '../data/drift_extras_repository.dart';
import '../data/drift_inventory_repository.dart';
import '../data/drift_schedule_repository.dart';
import '../domain/cycle.dart';
import '../domain/diary.dart';
import '../domain/extras.dart';
import '../domain/inventory_repository.dart';
import '../domain/reminder_scheduler.dart';
import '../domain/schedule.dart';
import 'cloud_sync.dart';
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
    prefs: () => ref.read(extrasRepositoryProvider).watchPrefs().first,
  );
  // Sound, quiet hours and language are part of what a reminder is; other
  // settings (the sync's own bookkeeping included) change nothing about it.
  ref.listen(
    prefsProvider.select((p) {
      final v = p.value;
      return v == null
          ? null
          : (v.sound, v.vibration, v.quiet, v.quietFrom, v.quietTo, v.language);
    }),
    (_, _) => sync.resync(),
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

final diaryRepositoryProvider = Provider<DiaryRepository>(
  (ref) => DriftDiaryRepository(ref.watch(appDatabaseProvider)),
);

final diaryProvider = StreamProvider<List<DiaryEntry>>(
  (ref) => ref.watch(diaryRepositoryProvider).watchEntries(),
);

final cycleRepositoryProvider = Provider<CycleRepository>(
  (ref) => DriftCycleRepository(ref.watch(appDatabaseProvider)),
);

/// The logged period days.
final periodDaysProvider = StreamProvider<Set<DateTime>>(
  (ref) => ref.watch(cycleRepositoryProvider).watchDays(),
);

/// Replaced in `main` with Firebase once it is configured.
final cloudServiceProvider = Provider<CloudService>(
  (ref) => const NoCloudService(),
);

/// Keeps this device's data and the signed-in account's backup equal. Not
/// started until the account screen or the app start asks for it.
final cloudSyncProvider = Provider<CloudSync>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final extras = ref.watch(extrasRepositoryProvider);
  final sync = CloudSync(
    cloud: ref.watch(cloudServiceProvider),
    backups: ref.watch(backupRepositoryProvider),
    extras: extras,
    // The settings table also holds the sync's own bookkeeping, so it is not
    // watched as a table: the user's settings signal their changes instead.
    localChanges: mergeSignals([
      db
          .tableUpdates()
          .where((u) => u.any((x) => x.table != 'app_settings'))
          .map((_) {}),
      extras.userSettingsChanged,
    ]),
    afterRestore: () => ref.read(reminderSyncProvider).resync(),
  );
  ref.onDispose(sync.dispose);
  return sync;
});
