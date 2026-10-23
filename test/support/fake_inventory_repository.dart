import 'dart:async';

import 'package:pillory/core/ids.dart';
import 'package:pillory/domain/errors.dart';
import 'package:pillory/domain/inventory_repository.dart';
import 'package:pillory/domain/inventory_rules.dart';
import 'package:pillory/domain/medicine_form.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/domain/pill_look.dart';
import 'package:pillory/domain/reminders.dart';
import 'package:pillory/domain/schedule.dart';

/// In-memory repository for widget tests. Real SQLite I/O does not complete
/// under the widget tester's fake clock, so the UI is tested against this and
/// the Drift implementation has its own tests. Uses the real domain rules.
class FakeInventoryRepository implements InventoryRepository {
  final _medicines = <Medicine>[];
  final _packages = <MedicinePackage>[];
  final _changes = StreamController<void>.broadcast(sync: true);

  final _history = <String, List<InventoryTransaction>>{};

  void _log(
    String packageId,
    TransactionKind kind,
    double delta,
    double after,
  ) {
    (_history[packageId] ??= []).insert(
      0,
      InventoryTransaction(
        id: generateId(),
        packageId: packageId,
        kind: kind,
        delta: delta,
        quantityAfter: after,
        createdAt: DateTime.now(),
      ),
    );
  }

  List<MedicineStock> _snapshot({bool archived = false}) => [
    for (final m in _medicines)
      if ((m.archivedAt != null) == archived)
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
  Stream<List<MedicineStock>> watchArchived() async* {
    yield _snapshot(archived: true);
    await for (final _ in _changes.stream) {
      yield _snapshot(archived: true);
    }
  }

  void _replaceMedicine(String id, Medicine Function(Medicine) change) {
    final i = _medicines.indexWhere((m) => m.id == id);
    if (i < 0) throw MedicineNotFoundException(id);
    _medicines[i] = change(_medicines[i]);
    _changes.add(null);
  }

  Medicine _copy(
    Medicine m, {
    String? name,
    MedicineForm? form,
    String? strength,
    double? threshold,
    PillLook? look,
    bool setFields = false,
    DateTime? archivedAt,
    bool setArchived = false,
  }) => Medicine(
    id: m.id,
    name: setFields ? name! : m.name,
    form: setFields ? form : m.form,
    strength: setFields ? strength : m.strength,
    unit: m.unit,
    look: setFields ? look : m.look,
    lowStockThreshold: setFields ? threshold : m.lowStockThreshold,
    archivedAt: setArchived ? archivedAt : m.archivedAt,
    createdAt: m.createdAt,
  );

  @override
  Future<void> updateMedicine(String medicineId, MedicineEdit edit) async {
    if (edit.name.trim().isEmpty) {
      throw const InvalidMedicineException('Название обязательно');
    }
    final strength = edit.strength?.trim();
    _replaceMedicine(
      medicineId,
      (m) => _copy(
        m,
        name: edit.name.trim(),
        form: edit.form,
        strength: strength == null || strength.isEmpty ? null : strength,
        threshold: edit.lowStockThreshold,
        look: edit.look,
        setFields: true,
      ),
    );
  }

  @override
  Future<void> archiveMedicine(String medicineId) async => _replaceMedicine(
    medicineId,
    (m) => _copy(m, archivedAt: DateTime.now(), setArchived: true),
  );

  @override
  Future<void> restoreMedicine(String medicineId) async =>
      _replaceMedicine(medicineId, (m) => _copy(m, setArchived: true));

  @override
  Future<void> updatePackageExpiry(
    String packageId,
    DateTime? expiresOn,
  ) async {
    final i = _packages.indexWhere((p) => p.id == packageId);
    if (i < 0) throw PackageNotFoundException(packageId);
    final p = _packages[i];
    _packages[i] = MedicinePackage(
      id: p.id,
      medicineId: p.medicineId,
      initialQuantity: p.initialQuantity,
      quantity: p.quantity,
      unit: p.unit,
      expiresOn: expiresOn,
      createdAt: p.createdAt,
    );
    _changes.add(null);
  }

  @override
  Future<void> correctQuantity({
    required String packageId,
    required double from,
    required double to,
  }) async {
    if (to < 0) {
      throw const InvalidMedicineException(
        'Остаток не может быть отрицательным',
      );
    }
    final i = _packages.indexWhere((p) => p.id == packageId);
    if (i < 0) throw PackageNotFoundException(packageId);
    final p = _packages[i];
    if (p.quantity != from) {
      throw StaleQuantityException(expected: from, actual: p.quantity);
    }
    if (to == from) return;
    _packages[i] = MedicinePackage(
      id: p.id,
      medicineId: p.medicineId,
      initialQuantity: p.initialQuantity,
      quantity: to,
      unit: p.unit,
      expiresOn: p.expiresOn,
      createdAt: p.createdAt,
    );
    _log(packageId, TransactionKind.correction, to - from, to);
    _changes.add(null);
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
        unit: d.unit,
        look: d.look,
        lowStockThreshold: d.lowStockThreshold,
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
  Future<List<InventoryTransaction>> history(String packageId) async =>
      _history[packageId] ?? const [];
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

  (Schedule, DateTime) _forChange(String scheduleId) {
    final old = _schedules.firstWhere((s) => s.id == scheduleId);
    final today = dateOnly(DateTime.now());
    final prefix = '$scheduleId|${today.year}-${today.month}-${today.day}|';
    final marked = _marks.entries.any(
      (e) => e.key.startsWith(prefix) && e.value != IntakeStatus.pending,
    );
    return (
      old,
      marked ? DateTime(today.year, today.month, today.day + 1) : today,
    );
  }

  void _replace(String id, Schedule Function(Schedule) change) {
    final i = _schedules.indexWhere((s) => s.id == id);
    _schedules[i] = change(_schedules[i]);
    _changes.add(null);
  }

  Schedule _copy(Schedule o, {NewSchedule? with_, DateTime? end}) => Schedule(
    id: o.id,
    createdAt: o.createdAt,
    medicineId: o.medicineId,
    kind: with_?.kind ?? o.kind,
    dose: with_?.dose ?? o.dose,
    doseUnit: o.doseUnit,
    weekdays: with_?.weekdays ?? o.weekdays,
    dates: with_?.dates ?? o.dates,
    startDate: with_?.startDate ?? o.startDate,
    endDate: with_ != null ? with_.endDate : (end ?? o.endDate),
    times: with_?.times ?? o.times,
  );

  @override
  Future<DateTime> updateSchedule(String scheduleId, ScheduleEdit edit) async {
    final (old, from) = _forChange(scheduleId);
    switch (planScheduleEdit(old, edit, from)) {
      case ScheduleUnchanged():
        break;
      case ScheduleRewrite(:final draft):
        _replace(scheduleId, (o) => _copy(o, with_: draft));
      case ScheduleSplit(:final draft, :final closeOn):
        _replace(scheduleId, (o) => _copy(o, end: closeOn));
        await createSchedule(draft);
    }
    return from;
  }

  @override
  Future<DateTime> endSchedule(String scheduleId) async {
    final (old, from) = _forChange(scheduleId);
    if (isCurrent(old, from)) {
      _replace(scheduleId, (o) => _copy(o, end: endDateFor(old, from)));
    }
    return from;
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
