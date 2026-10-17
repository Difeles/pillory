import 'dart:async';

import 'package:pillory/core/ids.dart';
import 'package:pillory/domain/errors.dart';
import 'package:pillory/domain/inventory_repository.dart';
import 'package:pillory/domain/inventory_rules.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/domain/reminders.dart';
import 'package:pillory/domain/schedule.dart';

/// In-memory repository for widget tests. Real SQLite I/O does not complete
/// under the widget tester's fake clock, so the UI is tested against this and
/// the Drift implementation has its own tests. Uses the real domain rules.
class FakeInventoryRepository implements InventoryRepository {
  final _medicines = <Medicine>[];
  final _packages = <MedicinePackage>[];
  final _changes = StreamController<void>.broadcast(sync: true);

  List<MedicineStock> _snapshot() => [
    for (final m in _medicines)
      MedicineStock(
        medicine: m,
        packages: [
          for (final p in _packages)
            if (p.medicineId == m.id) p,
        ],
      ),
  ];

  @override
  Stream<List<MedicineStock>> watchStock() async* {
    yield _snapshot();
    await for (final _ in _changes.stream) {
      yield _snapshot();
    }
  }

  @override
  Future<String> createMedicine(NewMedicine draft) async {
    final d = validateNewMedicine(draft);
    final id = generateId();
    _medicines.add(
      Medicine(
        id: id,
        name: d.name,
        form: d.form,
        strength: d.strength,
        createdAt: DateTime.now(),
      ),
    );
    await addPackage(
      medicineId: id,
      quantity: d.initialQuantity,
      unit: d.unit,
      expiresOn: d.expiresOn,
    );
    return id;
  }

  @override
  Future<String> addPackage({
    required String medicineId,
    required double quantity,
    required String unit,
    DateTime? expiresOn,
  }) async {
    final id = generateId();
    _packages.add(
      MedicinePackage(
        id: id,
        medicineId: medicineId,
        initialQuantity: quantity,
        quantity: quantity,
        unit: unit,
        expiresOn: expiresOn,
        createdAt: DateTime.now(),
      ),
    );
    _changes.add(null);
    return id;
  }

  @override
  Future<void> adjustQuantity({
    required String packageId,
    required double delta,
  }) async {
    final i = _packages.indexWhere((p) => p.id == packageId);
    if (i < 0) throw PackageNotFoundException(packageId);
    final p = _packages[i];
    final next = applyDelta(p.quantity, delta);
    _packages[i] = MedicinePackage(
      id: p.id,
      medicineId: p.medicineId,
      initialQuantity: p.initialQuantity,
      quantity: next,
      unit: p.unit,
      expiresOn: p.expiresOn,
      createdAt: p.createdAt,
    );
    _changes.add(null);
  }

  @override
  Future<List<InventoryTransaction>> history(String packageId) async => [];
}

/// In-memory schedule repository for widget tests, on top of the fake
/// inventory. Uses the real domain rules.
class FakeScheduleRepository implements ScheduleRepository {
  FakeScheduleRepository(this._inventory);

  final FakeInventoryRepository _inventory;
  final _schedules = <Schedule>[];
  final _marks = <String, IntakeStatus>{};
  // Marks made "before deductions were recorded": cannot be undone.
  final _untracked = <String>{};
  final _deductions = <String, List<({String packageId, double amount})>>{};
  final _changes = StreamController<void>.broadcast(sync: true);

  String _key(String id, DateTime day, int? minute) =>
      intakeKey(id, day, minute);

  /// Test hook: a taken mark as made before v4.
  void markLegacyTaken(String scheduleId, DateTime day, [int? minute]) {
    final k = _key(scheduleId, day, minute);
    _marks[k] = IntakeStatus.taken;
    _untracked.add(k);
    _changes.add(null);
  }

