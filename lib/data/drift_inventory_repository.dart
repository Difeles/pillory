import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/errors.dart';
import '../domain/inventory_repository.dart';
import '../domain/inventory_rules.dart';
import '../domain/models.dart';
import '../domain/pill_look.dart';
import '../domain/schedule.dart';
import 'app_database.dart';
import 'schedule_rows.dart';

class DriftInventoryRepository implements InventoryRepository {
  DriftInventoryRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  @override
  Stream<List<MedicineStock>> watchStock() => _watch(archived: false);

  @override
  Stream<List<MedicineStock>> watchArchived() => _watch(archived: true);

  Stream<List<MedicineStock>> _watch({required bool archived}) {
    final query =
        _db.select(_db.medicines).join([
            leftOuterJoin(
              _db.medicinePackages,
              _db.medicinePackages.medicineId.equalsExp(_db.medicines.id),
            ),
          ])
          ..where(
            archived
                ? _db.medicines.archivedAt.isNotNull()
                : _db.medicines.archivedAt.isNull(),
          )
          ..orderBy([
            OrderingTerm.asc(_db.medicines.id),
            OrderingTerm.asc(_db.medicinePackages.createdAt),
          ]);
    // A join watches every table it reads, so package and quantity changes
    // re-emit too.
    return query.watch().map((rows) {
      final byMedicine = <String, List<MedicinePackage>>{};
      final medicines = <String, Medicine>{};
      for (final row in rows) {
        final m = row.readTable(_db.medicines);
        medicines.putIfAbsent(m.id, () => _toMedicine(m));
        final list = byMedicine.putIfAbsent(m.id, () => []);
        final p = row.readTableOrNull(_db.medicinePackages);
        if (p != null) list.add(_package(p));
      }
      final stock = [
        for (final e in medicines.entries)
          // A medicine without packages cannot be created through this
          // repository; skip it rather than crash the list.
          if (byMedicine[e.key]!.isNotEmpty)
            MedicineStock(medicine: e.value, packages: byMedicine[e.key]!),
      ];
      // Sorted here, not in SQL: SQLite's lower() only folds ASCII, so
      // Cyrillic names would sort capitals before lowercase.
      stock.sort((a, b) {
        final byName = a.medicine.name.toLowerCase().compareTo(
          b.medicine.name.toLowerCase(),
        );
        return byName != 0 ? byName : a.medicine.id.compareTo(b.medicine.id);
      });
      return stock;
    });
  }

  @override
  Future<String> createMedicine(NewMedicine draft) async {
    final d = validateNewMedicine(draft);
    final now = _now();
    final medicineId = generateId();
    return _db.transaction(() async {
      await _db
          .into(_db.medicines)
          .insert(
            MedicinesCompanion.insert(
              id: medicineId,
              name: d.name,
              form: Value(d.form),
              strength: Value(d.strength),
              unit: Value(d.unit),
              lowStockThreshold: Value(d.lowStockThreshold),
              category: Value(d.category),
              storage: Value(d.storage),
              look: Value(d.look?.encode()),
              createdAt: now,
            ),
          );
      await _insertPackage(
        medicineId: medicineId,
        quantity: d.initialQuantity,
        unit: d.unit,
        expiresOn: d.expiresOn,
        now: now,
      );
      return medicineId;
    });
  }

  @override
  Future<String> addPackage({
    required String medicineId,
    required double quantity,
    required String unit,
    DateTime? expiresOn,
  }) async {
    if (!quantity.isFinite || quantity < 0) {
      throw const InvalidMedicineException(
        'Количество не может быть отрицательным',
      );
    }
    return _db.transaction(() async {
      final medicine = await _medicine(medicineId);
      if (medicine.archivedAt != null) {
        throw const InvalidMedicineException('Лекарство в архиве');
      }
      // One unit per medicine: quantities are summed and used up together.
      final own = medicine.unit;
      if (own != null && unit.trim() != own) {
        throw InvalidMedicineException('Единица должна быть «$own»');
      }
      return _insertPackage(
        medicineId: medicineId,
        quantity: normalizeQuantity(quantity),
        unit: unit.trim(),
        expiresOn: expiresOn == null ? null : dateOnly(expiresOn),
        now: _now(),
      );
    });
  }

