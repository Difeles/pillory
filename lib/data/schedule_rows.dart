import 'package:drift/drift.dart';

import '../domain/inventory_rules.dart';
import '../domain/schedule.dart';
import 'app_database.dart';
import 'tables.dart';

const _dates = DateOnlyConverter();

Schedule scheduleFromRow(ScheduleRow r) => Schedule(
  id: r.id,
  createdAt: r.createdAt,
  medicineId: r.medicineId,
  kind: r.kind,
  dose: r.dose,
  doseUnit: r.doseUnit,
  weekdays: {
    for (final w in r.weekdays.split(','))
      if (w.isNotEmpty) int.parse(w),
  },
  dates: [
    for (final x in r.dates.split(','))
      if (x.isNotEmpty) _dates.fromSql(x),
  ],
  mealRelation: r.mealRelation,
  startDate: r.startDate,
  endDate: r.endDate,
  times: [
    for (final x in r.times.split(','))
      if (x.isNotEmpty) int.parse(x),
  ],
);

/// The first day a change to a schedule can take effect: [today], or the day
/// after if [today] already carries a taken or skipped mark of it.
Future<DateTime> effectiveFrom(
  AppDatabase db,
  String scheduleId,
  DateTime today,
) async {
  final marked =
      await (db.select(db.intakeLogs)..where(
            (l) =>
                l.scheduleId.equals(scheduleId) &
                l.day.equalsValue(dateOnly(today)) &
                l.status.equalsValue(IntakeStatus.pending).not(),
          ))
          .get();
  final d = dateOnly(today);
  return marked.isEmpty ? d : DateTime(d.year, d.month, d.day + 1);
}
