import 'package:drift/drift.dart';

import '../domain/cycle.dart';
import 'app_database.dart';

class DriftCycleRepository implements CycleRepository {
  DriftCycleRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<Set<DateTime>> watchDays() => _db
      .select(_db.periodDays)
      .watch()
      .map((rows) => {for (final r in rows) r.day});

  @override
  Future<void> setDay(DateTime day, {required bool on}) {
    final d = DateTime(day.year, day.month, day.day);
    return on
        ? _db
              .into(_db.periodDays)
              .insert(
                PeriodDaysCompanion.insert(day: d),
                mode: InsertMode.insertOrIgnore,
              )
        : (_db.delete(_db.periodDays)..where((t) => t.day.equalsValue(d))).go();
  }
}
