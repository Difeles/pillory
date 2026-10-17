import 'dart:async';

import 'package:pillory/core/ids.dart';
import 'package:pillory/domain/errors.dart';
import 'package:pillory/domain/inventory_repository.dart';
import 'package:pillory/domain/inventory_rules.dart';
import 'package:pillory/domain/models.dart';

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
