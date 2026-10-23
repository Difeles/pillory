import 'package:drift/drift.dart'
    show BooleanExpressionOperators, StringExpressionOperators;

import '../domain/extras.dart' show devicePrefix;
import 'app_database.dart';
import 'backup_format.dart';

class DriftBackupRepository {
  DriftBackupRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  /// Every row, read in one transaction so the copy is one moment's state.
  Future<BackupData> read() => _db.transaction(
    () async => BackupData(
      schemaVersion: _db.schemaVersion,
      createdAt: _now(),
      medicines: await _db.select(_db.medicines).get(),
      packages: await _db.select(_db.medicinePackages).get(),
      transactions: await _db.select(_db.inventoryTransactions).get(),
      schedules: await _db.select(_db.schedules).get(),
      intakeLogs: await _db.select(_db.intakeLogs).get(),
      intakeDeductions: await _db.select(_db.intakeDeductions).get(),
      diary: await _db.select(_db.diaryEntries).get(),
      shopping: await _db.select(_db.shoppingItems).get(),
      // The device's own settings (which account, which revision) stay here.
      settings: [
        for (final s in await _db.select(_db.appSettings).get())
          if (!s.key.startsWith(devicePrefix)) s,
      ],
    ),
  );

  /// Replaces all data with [data], all or nothing: any failure rolls the
  /// transaction back and leaves the database as it was. Parents are written
  /// before children, so the foreign keys check every reference.
  Future<void> restore(BackupData data) => _db.transaction(() async {
    await _db.delete(_db.intakeDeductions).go();
    await _db.delete(_db.intakeLogs).go();
    await _db.delete(_db.inventoryTransactions).go();
    await _db.delete(_db.schedules).go();
    await _db.delete(_db.medicinePackages).go();
    await _db.delete(_db.medicines).go();
    if (data.hasExtras) {
      await _db.delete(_db.diaryEntries).go();
      await _db.delete(_db.shoppingItems).go();
      await (_db.delete(
        _db.appSettings,
      )..where((t) => t.key.like('$devicePrefix%').not())).go();
    }
    await _db.batch((b) {
      b.insertAll(_db.medicines, data.medicines);
      b.insertAll(_db.medicinePackages, data.packages);
      b.insertAll(_db.inventoryTransactions, data.transactions);
      b.insertAll(_db.schedules, data.schedules);
      b.insertAll(_db.intakeLogs, data.intakeLogs);
      b.insertAll(_db.intakeDeductions, data.intakeDeductions);
      if (data.hasExtras) {
        b.insertAll(_db.diaryEntries, data.diary);
        b.insertAll(_db.shoppingItems, data.shopping);
        b.insertAll(_db.appSettings, data.settings);
      }
    });
  });
}
