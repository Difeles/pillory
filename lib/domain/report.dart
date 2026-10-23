import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import 'diary.dart';
import 'inventory_rules.dart';
import 'schedule.dart';

/// What happened with one medicine over the period.
class MedicineSummary {
  const MedicineSummary({
    required this.name,
    required this.taken,
    required this.skipped,
    required this.missed,
  });

  final String name;
  final int taken;
  final int skipped;

  /// Planned for an earlier day and never marked.
  final int missed;

  int get planned => taken + skipped + missed;
}

/// Everything the doctor's report shows, already counted.
class ReportData {
  const ReportData({
    required this.name,
    required this.from,
    required this.to,
    required this.medicines,
    required this.diary,
  });

  /// The person's name, or empty.
  final String name;
  final DateTime from;
  final DateTime to;
  final List<MedicineSummary> medicines;

  /// Oldest first.
  final List<DiaryEntry> diary;
}

/// Counts the intakes of [history] by medicine and takes the diary entries
/// that fall into [from]..[to]. Today's open intakes are still ahead, so
/// they are not "missed".
ReportData buildReport({
  required String name,
  required DateTime from,
  required DateTime to,
  required Map<DateTime, List<DayIntake>> history,
  required Iterable<DiaryEntry> diary,
  required DateTime today,
}) {
  final start = dateOnly(from), end = dateOnly(to), now = dateOnly(today);
  final counts = <String, (String, int, int, int)>{};
  for (final e in history.entries) {
    final day = dateOnly(e.key);
    if (day.isBefore(start) || day.isAfter(end)) continue;
    for (final i in e.value) {
      final (n, t, s, m) =
          counts[i.schedule.medicineId] ?? (i.medicineName, 0, 0, 0);
      counts[i.schedule.medicineId] = (
        n,
        t + (i.taken ? 1 : 0),
        s + (i.skipped ? 1 : 0),
        m + (!i.taken && !i.skipped && day.isBefore(now) ? 1 : 0),
      );
    }
  }
  final medicines = [
    for (final (n, t, s, m) in counts.values)
      MedicineSummary(name: n, taken: t, skipped: s, missed: m),
  ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  final lastMoment = DateTime(end.year, end.month, end.day + 1);
  final entries = [
    for (final d in diary)
      if (!d.at.isBefore(start) && d.at.isBefore(lastMoment)) d,
  ]..sort((a, b) => a.at.compareTo(b.at));
  return ReportData(
    name: name,
    from: start,
    to: end,
    medicines: medicines,
    diary: entries,
  );
}

String _d(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

String _t(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _csv(Object? v) {
  final s = v?.toString() ?? '';
  return s.contains(RegExp('[",;\n]')) ? '"${s.replaceAll('"', '""')}"' : s;
}

/// The report as semicolon-separated text (opens in Excel and Numbers).
String reportCsv(ReportData r, AppLocalizations l) {
  final rows = <List<Object?>>[
    [l.csvTitle, r.name, '${_d(r.from)} - ${_d(r.to)}'],
    [],
    [l.csvMedicine, l.csvPlanned, l.csvTaken, l.csvSkipped, l.csvMissed],
    for (final m in r.medicines)
      [m.name, m.planned, m.taken, m.skipped, m.missed],
    [],
    [l.csvDate, l.csvTime, l.csvMood, l.csvSymptoms, l.csvNote],
    for (final e in r.diary)
      [
        _d(e.at),
        _t(e.at),
        e.mood,
        e.symptoms.map(l.symptom).join(', '),
        e.note,
      ],
  ];
  return rows.map((row) => row.map(_csv).join(';')).join('\n');
}

/// The line the PDF prints for a diary entry.
String diaryLine(AppLocalizations l, DiaryEntry e) => [
  if (e.mood != null) l.moodText(e.mood!),
  if (e.symptoms.isNotEmpty) e.symptoms.map(l.symptom).join(', '),
  if (e.note != null) e.note!,
].join(', ');

String reportPeriod(ReportData r) => '${_d(r.from)} - ${_d(r.to)}';
String reportStamp(DateTime d) => '${_d(d)} ${_t(d)}';
