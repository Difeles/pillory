import 'errors.dart';
import 'inventory_rules.dart';
import 'models.dart';

enum ScheduleKind { daily, weekdays, dates }

/// Input for a new intake schedule. [dose] is per intake and is separate from
/// the stock: "1 шт." per intake against 20 шт. in the cabinet.
class NewSchedule {
  const NewSchedule({
    required this.medicineId,
    required this.kind,
    required this.dose,
    required this.doseUnit,
    required this.startDate,
    this.weekdays = const {},
    this.dates = const [],
    this.endDate,
    this.times = const [],
  });

  final String medicineId;
  final ScheduleKind kind;
  final double dose;
  final String doseUnit;

  /// [DateTime.monday]..[DateTime.sunday]; used when [kind] is weekdays.
  final Set<int> weekdays;

  /// Used when [kind] is dates.
  final List<DateTime> dates;
  final DateTime startDate;
  final DateTime? endDate;

  /// Times of day, minutes from midnight. Empty means one untimed intake.
  final List<int> times;
}

class Schedule extends NewSchedule {
  const Schedule({
    required this.id,
    required this.createdAt,
    required super.medicineId,
    required super.kind,
    required super.dose,
    required super.doseUnit,
    required super.startDate,
    super.weekdays,
    super.dates,
    super.endDate,
    super.times,
  });

  final String id;
  final DateTime createdAt;
}

/// Returns [d] cleaned up (normalized dose, date-only dates, sorted dates) or
/// throws [InvalidScheduleException].
NewSchedule validateNewSchedule(NewSchedule d) {
  if (!d.dose.isFinite || d.dose <= 0) {
    throw const InvalidScheduleException('Дозировка должна быть больше нуля');
  }
  if (d.doseUnit.trim().isEmpty) {
    throw const InvalidScheduleException('Укажите единицу дозировки');
  }
  if (d.kind == ScheduleKind.weekdays &&
      (d.weekdays.isEmpty ||
          d.weekdays.any((w) => w < DateTime.monday || w > DateTime.sunday))) {
    throw const InvalidScheduleException('Выберите дни недели');
  }
  if (d.kind == ScheduleKind.dates && d.dates.isEmpty) {
    throw const InvalidScheduleException('Выберите даты');
  }
  final start = dateOnly(d.startDate);
  final end = d.endDate == null ? null : dateOnly(d.endDate!);
  if (end != null && end.isBefore(start)) {
    throw const InvalidScheduleException('Дата окончания раньше даты начала');
  }
  if (d.times.any((m) => m < 0 || m >= 24 * 60)) {
    throw const InvalidScheduleException('Некорректное время');
  }
  return NewSchedule(
    medicineId: d.medicineId,
    kind: d.kind,
    dose: normalizeQuantity(d.dose),
    doseUnit: d.doseUnit.trim(),
    weekdays: d.kind == ScheduleKind.weekdays ? d.weekdays : const {},
    dates: d.kind == ScheduleKind.dates
        ? ({for (final x in d.dates) dateOnly(x)}.toList()..sort())
        : const [],
    startDate: start,
    endDate: end,
    times: ({...d.times}.toList()..sort()),
  );
}

/// Whether [s] has an intake on [day].
bool occursOn(NewSchedule s, DateTime day) {
  final d = dateOnly(day);
  if (d.isBefore(dateOnly(s.startDate))) return false;
  if (s.endDate != null && d.isAfter(dateOnly(s.endDate!))) return false;
  return switch (s.kind) {
    ScheduleKind.daily => true,
    ScheduleKind.weekdays => s.weekdays.contains(d.weekday),
    ScheduleKind.dates => s.dates.any((x) => dateOnly(x) == d),
  };
}

/// The intakes of [s] on a scheduled day: one per time, or a single untimed
/// one (null).
List<int?> slotsOf(NewSchedule s) => s.times.isEmpty ? [null] : s.times;

