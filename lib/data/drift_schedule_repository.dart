import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/errors.dart';
import '../domain/inventory_repository.dart';
import '../domain/inventory_rules.dart';
import '../domain/models.dart';
import '../domain/reminders.dart';
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
    return _watchRange(d, d).map((byDay) => byDay[d] ?? const []);
  }

  @override
  Stream<Map<DateTime, List<DayIntake>>> watchHistory(
    DateTime from,
    DateTime to,
  ) => _watchRange(dateOnly(from), dateOnly(to));

  @override
  Stream<ReminderSource> watchReminderSource(DateTime from) {
    final s = _db.schedules, m = _db.medicines, l = _db.intakeLogs;
    final query = _db.select(s).join([
      innerJoin(m, m.id.equalsExp(s.medicineId)),
      leftOuterJoin(
        l,
        l.scheduleId.equalsExp(s.id) &
            l.day.isBiggerOrEqual(Constant(_dates.toSql(dateOnly(from)))) &
            l.status.equalsValue(IntakeStatus.pending).not(),
      ),
    ]);
    return query.watch().map((rows) {
      final schedules = <String, ReminderSchedule>{};
      final settled = <String>{};
      for (final r in rows) {
        final row = r.readTable(s);
        schedules[row.id] ??= ReminderSchedule(
          _schedule(row),
          r.readTable(m).name,
        );
        final log = r.readTableOrNull(l);
        if (log != null) {
          settled.add(
            intakeKey(
              row.id,
              log.day,
              log.slot == untimedSlot ? null : log.slot,
            ),
          );
        }
      }
      return ReminderSource(
        schedules: schedules.values.toList(),
        settled: settled,
      );
    });
  }

  Stream<Map<DateTime, List<DayIntake>>> _watchRange(
    DateTime from,
    DateTime to,
  ) {
    final s = _db.schedules, m = _db.medicines, l = _db.intakeLogs;
    final query = _db.select(s).join([
      innerJoin(m, m.id.equalsExp(s.medicineId)),
      leftOuterJoin(
        l,
        l.scheduleId.equalsExp(s.id) &
            l.day.isBiggerOrEqual(Constant(_dates.toSql(from))) &
            l.day.isSmallerOrEqual(Constant(_dates.toSql(to))),
      ),
    ]);
    // The join reads all three tables, so new schedules and marks re-emit.
    // A schedule yields one row per mark in the range (or one without marks).
    return query.watch().map((rows) {
      final bySchedule = <String, List<TypedResult>>{};
      for (final r in rows) {
        (bySchedule[r.readTable(s).id] ??= []).add(r);
      }
      final result = <DateTime, List<DayIntake>>{};
      for (final group in bySchedule.values) {
        final schedule = _schedule(group.first.readTable(s));
        final name = group.first.readTable(m).name;
        final logs = [
          for (final r in group)
            if (r.readTableOrNull(l) != null) r.readTable(l),
        ];
        for (
          var d = from;
          !d.isAfter(to);
          d = DateTime(d.year, d.month, d.day + 1)
        ) {
          if (!occursOn(schedule, d)) continue;
          for (final slot in slotsOf(schedule)) {
            final log = logs
                .where((x) => x.day == d && x.slot == (slot ?? untimedSlot))
                .firstOrNull;
            (result[d] ??= []).add(
              DayIntake(
                schedule: schedule,
                medicineName: name,
                minuteOfDay: slot,
                status: log?.status ?? IntakeStatus.pending,
                deductionsTracked: log?.deductionsTracked ?? false,
              ),
            );
          }
        }
      }
      for (final list in result.values) {
        list.sort(compareIntakes);
      }
      return result;
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

  /// Loads the schedule and the mark of one intake, validating the intake.
  Future<(Schedule, IntakeLogRow?)> _load(
    String scheduleId,
    DateTime d,
    int? minuteOfDay,
  ) async {
    final row = await (_db.select(
      _db.schedules,
    )..where((s) => s.id.equals(scheduleId))).getSingleOrNull();
    if (row == null) throw ScheduleNotFoundException(scheduleId);
    final schedule = _schedule(row);
    if (!occursOn(schedule, d)) {
      throw ArgumentError.value(d, 'day', 'no intake scheduled that day');
    }
    if (!slotsOf(schedule).contains(minuteOfDay)) {
      throw ArgumentError.value(minuteOfDay, 'minuteOfDay', 'not a time');
    }
    final log =
        await (_db.select(_db.intakeLogs)..where(
              (l) =>
                  l.scheduleId.equals(scheduleId) &
                  l.day.equalsValue(d) &
                  l.slot.equals(minuteOfDay ?? untimedSlot),
            ))
            .getSingleOrNull();
    return (schedule, log);
  }

  /// Writes the mark: updates the existing row (guarded by its current
  /// status, so a concurrent change makes it a no-op) or inserts a new one.
  /// Returns the row id, or null if the guard lost.
  Future<String?> _setMark(
    IntakeLogRow? log, {
    required String scheduleId,
    required DateTime day,
    required int slot,
    required IntakeStatus status,
    required bool tracked,
  }) async {
    if (log == null) {
      final id = generateId();
      await _db
          .into(_db.intakeLogs)
          .insert(
            IntakeLogsCompanion.insert(
              id: id,
              scheduleId: scheduleId,
              day: day,
              slot: Value(slot),
              status: Value(status),
              deductionsTracked: Value(tracked),
              takenAt: _now(),
            ),
          );
      return id;
    }
    final changed =
        await (_db.update(_db.intakeLogs)..where(
              (l) => l.id.equals(log.id) & l.status.equalsValue(log.status),
            ))
            .write(
              IntakeLogsCompanion(
                status: Value(status),
                deductionsTracked: Value(tracked),
                takenAt: Value(_now()),
              ),
            );
    return changed == 1 ? log.id : null;
  }

  @override
  Future<void> markTaken({
    required String scheduleId,
    required DateTime day,
    int? minuteOfDay,
  }) {
    final d = dateOnly(day);
    return _db.transaction(() async {
      final (schedule, log) = await _load(scheduleId, d, minuteOfDay);
      if (log?.status == IntakeStatus.taken) return;

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
      // The mark and its deductions are written together, in this one
      // transaction, so `deductions_tracked` is true only with all of them.
      final logId = await _setMark(
        log,
        scheduleId: scheduleId,
        day: d,
        slot: minuteOfDay ?? untimedSlot,
        status: IntakeStatus.taken,
        tracked: true,
      );
      if (logId == null) return;
      for (final step in plan) {
        await _inventory.adjustQuantity(
          packageId: step.packageId,
          delta: -step.amount,
        );
        await _db
            .into(_db.intakeDeductions)
            .insert(
              IntakeDeductionsCompanion.insert(
                id: generateId(),
                intakeLogId: logId,
                packageId: step.packageId,
                amount: step.amount,
              ),
            );
      }
    });
  }

  @override
  Future<void> markSkipped({
    required String scheduleId,
    required DateTime day,
    int? minuteOfDay,
  }) {
    final d = dateOnly(day);
    return _db.transaction(() async {
      final (_, log) = await _load(scheduleId, d, minuteOfDay);
      if (log?.status == IntakeStatus.skipped) return;
      if (log?.status == IntakeStatus.taken) {
        throw const IntakeStateException('Приём уже отмечен как принятый');
      }
      await _setMark(
        log,
        scheduleId: scheduleId,
        day: d,
        slot: minuteOfDay ?? untimedSlot,
        status: IntakeStatus.skipped,
        tracked: false,
      );
    });
  }

  @override
  Future<void> resetMark({
    required String scheduleId,
    required DateTime day,
    int? minuteOfDay,
  }) {
    final d = dateOnly(day);
    return _db.transaction(() async {
      final (_, log) = await _load(scheduleId, d, minuteOfDay);
      if (log == null || log.status == IntakeStatus.pending) return;
      if (log.status == IntakeStatus.taken && !log.deductionsTracked) {
        throw const UntrackedIntakeException();
      }
      final id = await _setMark(
        log,
        scheduleId: scheduleId,
        day: d,
        slot: minuteOfDay ?? untimedSlot,
        status: IntakeStatus.pending,
        tracked: false,
      );
      if (id == null || log.status == IntakeStatus.skipped) return;
      // Give back exactly what this mark took, each deduction once.
      final open = await (_db.select(
        _db.intakeDeductions,
      )..where((x) => x.intakeLogId.equals(id) & x.restoredAt.isNull())).get();
      for (final x in open) {
        await _inventory.adjustQuantity(
          packageId: x.packageId,
          delta: x.amount,
        );
        await (_db.update(_db.intakeDeductions)
              ..where((y) => y.id.equals(x.id)))
            .write(IntakeDeductionsCompanion(restoredAt: Value(_now())));
      }
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
