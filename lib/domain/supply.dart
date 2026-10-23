import 'inventory_rules.dart';
import 'models.dart';
import 'reminders.dart';
import 'schedule.dart';
import 'stock_status.dart';

/// Below this many days of supply a medicine is worth buying.
const supplyWarnDays = 7;

/// How far the usable stock of a medicine goes at the planned intakes.
class SupplyForecast {
  const SupplyForecast({
    required this.days,
    required this.coversPlan,
    required this.beyondHorizon,
  });

  /// Whole days from today that are fully covered: 0 means not even today.
  final int days;

  /// Every planned intake of every finite schedule is covered and nothing
  /// more is planned.
  final bool coversPlan;

  /// The stock outlasts the look-ahead of [supplyHorizonDays].
  final bool beyondHorizon;
}

/// How many days ahead the forecast looks.
const supplyHorizonDays = 365;

/// Walks the intakes of the running [schedules] day by day from [today] and
/// finds the day the usable stock of [stock] no longer covers a dose.
///
/// Null when nothing is planned for this medicine in its unit, so there is
/// nothing to base a forecast on.
SupplyForecast? forecastSupply(
  MedicineStock stock,
  Iterable<Schedule> schedules,
  DateTime today,
) {
  final mine = [
    for (final s in schedules)
      if (s.medicineId == stock.medicine.id && s.doseUnit == stock.unit) s,
  ];
  final from = dateOnly(today);
  var left = assess(stock, from).usable;
  var planned = false;
  for (var d = 0; d < supplyHorizonDays; d++) {
    final day = DateTime(from.year, from.month, from.day + d);
    var need = 0.0;
    for (final s in mine) {
      if (occursOn(s, day)) need += s.dose * slotsOf(s).length;
    }
    if (need > 0) planned = true;
    if (need > left) {
      return SupplyForecast(days: d, coversPlan: false, beyondHorizon: false);
    }
    left -= need;
  }
  if (!planned) return null;
  // Nothing ran out in a year: either the plan is over or it goes on.
  final open = mine.any(
    (s) => s.kind != ScheduleKind.dates && s.endDate == null,
  );
  return SupplyForecast(
    days: supplyHorizonDays,
    coversPlan: !open,
    beyondHorizon: open,
  );
}

/// A course ([medicineName]) whose last day is [endsOn].
typedef EndingCourse = ({
  String medicineName,
  DateTime endsOn,
  Schedule schedule,
});

/// Courses with an end date that falls within [days] days of [today]
/// (including today), soonest first. A schedule that another one of the same
/// medicine takes over the next day (a stage of a stepped scheme, a repeated
/// course) is not ending.
List<EndingCourse> endingCourses(
  Iterable<ReminderSchedule> schedules,
  DateTime today, {
  int days = 2,
}) {
  final all = schedules.toList();
  final from = dateOnly(today);
  final to = DateTime(from.year, from.month, from.day + days);
  bool continued(Schedule s, DateTime end) {
    final next = DateTime(end.year, end.month, end.day + 1);
    return all.any(
      (o) =>
          o.schedule.id != s.id &&
          o.schedule.medicineId == s.medicineId &&
          dateOnly(o.schedule.startDate) == next,
    );
  }

  final list = <EndingCourse>[
    for (final r in all)
      if (r.schedule.endDate case final end?
          when !dateOnly(end).isBefore(from) &&
              !dateOnly(end).isAfter(to) &&
              !continued(r.schedule, dateOnly(end)))
        (
          medicineName: r.medicineName,
          endsOn: dateOnly(end),
          schedule: r.schedule,
        ),
  ]..sort((a, b) => a.endsOn.compareTo(b.endsOn));
  return list;
}
