import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/errors.dart';
import '../domain/inventory_repository.dart';
import '../domain/inventory_rules.dart';
import '../domain/models.dart';
import '../domain/schedule.dart';
import 'app_database.dart';
import 'tables.dart';

class DriftScheduleRepository implements ScheduleRepository {
  /// [_inventory] must be backed by the same [_db]: the stock deduction runs
  /// inside this repository's transaction, which is what makes marking atomic.
  DriftScheduleRepository(this._db, this._inventory, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final InventoryRepository _inventory;
  final DateTime Function() _now;

  static const _dates = DateOnlyConverter();

  @override
  Stream<List<DayIntake>> watchDay(DateTime day) {
    final d = dateOnly(day);
    final s = _db.schedules, m = _db.medicines, l = _db.intakeLogs;
    final query = _db.select(s).join([
      innerJoin(m, m.id.equalsExp(s.medicineId)),
      leftOuterJoin(l, l.scheduleId.equalsExp(s.id) & l.day.equalsValue(d)),
    ]);
    // The join reads all three tables, so new schedules and marks re-emit.
    // A schedule yields one row per mark of the day (or one without marks).
    return query.watch().map((rows) {
      final bySchedule = <String, List<TypedResult>>{};
      for (final r in rows) {
        (bySchedule[r.readTable(s).id] ??= []).add(r);
      }
      final list = [
        for (final group in bySchedule.values)
          if (occursOn(_schedule(group.first.readTable(s)), d))
            for (final slot in slotsOf(_schedule(group.first.readTable(s))))
              DayIntake(
                schedule: _schedule(group.first.readTable(s)),
                medicineName: group.first.readTable(m).name,
                minuteOfDay: slot,
                takenAt: group
                    .map((r) => r.readTableOrNull(l))
                    .where((x) => x != null && x.slot == (slot ?? untimedSlot))
                    .firstOrNull
                    ?.takenAt,
              ),
      ]..sort(compareIntakes);
      return list;
    });
  }

  @override
  Future<String> createSchedule(NewSchedule draft) async {
    final d = validateNewSchedule(draft);
    final id = generateId();
    await _db
        .into(_db.schedules)
        .insert(
          SchedulesCompanion.insert(
            id: id,
            medicineId: d.medicineId,
            kind: d.kind,
            weekdays: Value((d.weekdays.toList()..sort()).join(',')),
            dates: Value(d.dates.map(_dates.toSql).join(',')),
            startDate: d.startDate,
            endDate: Value(d.endDate),
            times: Value(d.times.join(',')),
            dose: d.dose,
            doseUnit: d.doseUnit,
            createdAt: _now(),
          ),
        );
    return id;
  }

  @override
  Future<void> markTaken({
    required String scheduleId,
    required DateTime day,
    int? minuteOfDay,
  }) {
    final d = dateOnly(day);
    final slot = minuteOfDay ?? untimedSlot;
    return _db.transaction(() async {
      final row = await (_db.select(
        _db.schedules,
      )..where((s) => s.id.equals(scheduleId))).getSingleOrNull();
      if (row == null) throw ScheduleNotFoundException(scheduleId);
      final schedule = _schedule(row);
      if (!occursOn(schedule, d)) {
        throw ArgumentError.value(day, 'day', 'no intake scheduled that day');
      }
      if (!slotsOf(schedule).contains(minuteOfDay)) {
        throw ArgumentError.value(minuteOfDay, 'minuteOfDay', 'not a time');
      }
      final done =
          await (_db.select(_db.intakeLogs)..where(
                (l) =>
                    l.scheduleId.equals(scheduleId) &
                    l.day.equalsValue(d) &
                    l.slot.equals(slot),
              ))
              .getSingleOrNull();
      if (done != null) return;

      final packages = await (_db.select(
        _db.medicinePackages,
      )..where((p) => p.medicineId.equals(schedule.medicineId))).get();
      final plan = planDeduction(
        [
          for (final p in packages)
            MedicinePackage(
              id: p.id,
              medicineId: p.medicineId,
              initialQuantity: p.initialQuantity,
              quantity: p.quantity,
              unit: p.unit,
              expiresOn: p.expiresOn,
              createdAt: p.createdAt,
            ),
        ],
        schedule.dose,
        _now(),
      );
      for (final step in plan) {
        await _inventory.adjustQuantity(
          packageId: step.packageId,
          delta: -step.amount,
        );
      }
      await _db
          .into(_db.intakeLogs)
          .insert(
            IntakeLogsCompanion.insert(
              id: generateId(),
              scheduleId: scheduleId,
              day: d,
              slot: Value(slot),
              takenAt: _now(),
            ),
          );
    });
  }

  Schedule _schedule(ScheduleRow r) => Schedule(
    id: r.id,
    createdAt: r.createdAt,
    medicineId: r.medicineId,
    kind: r.kind,
    dose: r.dose,
    doseUnit: r.doseUnit,
    weekdays: {
      for (final w in r.weekdays.split(','))
        if (w.isNotEmpty) int.parse(w),
    },
    dates: [
      for (final x in r.dates.split(','))
        if (x.isNotEmpty) _dates.fromSql(x),
    ],
    startDate: r.startDate,
    endDate: r.endDate,
    times: [
      for (final x in r.times.split(','))
        if (x.isNotEmpty) int.parse(x),
    ],
  );
}
