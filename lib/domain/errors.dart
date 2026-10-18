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

/// Input does not satisfy the schedule rules (no days, bad dose, bad range).
class InvalidScheduleException implements Exception {
  const InvalidScheduleException(this.message);
  final String message;

  @override
  String toString() => 'InvalidScheduleException: $message';
}

class ScheduleNotFoundException implements Exception {
  const ScheduleNotFoundException(this.scheduleId);
  final String scheduleId;

  @override
  String toString() => 'ScheduleNotFoundException: $scheduleId';
}

/// The mark cannot move to the requested state from its current one.
class IntakeStateException implements Exception {
  const IntakeStateException(this.message);
  final String message;

  @override
  String toString() => 'IntakeStateException: $message';
}

/// A taken mark made before deductions were recorded: its stock cannot be
/// restored exactly, so it cannot be undone.
class UntrackedIntakeException extends IntakeStateException {
  const UntrackedIntakeException()
    : super('Списания для этой отметки не сохранены');
}

/// The schedule was already changed or ended: there is nothing left to edit.
class ScheduleEndedException implements Exception {
  const ScheduleEndedException(this.scheduleId);
  final String scheduleId;

  @override
  String toString() => 'ScheduleEndedException: $scheduleId';
}

class MedicineNotFoundException implements Exception {
  const MedicineNotFoundException(this.medicineId);
  final String medicineId;

  @override
  String toString() => 'MedicineNotFoundException: $medicineId';
}

/// A stock correction was made against a quantity that has since changed.
class StaleQuantityException implements Exception {
  const StaleQuantityException({required this.expected, required this.actual});
  final double expected;
  final double actual;

  @override
  String toString() =>
      'StaleQuantityException: expected $expected, actual $actual';
}