  Future<List<DayIntake>> _snapshot(DateTime day) async {
    final stock = await _inventory.watchStock().first;
    return [
      for (final s in _schedules)
        if (occursOn(s, day))
          for (final slot in slotsOf(s))
            DayIntake(
              schedule: s,
              medicineName: stock
                  .firstWhere((m) => m.medicine.id == s.medicineId)
                  .medicine
                  .name,
              minuteOfDay: slot,
              status: _marks[_key(s.id, day, slot)] ?? IntakeStatus.pending,
              deductionsTracked: !_untracked.contains(_key(s.id, day, slot)),
            ),
    ]..sort(compareIntakes);
  }

  @override
  Stream<List<DayIntake>> watchDay(DateTime day) async* {
    yield await _snapshot(day);
    await for (final _ in _changes.stream) {
      yield await _snapshot(day);
    }
  }

  @override
  Stream<Map<DateTime, List<DayIntake>>> watchHistory(
    DateTime from,
    DateTime to,
  ) async* {
    Future<Map<DateTime, List<DayIntake>>> snapshot() async => {
      for (
        var d = dateOnly(from);
        !d.isAfter(to);
        d = DateTime(d.year, d.month, d.day + 1)
      )
        if ((await _snapshot(d)) case final l when l.isNotEmpty) d: l,
    };
    yield await snapshot();
    await for (final _ in _changes.stream) {
      yield await snapshot();
    }
  }

  @override
  Stream<ReminderSource> watchReminderSource(DateTime from) async* {
    Future<ReminderSource> snapshot() async {
      final stock = await _inventory.watchStock().first;
      return ReminderSource(
        schedules: [
          for (final s in _schedules)
            ReminderSchedule(
              s,
              stock
                  .firstWhere((m) => m.medicine.id == s.medicineId)
                  .medicine
                  .name,
            ),
        ],
        settled: {
          for (final e in _marks.entries)
            if (e.value != IntakeStatus.pending) e.key,
        },
      );
    }

    yield await snapshot();
    await for (final _ in _changes.stream) {
      yield await snapshot();
    }
  }

  @override
  Future<String> createSchedule(NewSchedule draft) async {
    final d = validateNewSchedule(draft);
    final s = Schedule(
      id: generateId(),
      createdAt: DateTime.now(),
      medicineId: d.medicineId,
      kind: d.kind,
      dose: d.dose,
      doseUnit: d.doseUnit,
      weekdays: d.weekdays,
      dates: d.dates,
      startDate: d.startDate,
      endDate: d.endDate,
      times: d.times,
    );
    _schedules.add(s);
    _changes.add(null);
    return s.id;
  }

  @override
  Future<void> markTaken({
    required String scheduleId,
    required DateTime day,
    int? minuteOfDay,
  }) async {
    final s = _schedules.firstWhere((s) => s.id == scheduleId);
    final k = _key(scheduleId, day, minuteOfDay);
    if (_marks[k] == IntakeStatus.taken) return;
    final stock = await _inventory.watchStock().first;
    final packages = stock
        .firstWhere((m) => m.medicine.id == s.medicineId)
        .packages;
    final plan = planDeduction(packages, s.dose, DateTime.now());
    for (final step in plan) {
      await _inventory.adjustQuantity(
        packageId: step.packageId,
        delta: -step.amount,
      );
    }
    _marks[k] = IntakeStatus.taken;
    _untracked.remove(k);
    _deductions[k] = plan;
    _changes.add(null);
  }

  @override
  Future<void> markSkipped({
    required String scheduleId,
    required DateTime day,
    int? minuteOfDay,
  }) async {
    final k = _key(scheduleId, day, minuteOfDay);
    if (_marks[k] == IntakeStatus.taken) {
      throw const IntakeStateException('taken');
    }
    _marks[k] = IntakeStatus.skipped;
    _changes.add(null);
  }

  @override
  Future<void> resetMark({
    required String scheduleId,
    required DateTime day,
    int? minuteOfDay,
  }) async {
    final k = _key(scheduleId, day, minuteOfDay);
    if (_marks[k] == IntakeStatus.taken) {
      if (_untracked.contains(k)) throw const UntrackedIntakeException();
      for (final x in _deductions.remove(k) ?? const []) {
        await _inventory.adjustQuantity(
          packageId: x.packageId,
          delta: x.amount,
        );
      }
    }
    _marks.remove(k);
    _changes.add(null);
  }
}
