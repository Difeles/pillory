import 'models.dart';

/// Persistent storage of the home medicine cabinet. Implemented in `data/`.
abstract class InventoryRepository {
  /// All medicines with their packages, by name; re-emits on every change.
  Stream<List<MedicineStock>> watchStock();

  /// Creates the medicine, its first package and the initial history entry in
  /// one transaction. Returns the new medicine id.
  Future<String> createMedicine(NewMedicine draft);

  /// Adds another package (e.g. a different expiry date) to a medicine.
  Future<String> addPackage({
    required String medicineId,
    required double quantity,
    required String unit,
    DateTime? expiresOn,
  });

  /// Changes a package quantity by [delta] and records the change in history,
  /// atomically. Throws `InsufficientStockException` if it would go below
  /// zero; nothing is written in that case.
  Future<void> adjustQuantity({
    required String packageId,
    required double delta,
  });

  /// History of one package, newest first.
  Future<List<InventoryTransaction>> history(String packageId);
}
