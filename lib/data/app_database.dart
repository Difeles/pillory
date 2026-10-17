import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/medicine_form.dart';
import '../domain/models.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Medicines, MedicinePackages, InventoryTransactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'pillory'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // v1: no upgrades yet. When schemaVersion is bumped, run
    // `dart run drift_dev make-migrations` and use `stepByStep(...)` here;
    // until then an unexpected upgrade throws instead of silently dropping data.
    beforeOpen: (details) async {
      // SQLite ignores REFERENCES unless this is switched on per connection.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
