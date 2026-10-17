import 'medicine_form.dart';

/// The drug itself: what it is called and what it is. Holds no quantities.
class Medicine {
  const Medicine({
    required this.id,
    required this.name,
    required this.createdAt,
    this.form,
    this.strength,
  });

  final String id;
  final String name;
  final MedicineForm? form;

  /// Dosage or concentration as the user wrote it, e.g. "500 мг".
  final String? strength;
  final DateTime createdAt;
}

/// One physical package of a medicine. A medicine can have several, each with
/// its own expiry date and remaining quantity.
class MedicinePackage {
  const MedicinePackage({
    required this.id,
    required this.medicineId,
    required this.initialQuantity,
    required this.quantity,
    required this.unit,
    required this.createdAt,
    this.expiresOn,
  });

  final String id;
  final String medicineId;
  final double initialQuantity;
  final double quantity;
  final String unit;

  /// Calendar date only, no time of day or time zone.
  final DateTime? expiresOn;
  final DateTime createdAt;
}

enum TransactionKind { initial, increase, decrease }

/// One entry in a package's stock history. Never edited after it is written.
class InventoryTransaction {
  const InventoryTransaction({
    required this.id,
    required this.packageId,
    required this.kind,
    required this.delta,
    required this.quantityAfter,
    required this.createdAt,
  });

  final String id;
  final String packageId;
  final TransactionKind kind;

  /// Signed change; the initial entry carries the starting quantity.
  final double delta;
  final double quantityAfter;
  final DateTime createdAt;
}

/// A medicine with its packages: the shape the cabinet list shows.
class MedicineStock {
  const MedicineStock({required this.medicine, required this.packages});

  final Medicine medicine;

  /// Oldest first.
  final List<MedicinePackage> packages;

  /// The package the +/- buttons act on. With one package that is the only
  /// one; managing several is a later screen.
  MedicinePackage get primaryPackage => packages.first;

  /// Sum over packages. Only meaningful when all packages share one unit.
  double get totalQuantity => packages.fold(0.0, (sum, p) => sum + p.quantity);

  String get unit => primaryPackage.unit;

  /// Earliest expiry among packages that still have stock.
  DateTime? get nearestExpiry {
    final dates = [
      for (final p in packages)
        if (p.quantity > 0 && p.expiresOn != null) p.expiresOn!,
    ]..sort();
    return dates.isEmpty ? null : dates.first;
  }
}

/// Input for creating a medicine together with its first package.
class NewMedicine {
  const NewMedicine({
    required this.name,
    required this.initialQuantity,
    required this.unit,
    this.form,
    this.strength,
    this.expiresOn,
  });

  final String name;
  final MedicineForm? form;
  final String? strength;
  final double initialQuantity;
  final String unit;
  final DateTime? expiresOn;
}
