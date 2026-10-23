import 'dart:convert';

import 'inventory_rules.dart';
import 'reminder_scheduler.dart' show ReminderStyle;
import 'schedule.dart';

/// How many future reminders are kept scheduled. iOS allows 64 pending local
/// notifications per app, so this stays below it.
const reminderLimit = 60;

/// Technical limit of the planning horizon for recurring schedules. A
/// schedule yields at most [reminderLimit] reminders, and the sparsest one
/// (weekly) reaches that in about 420 days, so this never cuts a plan short.
/// A schedule on specific dates ignores it: every future date counts.
const reminderMaxDays = 730;

/// Flips a reminder's id to the id of its follow-up (stays a 31-bit value).
const followUpBit = 0x40000000;

/// A schedule with the name of its medicine: what a reminder is made from.
class ReminderSchedule {
  const ReminderSchedule(this.schedule, this.medicineName);

  final Schedule schedule;
  final String medicineName;
}

/// Input of [planReminders]: the schedules and which of their intakes are
/// already settled (taken or skipped) from the planning day on.
class ReminderSource {
  const ReminderSource({required this.schedules, this.settled = const {}});

  final List<ReminderSchedule> schedules;

  /// [intakeKey]s of settled intakes.
  final Set<String> settled;
}

String intakeKey(String scheduleId, DateTime day, int? minuteOfDay) {
  final d = dateOnly(day);
  return '$scheduleId|${d.year}-${d.month}-${d.day}|${minuteOfDay ?? -1}';
}

class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.fireAt,
    required this.scheduleId,
    required this.day,
    required this.minuteOfDay,
    required this.medicineName,
    required this.dose,
    required this.doseUnit,
  });

  /// Stable for one intake, so planning the same intake again replaces it.
  final int id;

  /// Wall-clock time in the device's time zone.
  final DateTime fireAt;
  final String scheduleId;
  final DateTime day;
  final int minuteOfDay;
  final String medicineName;
  final double dose;
  final String doseUnit;

  OpenIntakeRequest get request => OpenIntakeRequest(
    scheduleId: scheduleId,
    day: day,
    minuteOfDay: minuteOfDay,
  );
}

/// The nearest [limit] future timed intakes that are not yet taken or
/// skipped, soonest first. Untimed intakes get no reminder.
List<PlannedReminder> planReminders(
  ReminderSource source,
  DateTime now, {
  int limit = reminderLimit,
  int maxDays = reminderMaxDays,
}) {
  final today = dateOnly(now);
  final all = <PlannedReminder>[];
  for (final rs in source.schedules) {
    final s = rs.schedule;
    final times = ({...s.times}.toList()..sort());
    var count = 0;
    // One schedule can never need more than [limit] of the nearest ones.
    days:
    for (final day in _candidateDays(s, today, maxDays)) {
      for (final t in times) {
        final fire = DateTime(day.year, day.month, day.day, t ~/ 60, t % 60);
        if (!fire.isAfter(now)) continue;
        if (source.settled.contains(intakeKey(s.id, day, t))) continue;
        all.add(
          PlannedReminder(
            id: _id(intakeKey(s.id, day, t)),
            fireAt: fire,
            scheduleId: s.id,
            day: day,
            minuteOfDay: t,
            medicineName: rs.medicineName,
            dose: s.dose,
            doseUnit: s.doseUnit,
          ),
        );
        if (++count >= limit) break days;
      }
    }
  }
  all.sort((a, b) {
    final c = a.fireAt.compareTo(b.fireAt);
    return c != 0 ? c : a.id.compareTo(b.id);
  });
  // An id collision (31-bit hash) drops the later reminder, never duplicates.
  final seen = <int>{};
  return [
    for (final r in all)
      if (seen.add(r.id)) r,
  ].take(limit).toList();
}

/// Scheduled days of [s] from [today] on, in order.
Iterable<DateTime> _candidateDays(
  Schedule s,
  DateTime today,
  int maxDays,
) sync* {
  if (s.kind == ScheduleKind.dates) {
    final dates = ({for (final d in s.dates) dateOnly(d)}.toList()..sort());
    for (final d in dates) {
      if (!d.isBefore(today) && occursOn(s, d)) yield d;
    }
    return;
  }
  final start = dateOnly(s.startDate);
  var d = start.isAfter(today) ? start : today;
  final last = DateTime(today.year, today.month, today.day + maxDays);
  final end = s.endDate == null ? last : dateOnly(s.endDate!);
  final stop = end.isBefore(last) ? end : last;
  for (; !d.isAfter(stop); d = DateTime(d.year, d.month, d.day + 1)) {
    if (occursOn(s, d)) yield d;
  }
}

/// FNV-1a, 31 bits: the notification id must fit a signed 32-bit integer.
int _id(String key) {
  var h = 0x811c9dc5;
  for (final c in key.codeUnits) {
    h = ((h ^ c) * 0x01000193) & 0xFFFFFFFF;
  }
  return h & 0x7FFFFFFF;
}

/// Which intake a tapped notification points at.
class OpenIntakeRequest {
  const OpenIntakeRequest({
    required this.scheduleId,
    required this.day,
    required this.minuteOfDay,
  });

  final String scheduleId;
  final DateTime day;
  final int minuteOfDay;

  Map<String, Object> toJson() => {
    's': scheduleId,
    'd': '${day.year}-${day.month}-${day.day}',
    'm': minuteOfDay,
  };

  /// Null for a missing or malformed payload.
  static OpenIntakeRequest? fromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final j = jsonDecode(payload) as Map<String, dynamic>;
      final d = (j['d'] as String).split('-').map(int.parse).toList();
      return OpenIntakeRequest(
        scheduleId: j['s'] as String,
        day: DateTime(d[0], d[1], d[2]),
        minuteOfDay: j['m'] as int,
      );
    } on Object {
      return null;
    }
  }
}

/// Button ids of a reminder and how long each postpones it.
const takenAction = 'taken';
const snoozeActions = {
  'snooze': Duration(minutes: 10),
  'snooze30': Duration(minutes: 30),
};

/// What pressing a "later" button does: another notification with the same
/// text, and the follow-up of the reminder dropped (it would only come while
/// the user has asked to wait).
class SnoozePlan {
  const SnoozePlan({
    required this.cancelId,
    required this.newId,
    required this.after,
    required this.title,
    required this.body,
    required this.style,
    required this.payload,
  });

  final int cancelId;
  final int newId;
  final Duration after;
  final String title;
  final String body;
  final ReminderStyle style;
  final String payload;

  /// Null for a button that does not postpone, or a payload that cannot be
  /// postponed.
  static SnoozePlan? from({
    required int? id,
    required String? payload,
    required String? actionId,
  }) {
    final after = snoozeActions[actionId];
    if (after == null || id == null || payload == null) return null;
    try {
      final j = jsonDecode(payload) as Map<String, dynamic>;
      return SnoozePlan(
        cancelId: id ^ followUpBit,
        newId: (id ^ 0x20000000) & 0x7FFFFFFF,
        after: after,
        title: j['t'] as String,
        body: j['b'] as String,
        style: ReminderStyle(
          sound: j['ss'] != false,
          vibration: j['sv'] != false,
        ),
        payload: jsonEncode({...j, 'z': 1}),
      );
    } on Object {
      return null;
    }
  }
}
