/// A stock change would take a package below zero.
class InsufficientStockException implements Exception {
  const InsufficientStockException({
    required this.current,
    required this.delta,
  });
  final double current;
  final double delta;

  @override
  String toString() =>
      'InsufficientStockException: cannot change $current by $delta';
}

/// Input does not satisfy the medicine rules (blank name, bad quantity).
class InvalidMedicineException implements Exception {
  const InvalidMedicineException(this.message);
  final String message;

  @override
  String toString() => 'InvalidMedicineException: $message';
}

class PackageNotFoundException implements Exception {
  const PackageNotFoundException(this.packageId);
  final String packageId;

  @override
  String toString() => 'PackageNotFoundException: $packageId';
}
