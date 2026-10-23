import 'models.dart';

/// Persistent storage of the home medicine cabinet. Implemented in `data/`.
abstract class InventoryRepository {
  /// All medicines in the cabinet (not archived) with their packages, by
  /// name; re-emits on every change.
  Stream<List<MedicineStock>> watchStock();

  /// Archived medicines with their packages, by name; re-emits on change.
  Stream<List<MedicineStock>> watchArchived();

  /// Creates the medicine, its first package and the initial history entry in
  /// one transaction. Returns the new medicine id.
  Future<String> createMedicine(NewMedicine draft);

  /// Changes the name, form and strength. Intakes already marked keep the
  /// values they were marked with. Throws [InvalidMedicineException] for an
  /// empty name and [MedicineNotFoundException].
  Future<void> updateMedicine(String medicineId, MedicineEdit edit);

  /// Archives a medicine: it leaves the cabinet and its current schedules end
  /// (so their reminders stop). Nothing is deleted; past intakes, packages and
  /// stock history stay. Archiving an archived medicine does nothing.
  Future<void> archiveMedicine(String medicineId);

  /// Returns a medicine to the cabinet. Its ended schedules do not resume.
  Future<void> restoreMedicine(String medicineId);

  /// Deletes a medicine for good with its packages, history, schedules and
  /// marks (for one made by mistake; archiving keeps them). Throws
  /// [MedicineNotFoundException].
  Future<void> deleteMedicine(String medicineId);

  /// Deletes a package with its history. A medicine keeps at least one
  /// package: deleting the last throws [InvalidMedicineException]. Throws
  /// [PackageNotFoundException].
  Future<void> deletePackage(String packageId);

  /// Adds another package (e.g. a different expiry date) to a medicine. The
  /// unit must be the medicine's own; throws [InvalidMedicineException]
  /// otherwise, for a negative quantity and for an archived medicine.
  ///
  /// [quantity] is what is in the package now; [packSize] is what it held new
  /// (the same when null, more for an opened package). A [packSize] below
  /// [quantity] throws [InvalidMedicineException].
  Future<String> addPackage({
    required String medicineId,
    required double quantity,
    required String unit,
    DateTime? expiresOn,
    double? packSize,
  });

  /// Changes a package quantity by [delta] and records the change in history,
  /// atomically. Throws `InsufficientStockException` if it would go below
  /// zero; nothing is written in that case.
  Future<void> adjustQuantity({
    required String packageId,
    required double delta,
  });

  /// Sets or clears the expiry date; the quantity and history are untouched.
  Future<void> updatePackageExpiry(String packageId, DateTime? expiresOn);

  /// Sets the quantity of a package to [to], recording a `correction` in its
  /// history, atomically. [from] is the quantity the caller saw: if the stock
  /// has changed since, throws [StaleQuantityException] and writes nothing.
  /// A negative [to] is refused ([InvalidMedicineException]); [to] equal to
  /// the current quantity writes nothing.
  Future<void> correctQuantity({
    required String packageId,
    required double from,
    required double to,
  });

  /// History of one package, newest first.
  Future<List<InventoryTransaction>> history(String packageId);
}