  Future<MedicineRow> _medicine(String id) async {
    final row = await (_db.select(
      _db.medicines,
    )..where((m) => m.id.equals(id))).getSingleOrNull();
    if (row == null) throw MedicineNotFoundException(id);
    return row;
  }

  @override
  Future<void> updateMedicine(String medicineId, MedicineEdit edit) async {
    final name = edit.name.trim();
    if (name.isEmpty) {
      throw const InvalidMedicineException('Название обязательно');
    }
    final strength = edit.strength?.trim();
    final threshold = validateThreshold(edit.lowStockThreshold);
    await _medicine(medicineId);
    await (_db.update(
      _db.medicines,
    )..where((m) => m.id.equals(medicineId))).write(
      MedicinesCompanion(
        name: Value(name),
        form: Value(edit.form),
        strength: Value(strength == null || strength.isEmpty ? null : strength),
        lowStockThreshold: Value(threshold),
        category: Value(edit.category),
        storage: Value(edit.storage),
        look: Value(edit.look?.encode()),
      ),
    );
  }

  @override
  Future<void> archiveMedicine(String medicineId) {
    return _db.transaction(() async {
      final medicine = await _medicine(medicineId);
      if (medicine.archivedAt != null) return;
      await (_db.update(_db.medicines)..where((m) => m.id.equals(medicineId)))
          .write(MedicinesCompanion(archivedAt: Value(_now())));
      // End its schedules the way ending one does, so today's marks stay.
      final rows = await (_db.select(
        _db.schedules,
      )..where((s) => s.medicineId.equals(medicineId))).get();
      for (final row in rows) {
        final schedule = scheduleFromRow(row);
        final from = await effectiveFrom(_db, row.id, _now());
        if (!isCurrent(schedule, from)) continue;
        await (_db.update(
          _db.schedules,
        )..where((s) => s.id.equals(row.id))).write(
          SchedulesCompanion(endDate: Value(endDateFor(schedule, from))),
        );
      }
    });
  }

  @override
  Future<void> deleteMedicine(String medicineId) async {
    await _medicine(medicineId);
    // Packages, schedules, marks and history follow by cascade.
    await (_db.delete(
      _db.medicines,
    )..where((m) => m.id.equals(medicineId))).go();
  }

  @override
  Future<void> deletePackage(String packageId) {
    return _db.transaction(() async {
      final p = await (_db.select(
        _db.medicinePackages,
      )..where((x) => x.id.equals(packageId))).getSingleOrNull();
      if (p == null) throw PackageNotFoundException(packageId);
      final all = await (_db.select(
        _db.medicinePackages,
      )..where((x) => x.medicineId.equals(p.medicineId))).get();
      if (all.length < 2) {
        throw const InvalidMedicineException(
          'Единственную упаковку удалить нельзя: удалите лекарство',
        );
      }
      await (_db.delete(
        _db.medicinePackages,
      )..where((x) => x.id.equals(packageId))).go();
    });
  }

  @override
  Future<void> restoreMedicine(String medicineId) async {
    await _medicine(medicineId);
    await (_db.update(_db.medicines)..where((m) => m.id.equals(medicineId)))
        .write(const MedicinesCompanion(archivedAt: Value(null)));
  }

  @override
  Future<void> updatePackageExpiry(
    String packageId,
    DateTime? expiresOn,
  ) async {
    final changed =
        await (_db.update(
          _db.medicinePackages,
        )..where((p) => p.id.equals(packageId))).write(
          MedicinePackagesCompanion(
            expiresOn: Value(expiresOn == null ? null : dateOnly(expiresOn)),
          ),
        );
    if (changed == 0) throw PackageNotFoundException(packageId);
  }

  @override
  Future<void> correctQuantity({
    required String packageId,
    required double from,
    required double to,
  }) async {
    if (!to.isFinite || to < 0) {
      throw const InvalidMedicineException(
        'Остаток не может быть отрицательным',
      );
    }
    return _db.transaction(() async {
      final row = await (_db.select(
        _db.medicinePackages,
      )..where((p) => p.id.equals(packageId))).getSingleOrNull();
      if (row == null) throw PackageNotFoundException(packageId);
      if (row.quantity != normalizeQuantity(from)) {
        throw StaleQuantityException(expected: from, actual: row.quantity);
      }
      final next = normalizeQuantity(to);
      final delta = normalizeQuantity(next - row.quantity);
      if (delta == 0) return;
      await (_db.update(_db.medicinePackages)
            ..where((p) => p.id.equals(packageId)))
          .write(MedicinePackagesCompanion(quantity: Value(next)));
      await _insertTransaction(
        packageId: packageId,
        kind: TransactionKind.correction,
        delta: delta,
        quantityAfter: next,
        now: _now(),
      );
    });
  }

