import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/medicine_form.dart';
import '../domain/models.dart';
import '../domain/schedule.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Medicines,
    MedicinePackages,
    InventoryTransactions,
    Schedules,
    IntakeLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'pillory'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v2 added schedules and intake logs; existing tables are untouched.
      if (from < 2) {
        await m.createTable(schedules);
        await m.createIndex(idxSchedulesMedicine);
        await m.createTable(intakeLogs);
      } else if (from < 3) {
        // v3: several times per schedule. Logs first, as they read the old
        // schedules.minute_of_day; existing marks keep their time as slot.
        await m.alterTable(
          TableMigration(
            intakeLogs,
            newColumns: [intakeLogs.slot],
            columnTransformer: {
              intakeLogs.slot: const CustomExpression(
                '(SELECT coalesce(s.minute_of_day, -1) FROM schedules s '
                'WHERE s.id = schedule_id)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            schedules,
            newColumns: [schedules.times],
            columnTransformer: {
              schedules.times: const CustomExpression(
                "coalesce(CAST(minute_of_day AS TEXT), '')",
              ),
            },
          ),
        );
      }
    },
    beforeOpen: (details) async {
      // SQLite ignores REFERENCES unless this is switched on per connection.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
