import 'inventory_rules.dart';
import 'models.dart';

/// A package is "expiring soon" from today up to this many days ahead,
/// inclusive.
const expiringSoonDays = 30;

/// Without an own threshold, stock is "low" at this share of the biggest
/// package (by its initial quantity) or less.
const lowStockShare = 0.2;

enum PackageStatus { ok, empty, expired, expiringSoon }

/// The state of one package on [today]. An empty package is just empty,
/// whatever its date says: there is nothing left to warn about.
PackageStatus packageStatus(MedicinePackage p, DateTime today) {
  if (p.quantity <= 0) return PackageStatus.empty;
  final expiry = p.expiresOn;
  if (expiry == null) return PackageStatus.ok;
  final t = dateOnly(today);
  final day = dateOnly(expiry);
  // "Good until" a date includes that date, so only an earlier one is expired.
  if (day.isBefore(t)) return PackageStatus.expired;
  // Calendar arithmetic, not a Duration: a clock change must not shift it.
  if (day.isAfter(DateTime(t.year, t.month, t.day + expiringSoonDays))) {
    return PackageStatus.ok;
  }
  return PackageStatus.expiringSoon;
}

/// Whole calendar days from [today] to [date] (negative if earlier).
int daysUntil(DateTime date, DateTime today) {
  final d = dateOnly(date), t = dateOnly(today);
  // UTC, so a 23- or 25-hour day around a clock change still counts as one.
  return DateTime.utc(
    d.year,
    d.month,
    d.day,
  ).difference(DateTime.utc(t.year, t.month, t.day)).inDays;
}

/// The one problem a card shows, in priority order.
enum StockProblem { expired, expiringSoon, out, low }

enum StockFilter { all, lowOrOut, expiringSoon, expired }

/// How a medicine stands on a given day. Only packages in the medicine's
/// unit count; packages in another unit are left out of everything.
class StockAssessment {
  StockAssessment._({
    required this.stock,
    required this.usable,
    required this.threshold,
    required this.earliestExpired,
    required this.nearestExpiring,
  });

  final MedicineStock stock;

  /// Quantity in date: counted packages that are not expired.
  final double usable;

  /// At or below this (and above zero) the stock is low.
  final double threshold;

  /// Earliest expiry date among expired packages that still have stock.
  final DateTime? earliestExpired;

  /// Nearest expiry date among soon-to-expire packages with stock.
  final DateTime? nearestExpiring;

  bool get isOut => usable <= 0;
  bool get isLow => !isOut && usable <= threshold;
  bool get hasExpired => earliestExpired != null;
  bool get hasExpiringSoon => nearestExpiring != null;

  StockProblem? get problem {
    if (hasExpired) return StockProblem.expired;
    if (hasExpiringSoon) return StockProblem.expiringSoon;
    if (isOut) return StockProblem.out;
    if (isLow) return StockProblem.low;
    return null;
  }

  bool matches(StockFilter f) => switch (f) {
    StockFilter.all => true,
    StockFilter.lowOrOut => isOut || isLow,
    StockFilter.expiringSoon => hasExpiringSoon,
    StockFilter.expired => hasExpired,
  };

  /// How far below its threshold the stock is; 0 for none.
  double get fill => threshold <= 0 ? 0 : usable / threshold;
}

StockAssessment assess(MedicineStock stock, DateTime today) {
  var usable = 0.0;
  var biggest = 0.0;
  DateTime? expired, soon;
  for (final p in stock.counted) {
    if (p.initialQuantity > biggest) biggest = p.initialQuantity;
    switch (packageStatus(p, today)) {
      case PackageStatus.ok:
        usable += p.quantity;
      case PackageStatus.expiringSoon:
        usable += p.quantity;
        final d = dateOnly(p.expiresOn!);
        if (soon == null || d.isBefore(soon)) soon = d;
      case PackageStatus.expired:
        final d = dateOnly(p.expiresOn!);
        if (expired == null || d.isBefore(expired)) expired = d;
      case PackageStatus.empty:
        break;
    }
  }
  return StockAssessment._(
    stock: stock,
    usable: normalizeQuantity(usable),
    threshold: normalizeQuantity(
      stock.medicine.lowStockThreshold ?? biggest * lowStockShare,
    ),
    earliestExpired: expired,
    nearestExpiring: soon,
  );
}

/// The medicines of [stocks] that match [filter], assessed on [today]. With a
/// filter on they are ordered by how urgent the problem is; with [all] the
/// given order (by name) is kept. Archived medicines are never included.
List<StockAssessment> filterStock(
  List<MedicineStock> stocks,
  StockFilter filter,
  DateTime today,
) {
  final list = [
    for (final s in stocks)
      if (s.medicine.archivedAt == null) assess(s, today),
  ].where((a) => a.matches(filter)).toList();
  int byName(StockAssessment a, StockAssessment b) {
    final c = a.stock.medicine.name.toLowerCase().compareTo(
      b.stock.medicine.name.toLowerCase(),
    );
    return c != 0 ? c : a.stock.medicine.id.compareTo(b.stock.medicine.id);
  }

  int by(StockAssessment a, StockAssessment b, int Function() key) {
    final c = key();
    return c != 0 ? c : byName(a, b);
  }

  switch (filter) {
    case StockFilter.all:
      break;
    case StockFilter.expired:
      list.sort(
        (a, b) =>
            by(a, b, () => a.earliestExpired!.compareTo(b.earliestExpired!)),
      );
    case StockFilter.expiringSoon:
      list.sort(
        (a, b) =>
            by(a, b, () => a.nearestExpiring!.compareTo(b.nearestExpiring!)),
      );
    case StockFilter.lowOrOut:
      list.sort(
        (a, b) => by(a, b, () {
          if (a.isOut != b.isOut) return a.isOut ? -1 : 1;
          return a.fill.compareTo(b.fill);
        }),
      );
  }
  return list;
}
