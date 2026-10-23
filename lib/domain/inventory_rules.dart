import 'errors.dart';
import 'models.dart';

/// Quantities are fractional (ml, half a tablet). Rounding to 3 decimals keeps
/// repeated additions from accumulating binary float noise.
double normalizeQuantity(double value) => (value * 1000).round() / 1000;

/// New quantity after applying [delta], or [InsufficientStockException] if it
/// would go below zero.
double applyDelta(double current, double delta) {
  final next = normalizeQuantity(current + delta);
  if (next < 0) {
    throw InsufficientStockException(current: current, delta: delta);
  }
  return next;
}

/// Drops the time of day, so an expiry date cannot shift across time zones.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isExpired(DateTime? expiresOn, DateTime now) =>
    expiresOn != null && dateOnly(expiresOn).isBefore(dateOnly(now));

/// Returns [draft] cleaned up (trimmed text, normalized quantity, date only),
/// or throws [InvalidMedicineException].
NewMedicine validateNewMedicine(NewMedicine draft) {
  final name = draft.name.trim();
  if (name.isEmpty) {
    throw const InvalidMedicineException('Название обязательно');
  }
  if (!draft.initialQuantity.isFinite || draft.initialQuantity < 0) {
    throw const InvalidMedicineException(
      'Количество не может быть отрицательным',
    );
  }
  final size = draft.packSize;
  if (size != null &&
      (!size.isFinite ||
          normalizeQuantity(size) < normalizeQuantity(draft.initialQuantity))) {
    throw const InvalidMedicineException(
      'В упаковке не могло быть меньше, чем осталось сейчас',
    );
  }
  final unit = draft.unit.trim();
  if (unit.isEmpty) {
    throw const InvalidMedicineException('Укажите единицу учёта');
  }
  final strength = draft.strength?.trim();
  final threshold = validateThreshold(draft.lowStockThreshold);
  return NewMedicine(
    look: draft.look,
    lowStockThreshold: threshold,
    category: draft.category,
    storage: draft.storage,
    name: name,
    form: draft.form,
    strength: (strength == null || strength.isEmpty) ? null : strength,
    initialQuantity: normalizeQuantity(draft.initialQuantity),
    packSize: size == null ? null : normalizeQuantity(size),
    unit: unit,
    expiresOn: draft.expiresOn == null ? null : dateOnly(draft.expiresOn!),
  );
}

/// A low-stock threshold must be a number of 0 or more (or absent).
double? validateThreshold(double? value) {
  if (value == null) return null;
  if (!value.isFinite || value < 0) {
    throw const InvalidMedicineException('Порог не может быть отрицательным');
  }
  return normalizeQuantity(value);
}

/// The packages with something left, in the order they are used up: in date
/// before expired, earliest expiry first, then the oldest.
List<MedicinePackage> inUseOrder(
  Iterable<MedicinePackage> packages,
  DateTime today,
) => packages.where((p) => p.quantity > 0).toList()
  ..sort((a, b) {
    final ea = isExpired(a.expiresOn, today),
        eb = isExpired(b.expiresOn, today);
    if (ea != eb) return ea ? 1 : -1;
    final xa = a.expiresOn, xb = b.expiresOn;
    if (xa != xb) {
      if (xa == null) return 1;
      if (xb == null) return -1;
      return xa.compareTo(xb);
    }
    return a.createdAt.compareTo(b.createdAt);
  });
