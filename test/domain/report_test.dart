import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/domain/diary.dart';
import 'package:flutter/widgets.dart';
import 'package:pillory/domain/report.dart';
import 'package:pillory/l10n/app_localizations.dart';
import 'package:pillory/domain/schedule.dart';

void main() {
  final today = DateTime(2026, 10, 20);
  DateTime ago(int n) => DateTime(2026, 10, 20 - n);

  Schedule schedule(String medicineId) => Schedule(
    id: 's$medicineId',
    createdAt: DateTime(2026),
    medicineId: medicineId,
    kind: ScheduleKind.daily,
    dose: 1,
    doseUnit: 'шт.',
    startDate: DateTime(2026, 10, 1),
    times: const [480],
  );

  DayIntake intake(String id, String name, IntakeStatus status) => DayIntake(
    schedule: schedule(id),
    medicineName: name,
    minuteOfDay: 480,
    status: status,
    deductionsTracked: true,
  );

  test('counts taken, skipped and missed per medicine', () {
    final r = buildReport(
      name: 'Аня',
      from: ago(2),
      to: today,
      history: {
        ago(2): [intake('a', 'Аспирин', IntakeStatus.taken)],
        ago(1): [intake('a', 'Аспирин', IntakeStatus.pending)],
        today: [
          intake('a', 'Аспирин', IntakeStatus.pending),
          intake('b', 'Бромгексин', IntakeStatus.skipped),
        ],
        ago(9): [intake('a', 'Аспирин', IntakeStatus.taken)],
      },
      diary: const [],
      today: today,
    );
    final a = r.medicines.first;
    expect([a.name, a.taken, a.skipped, a.missed], ['Аспирин', 1, 0, 1]);
    expect(a.planned, 2, reason: 'today is still ahead, so not counted');
    final b = r.medicines.last;
    expect([b.name, b.skipped], ['Бромгексин', 1]);
  });

  test('diary entries of the period come oldest first', () {
    final r = buildReport(
      name: '',
      from: ago(2),
      to: today,
      history: const {},
      diary: [
        DiaryEntry(
          id: '2',
          at: DateTime(2026, 10, 20, 23, 59),
          symptoms: const ['headache'],
        ),
        DiaryEntry(id: '1', at: DateTime(2026, 10, 18, 8), mood: 4),
        DiaryEntry(id: '0', at: DateTime(2026, 10, 1), mood: 1),
      ],
      today: today,
    );
    expect(r.diary.map((e) => e.id), ['1', '2']);
  });

  test('csv quotes what needs it', () {
    final r = buildReport(
      name: 'Аня; мама',
      from: ago(1),
      to: today,
      history: const {},
      diary: [
        DiaryEntry(id: '1', at: DateTime(2026, 10, 20, 8), note: 'a;"b"'),
      ],
      today: today,
    );
    final csv = reportCsv(r, lookupAppLocalizations(const Locale('ru')));
    expect(csv, contains('"Аня; мама"'));
    expect(csv, contains('"a;""b"""'));
  });
}