  /// Inserts the package and its `initial` history entry. Callers wrap this
  /// in a transaction.
  Future<String> _insertPackage({
    required String medicineId,
    required double quantity,
    required String unit,
    required DateTime? expiresOn,
    required DateTime now,
  }) async {
    final packageId = generateId();
    await _db
        .into(_db.medicinePackages)
        .insert(
          MedicinePackagesCompanion.insert(
            id: packageId,
            medicineId: medicineId,
            initialQuantity: quantity,
            quantity: quantity,
            unit: unit,
            expiresOn: Value(expiresOn),
            createdAt: now,
          ),
        );
    await _insertTransaction(
      packageId: packageId,
      kind: TransactionKind.initial,
      delta: quantity,
      quantityAfter: quantity,
      now: now,
    );
    return packageId;
  }

  @override
  Future<void> adjustQuantity({
    required String packageId,
    required double delta,
  }) async {
    if (!delta.isFinite || delta == 0) {
      throw ArgumentError.value(delta, 'delta', 'must be a non-zero number');
    }
    return _db.transaction(() async {
      final row = await (_db.select(
        _db.medicinePackages,
      )..where((p) => p.id.equals(packageId))).getSingleOrNull();
      if (row == null) throw PackageNotFoundException(packageId);
      // Throws before anything is written, so a refused change leaves no trace.
      final next = applyDelta(row.quantity, delta);
      await (_db.update(_db.medicinePackages)
            ..where((p) => p.id.equals(packageId)))
          .write(MedicinePackagesCompanion(quantity: Value(next)));
      await _insertTransaction(
        packageId: packageId,
        kind: delta > 0 ? TransactionKind.increase : TransactionKind.decrease,
        delta: normalizeQuantity(delta),
        quantityAfter: next,
        now: _now(),
      );
    });
  }

  @override
  Future<List<InventoryTransaction>> history(String packageId) async {
    final rows =
        await (_db.select(_db.inventoryTransactions)
              ..where((t) => t.packageId.equals(packageId))
              ..orderBy([
                // rowid breaks ties between entries written in the same instant
                (t) => OrderingTerm.desc(t.createdAt),
                (t) => OrderingTerm.desc(const CustomExpression<int>('rowid')),
              ]))
            .get();
    return [
      for (final t in rows)
        InventoryTransaction(
          id: t.id,
          packageId: t.packageId,
          kind: t.kind,
          delta: t.delta,
          quantityAfter: t.quantityAfter,
          createdAt: t.createdAt,
        ),
    ];
  }

  Future<void> _insertTransaction({
    required String packageId,
    required TransactionKind kind,
    required double delta,
    required double quantityAfter,
    required DateTime now,
  }) => _db
      .into(_db.inventoryTransactions)
      .insert(
        InventoryTransactionsCompanion.insert(
          id: generateId(),
          packageId: packageId,
          kind: kind,
          delta: delta,
          quantityAfter: quantityAfter,
          createdAt: now,
        ),
      );

  Medicine _toMedicine(MedicineRow m) => Medicine(
    id: m.id,
    name: m.name,
    form: m.form,
    strength: m.strength,
    unit: m.unit ?? '',
    archivedAt: m.archivedAt,
    lowStockThreshold: m.lowStockThreshold,
    category: m.category,
    storage: m.storage,
    look: PillLook.tryParse(m.look),
    createdAt: m.createdAt,
  );

  MedicinePackage _package(MedicinePackageRow p) => MedicinePackage(
    id: p.id,
    medicineId: p.medicineId,
    initialQuantity: p.initialQuantity,
    quantity: p.quantity,
    unit: p.unit,
    expiresOn: p.expiresOn,
    createdAt: p.createdAt,
  );
}
