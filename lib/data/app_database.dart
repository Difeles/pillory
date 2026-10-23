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
    IntakeDeductions,
    ShoppingItems,
    AppSettings,
    DiaryEntries,
    PeriodDays,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'pillory'));

  @override
  int get schemaVersion => 12;

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
        // Their SQL defaults make them taken with untracked deductions.
        await m.alterTable(
          TableMigration(
            intakeLogs,
            newColumns: [
              intakeLogs.slot,
              intakeLogs.status,
              intakeLogs.deductionsTracked,
              intakeLogs.medicineName,
              intakeLogs.medicineForm,
              intakeLogs.medicineStrength,
            ],
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
            newColumns: [schedules.times, schedules.mealRelation],
            columnTransformer: {
              schedules.times: const CustomExpression(
                "coalesce(CAST(minute_of_day AS TEXT), '')",
              ),
            },
          ),
        );
      } else if (from < 4) {
        // v4: skipped marks and undo. Existing marks stay taken, untracked.
        await m.addColumn(intakeLogs, intakeLogs.status);
        await m.addColumn(intakeLogs, intakeLogs.deductionsTracked);
        await _addSnapshotColumns(m);
      } else if (from < 5) {
        // v5: marks keep a snapshot of the medicine. Existing marks have none
        // and keep following the current medicine.
        await _addSnapshotColumns(m);
      }
      if (from < 4) {
        await m.createTable(intakeDeductions);
      }
      if (from < 6) {
        // v6: an optional own low-stock threshold; existing medicines have
        // none and keep the app-wide rule.
        await m.addColumn(medicines, medicines.lowStockThreshold);
      }
      if (from < 7) {
        // v7: category, storage and meal relation (all optional), the
        // shopping list and the settings.
        await m.addColumn(medicines, medicines.category);
        await m.addColumn(medicines, medicines.storage);
        // Older schedules tables were created or rebuilt above, with it.
        if (from >= 3) await m.addColumn(schedules, schedules.mealRelation);
        await m.createTable(shoppingItems);
        await m.createTable(appSettings);
      }
      if (from < 8) {
        // v8: the wellbeing diary.
        await m.createTable(diaryEntries);
        await m.createIndex(idxDiaryAt);
      }
      if (from < 9) {
        // v9: how a medicine's pill looks (optional).
        await m.addColumn(medicines, medicines.look);
      }
      if (from >= 8 && from < 11) {
        // v11: the diary keeps what the trouble was, not measurements.
        await m.addColumn(diaryEntries, diaryEntries.symptoms);
        for (final c in ['temperature', 'systolic', 'diastolic', 'pulse']) {
          await customStatement('ALTER TABLE diary_entries DROP COLUMN $c');
        }
      }
      if (from >= 8 && from < 12) {
        // v12: a migraine level on diary entries.
        await m.addColumn(diaryEntries, diaryEntries.migraine);
      }
      if (from < 12) {
        // v12: the period calendar.
        await m.createTable(periodDays);
      }
      if (from == 10) {
        // v10 had a flag "important medicine"; v11 has none.
        await customStatement('ALTER TABLE medicines DROP COLUMN important');
      }
      if (from < 5) {
        // medicines is never rebuilt above, so it lacks both columns here.
        await m.addColumn(medicines, medicines.archivedAt);
        await m.addColumn(medicines, medicines.unit);
        // Existing medicines are not archived. Their unit is that of their
        // oldest package; packages in another unit stay as they are and are
        // kept out of totals and deductions (see MedicineStock.counted).
        await customStatement(
          'UPDATE medicines SET unit = (SELECT p.unit FROM medicine_packages p '
          'WHERE p.medicine_id = medicines.id '
          'ORDER BY p.created_at, p.rowid LIMIT 1)',
        );
      }
    },
    beforeOpen: (details) async {
      // SQLite ignores REFERENCES unless this is switched on per connection.
      await customStatement('PRAGMA foreign_keys = ON');
      // Phones upgraded from before v4 never got this index: createTable above
      // does not create the table's indexes. Harmless where it exists.
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_deductions_log '
        'ON intake_deductions (intake_log_id)',
      );
    },
  );

  Future<void> _addSnapshotColumns(Migrator m) async {
    await m.addColumn(intakeLogs, intakeLogs.medicineName);
    await m.addColumn(intakeLogs, intakeLogs.medicineForm);
    await m.addColumn(intakeLogs, intakeLogs.medicineStrength);
  }
}