enum IntakeStatus { pending, taken, skipped }

/// One scheduled intake on one day, with its mark.
class DayIntake {
  const DayIntake({
    required this.schedule,
    required this.medicineName,
    this.minuteOfDay,
    this.status = IntakeStatus.pending,
    this.deductionsTracked = false,
  });

  final Schedule schedule;
  final String medicineName;

  /// Which of the schedule's times this is; null for an untimed intake.
  final int? minuteOfDay;
  final IntakeStatus status;

  /// Whether a taken mark has its stock deductions recorded (see the
  /// `intake_logs` table); only then can it be undone.
  final bool deductionsTracked;

  bool get taken => status == IntakeStatus.taken;
  bool get skipped => status == IntakeStatus.skipped;
  bool get canReset => skipped || (taken && deductionsTracked);
}

/// Timed intakes first by time, then untimed ones, each by medicine name.
int compareIntakes(DayIntake a, DayIntake b) {
  final ta = a.minuteOfDay, tb = b.minuteOfDay;
  if (ta != tb) {
    if (ta == null) return 1;
    if (tb == null) return -1;
    return ta.compareTo(tb);
  }
  return a.medicineName.toLowerCase().compareTo(b.medicineName.toLowerCase());
}

/// How to take [dose] out of [packages]: packages in date, earliest expiry
/// first and expired ones last, so in-date stock is used up first. Throws
/// [InsufficientStockException] if the total is not enough; nothing is
/// deducted from a partial plan.
List<({String packageId, double amount})> planDeduction(
  List<MedicinePackage> packages,
  double dose,
  DateTime today,
) {
  final usable = packages.where((p) => p.quantity > 0).toList()
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
  final plan = <({String packageId, double amount})>[];
  var left = normalizeQuantity(dose);
  for (final p in usable) {
    if (left <= 0) break;
    final take = left < p.quantity ? left : p.quantity;
    plan.add((packageId: p.id, amount: take));
    left = normalizeQuantity(left - take);
  }
  if (left > 0) {
    final total = packages.fold(0.0, (s, p) => s + p.quantity);
    throw InsufficientStockException(current: total, delta: -dose);
  }
  return plan;
}

abstract class ScheduleRepository {
  /// Intakes scheduled for [day], with their marks; re-emits on change.
  Stream<List<DayIntake>> watchDay(DateTime day);

  /// Intakes of each day in [from]..[to] that has any, by day; re-emits on
  /// change.
  Stream<Map<DateTime, List<DayIntake>>> watchHistory(
    DateTime from,
    DateTime to,
  );

  /// Returns the new schedule id. Throws [InvalidScheduleException].
  Future<String> createSchedule(NewSchedule draft);

  /// Marks the intake of [scheduleId] at [minuteOfDay] (null if untimed) on
  /// [day] as taken and deducts one dose from stock, recording inventory
  /// transactions and the exact deductions, atomically. Already taken: does
  /// nothing. A skipped intake can be taken. Other times of the same schedule
  /// are unaffected. Throws [InsufficientStockException] (nothing written) if
  /// stock is short.
  Future<void> markTaken({
    required String scheduleId,
    required DateTime day,
    int? minuteOfDay,
  });

  /// Marks the intake as skipped; stock is untouched. Already skipped: does
  /// nothing. Throws [IntakeStateException] if it is taken (reset it first).
  Future<void> markSkipped({
    required String scheduleId,
    required DateTime day,
    int? minuteOfDay,
  });

  /// Returns a taken or skipped intake to unmarked. Undoing a taken mark gives
  /// back exactly what it took, from the same packages, once, atomically.
  /// Not marked: does nothing. Throws [UntrackedIntakeException] for a taken
  /// mark without recorded deductions (nothing changes).
  Future<void> resetMark({
    required String scheduleId,
    required DateTime day,
    int? minuteOfDay,
  });
}
