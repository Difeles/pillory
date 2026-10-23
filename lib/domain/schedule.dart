import 'errors.dart';
import 'inventory_rules.dart';
import 'medicine_form.dart';
import 'pill_look.dart';
import 'models.dart';
import 'reminders.dart';

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
    this.mealRelation,
  });

  final String medicineId;

  /// Null: any time relative to meals.
  final MealRelation? mealRelation;
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
    super.mealRelation,
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
    mealRelation: d.mealRelation,
  );
}

/// [d] a whole number of [years] later: the same course a year on. The
/// start and the end move together, a date that does not exist then (29
/// February) falls on the next day.
NewSchedule shiftedByYears(NewSchedule d, int years) {
  DateTime shift(DateTime x) => DateTime(x.year + years, x.month, x.day);
  return NewSchedule(
    medicineId: d.medicineId,
    kind: d.kind,
    dose: d.dose,
    doseUnit: d.doseUnit,
    weekdays: d.weekdays,
    dates: [for (final x in d.dates) shift(x)],
    startDate: shift(d.startDate),
    endDate: d.endDate == null ? null : shift(d.endDate!),
    times: d.times,
    mealRelation: d.mealRelation,
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
    this.medicineForm,
    this.medicineStrength,
    this.medicineLook,
    this.minuteOfDay,
    this.status = IntakeStatus.pending,
    this.deductionsTracked = false,
  });

  final Schedule schedule;

  /// The medicine as it was when the intake was marked, or as it is now for
  /// one that is not marked.
  final String medicineName;
  final MedicineForm? medicineForm;
  final String? medicineStrength;

  /// The medicine's pill drawing as it is now (not part of the snapshot).
  final PillLook? medicineLook;

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

/// Whether [s] still has days from [day] on that nothing has closed: no end,
/// or an end that is not before [day] and not before the start (a schedule
/// ended before its first day never took effect).
bool isCurrent(NewSchedule s, DateTime day) {
  final e = s.endDate;
  if (e == null) return true;
  final end = dateOnly(e);
  return !end.isBefore(dateOnly(s.startDate)) && !end.isBefore(dateOnly(day));
}

/// New settings for an existing schedule. The medicine and the dose unit are
/// deliberately not here: history stays attached to the medicine.
class ScheduleEdit {
  const ScheduleEdit({
    required this.kind,
    required this.dose,
    required this.times,
    this.weekdays = const {},
    this.dates = const [],
    this.startDate,
    this.endDate,
    this.mealRelation,
  });

  final MealRelation? mealRelation;
  final ScheduleKind kind;
  final double dose;
  final List<int> times;
  final Set<int> weekdays;
  final List<DateTime> dates;

  /// Used only while the schedule has not started; afterwards the new
  /// settings start on the effective day.
  final DateTime? startDate;
  final DateTime? endDate;
}

sealed class ScheduleEditPlan {
  const ScheduleEditPlan();
}

/// Nothing that matters changed: no new version.
class ScheduleUnchanged extends ScheduleEditPlan {
  const ScheduleUnchanged();
}

/// Not started yet, so there is no history to protect: edit in place.
class ScheduleRewrite extends ScheduleEditPlan {
  const ScheduleRewrite(this.draft);
  final NewSchedule draft;
}

/// Started: the old schedule ends the day before the new one starts.
class ScheduleSplit extends ScheduleEditPlan {
  const ScheduleSplit(this.draft, this.closeOn);
  final NewSchedule draft;
  final DateTime closeOn;
}

/// What an edit of [old] does when it takes effect on [from]. Throws
/// [ScheduleEndedException] if [old] has nothing left from [from] on and
/// [InvalidScheduleException] for invalid settings.
ScheduleEditPlan planScheduleEdit(
  Schedule old,
  ScheduleEdit edit,
  DateTime from,
) {
  if (!isCurrent(old, from)) throw ScheduleEndedException(old.id);
  final started = dateOnly(old.startDate).isBefore(from);
  final byDates = edit.kind == ScheduleKind.dates;
  // Past dates belong to the old version, which stays as it was.
  final dates = [
    for (final d in edit.dates)
      if (!started || !dateOnly(d).isBefore(from)) d,
  ];
  final earliest = dates.isEmpty
      ? null
      : (dates.map(dateOnly).toList()..sort()).first;
  final draft = validateNewSchedule(
    NewSchedule(
      medicineId: old.medicineId,
      kind: edit.kind,
      dose: edit.dose,
      doseUnit: old.doseUnit,
      weekdays: edit.weekdays,
      dates: dates,
      startDate: started
          ? (byDates ? earliest ?? from : from)
          : (byDates ? earliest : edit.startDate) ?? old.startDate,
      endDate: byDates ? null : edit.endDate,
      times: edit.times,
      mealRelation: edit.mealRelation,
    ),
  );

  bool same<T>(Iterable<T> a, Iterable<T> b) =>
      a.length == b.length && a.toSet().containsAll(b);
  final oldDates = [
    for (final d in old.dates)
      if (!started || !dateOnly(d).isBefore(from)) dateOnly(d),
  ];
  final unchanged =
      draft.kind == old.kind &&
      draft.dose == old.dose &&
      draft.mealRelation == old.mealRelation &&
      same(draft.times, old.times) &&
      same(draft.weekdays, old.weekdays) &&
      same(draft.dates, oldDates) &&
      draft.endDate == (old.endDate == null ? null : dateOnly(old.endDate!)) &&
      (started || draft.startDate == dateOnly(old.startDate));
  if (unchanged) return const ScheduleUnchanged();
  if (!started) return ScheduleRewrite(draft);
  return ScheduleSplit(draft, DateTime(from.year, from.month, from.day - 1));
}

/// The last day [s] keeps its intakes once it is ended with effect from
/// [from]; before its start for a schedule that never began.
DateTime endDateFor(Schedule s, DateTime from) {
  final start = dateOnly(s.startDate);
  final day = start.isBefore(from) ? from : start;
  return DateTime(day.year, day.month, day.day - 1);
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

  /// The schedules with their medicine names and the intakes already settled
  /// (taken or skipped) on or after [from]; re-emits on change.
  Stream<ReminderSource> watchReminderSource(DateTime from);

  /// Returns the new schedule id. Throws [InvalidScheduleException].
  Future<String> createSchedule(NewSchedule draft);

  /// Changes a schedule and returns the day the change takes effect: today,
  /// or tomorrow if today already has a mark on it. A schedule that has
  /// started is closed the day before and continued as a new one, so past
  /// days, marks and doses stay as they were; one that has not started is
  /// edited in place. Nothing is written if nothing changed. Throws
  /// [ScheduleEndedException] if there is nothing left to change and
  /// [InvalidScheduleException] for invalid settings.
  Future<DateTime> updateSchedule(String scheduleId, ScheduleEdit edit);

  /// Ends a schedule from the same effective day as [updateSchedule] (so
  /// today's marks stay visible) and returns that day. Past intakes and their
  /// statuses are kept. Ending an ended schedule does nothing.
  Future<DateTime> endSchedule(String scheduleId);

  /// Deletes a schedule for good with its marks (for one made by mistake;
  /// ending keeps the past). What its taken intakes deducted goes back to
  /// stock. Throws [ScheduleNotFoundException].
  Future<void> deleteSchedule(String scheduleId);

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
