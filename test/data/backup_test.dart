import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/reminder_sync.dart';
import 'package:pillory/data/app_database.dart';
import 'package:pillory/data/backup_format.dart';
import 'package:pillory/data/drift_backup_repository.dart';
import 'package:pillory/data/drift_inventory_repository.dart';
import 'package:pillory/data/drift_schedule_repository.dart';
import 'package:pillory/data/tables.dart' show untimedSlot;
import 'package:pillory/domain/medicine_form.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/domain/schedule.dart';

import '../support/fake_reminder_scheduler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Monday 07:00.
  final now = DateTime.utc(2026, 10, 19, 7);
  final today = DateTime(2026, 10, 19);

  late AppDatabase db;
  late DriftInventoryRepository inventory;
  late DriftScheduleRepository schedules;
  late DriftBackupRepository backup;

  AppDatabase open() => AppDatabase(NativeDatabase.memory());

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    db = open();
    inventory = DriftInventoryRepository(db, now: () => now);
    schedules = DriftScheduleRepository(db, inventory, now: () => now);
    backup = DriftBackupRepository(db, now: () => now);
  });
  tearDown(() => db.close());

  /// Every kind of row: an archived medicine, two packages, all mark states
  /// (taken, skipped, reset after a deduction), and a schedule that was split
  /// into two rows by an edit.
  Future<void> seed() async {
    final a = await inventory.createMedicine(
      NewMedicine(
        name: 'Аспирин',
        form: MedicineForm.tablet,
        strength: '500 мг',
        initialQuantity: 20,
        unit: 'шт.',
        expiresOn: DateTime(2027, 1, 31),
        lowStockThreshold: 4,
      ),
    );
    await inventory.addPackage(medicineId: a, quantity: 10, unit: 'шт.');
    final b = await inventory.createMedicine(
      const NewMedicine(name: 'Старое', initialQuantity: 3, unit: 'мл'),
    );
    await inventory.archiveMedicine(b);

    final s = await schedules.createSchedule(
      NewSchedule(
        medicineId: a,
        kind: ScheduleKind.daily,
        dose: 2,
        doseUnit: 'шт.',
        startDate: DateTime(2026, 10, 1),
        times: [480, 1200],
      ),
    );
    await schedules.markTaken(scheduleId: s, day: today, minuteOfDay: 480);
    await schedules.markSkipped(scheduleId: s, day: today, minuteOfDay: 1200);
    final yesterday = DateTime(2026, 10, 18);
    await schedules.markTaken(scheduleId: s, day: yesterday, minuteOfDay: 480);
    await schedules.resetMark(scheduleId: s, day: yesterday, minuteOfDay: 480);
    await schedules.updateSchedule(
      s,
      ScheduleEdit(
        kind: ScheduleKind.daily,
        dose: 1,
        times: const [480],
        startDate: DateTime(2026, 10, 1),
      ),
    );
    await schedules.createSchedule(
      NewSchedule(
        medicineId: a,
        kind: ScheduleKind.weekdays,
        weekdays: const {1, 5},
        dose: 1,
        doseUnit: 'шт.',
        startDate: DateTime(2026, 10, 1),
      ),
    );
  }

  Uint8List bytes(String s) => Uint8List.fromList(utf8.encode(s));
  Future<String> dump(DriftBackupRepository r) async =>
      encodeBackup(await r.read());
  Map<String, dynamic> json(BackupData d) =>
      jsonDecode(encodeBackup(d)) as Map<String, dynamic>;

  void refuses(Object source, BackupProblem problem) {
    final b = source is Uint8List ? source : bytes(jsonEncode(source));
    expect(
      () => parseBackup(b),
      throwsA(
        isA<BackupException>().having((e) => e.problem, 'problem', problem),
      ),
    );
  }

  test('export, restore and export again give the same file', () async {
    await seed();
    final first = await dump(backup);
    final data = await backup.read();
    expect(data.schedules.length, greaterThanOrEqualTo(3), reason: 'split');
    expect(data.intakeLogs.map((l) => l.status).toSet(), {
      IntakeStatus.taken,
      IntakeStatus.skipped,
      IntakeStatus.pending,
    });
    expect(data.intakeDeductions.any((x) => x.restoredAt != null), isTrue);
    expect(data.archivedMedicines, 1);

    final other = open();
    addTearDown(other.close);
    final target = DriftBackupRepository(other, now: () => now);
    await target.restore(parseBackup(bytes(first)));

    expect(await dump(target), first);
  });

  test('restoring replaces whatever was there', () async {
    await seed();
    final file = await dump(backup);

    final other = open();
    addTearDown(other.close);
    final otherInventory = DriftInventoryRepository(other, now: () => now);
    await otherInventory.createMedicine(
      const NewMedicine(name: 'Лишнее', initialQuantity: 1, unit: 'шт.'),
    );
    final target = DriftBackupRepository(other, now: () => now);
    await target.restore(parseBackup(bytes(file)));

    expect(await dump(target), file);
    expect(
      (await target.read()).medicines.map((m) => m.name),
      isNot(contains('Лишнее')),
    );
  });

  test('a failure while restoring rolls everything back', () async {
    await seed();
    final before = await dump(backup);
    final good = parseBackup(bytes(before));
    // Passes the parser's types but breaks a foreign key, after the deletes.
    final broken = BackupData(
      schemaVersion: good.schemaVersion,
      medicines: good.medicines,
      packages: [
        ...good.packages,
        good.packages.first.copyWith(id: 'x', medicineId: 'missing'),
      ],
      transactions: good.transactions,
      schedules: good.schedules,
      intakeLogs: good.intakeLogs,
      intakeDeductions: good.intakeDeductions,
    );
    await expectLater(backup.restore(broken), throwsA(anything));
    expect(await dump(backup), before);
  });

  test('restore re-plans the notifications', () async {
    await seed();
    final file = await dump(backup);

    final other = open();
    addTearDown(other.close);
    final otherInventory = DriftInventoryRepository(other, now: () => now);
    final otherSchedules = DriftScheduleRepository(
      other,
      otherInventory,
      now: () => now,
    );
    final scheduler = FakeReminderScheduler();
    final sync = ReminderSync(
      otherSchedules,
      scheduler,
      now: () => DateTime(2026, 10, 19, 7),
    );
    addTearDown(sync.dispose);
    // A reminder of a schedule that the restore removes.
    await scheduler.schedule(
      id: 1,
      at: DateTime(2026, 10, 20),
      title: 'x',
      body: 'x',
      payload: '{}',
    );

    await DriftBackupRepository(
      other,
      now: () => now,
    ).restore(parseBackup(bytes(file)));
    await sync.resync();

    expect(scheduler.scheduled.containsKey(1), isFalse);
    expect(scheduler.scheduled, isNotEmpty);
  });

  group('refuses', () {
    late Map<String, dynamic> good;
    setUp(() async {
      await seed();
      good = json(await backup.read());
    });
    Map<String, dynamic> copy() => jsonDecode(jsonEncode(good));
    List rows(Map<String, dynamic> j, String t) => j['data'][t] as List;

    test('broken JSON, a foreign file and an oversized file', () {
      refuses(bytes('{"format": "pillory-backup", '), BackupProblem.corrupt);
      refuses(Uint8List.fromList([0xff, 0xfe, 0x00]), BackupProblem.corrupt);
      refuses({'hello': 1}, BackupProblem.notBackup);
      refuses(bytes('[1,2]'), BackupProblem.notBackup);
      refuses(Uint8List(maxBackupBytes + 1), BackupProblem.tooLarge);
    });

    test('a future format version, without looking at the rest', () {
      refuses({
        'format': backupFormat,
        'formatVersion': backupFormatVersion + 1,
      }, BackupProblem.newerFormat);
      final j = copy()..['formatVersion'] = backupFormatVersion + 1;
      refuses(j, BackupProblem.newerFormat);
      refuses(copy()..['encryption'] = {'alg': 'x'}, BackupProblem.newerFormat);
    });

    test('a missing or invalid format version', () {
      refuses(copy()..remove('formatVersion'), BackupProblem.corrupt);
      refuses(copy()..['formatVersion'] = 0, BackupProblem.corrupt);
    });

    test('counts that do not match', () {
      final j = copy();
      (j['counts'] as Map)['packages'] = 99;
      refuses(j, BackupProblem.inconsistent);
      final k = copy();
      rows(k, 'packages').removeLast();
      refuses(k, BackupProblem.inconsistent);
    });

    test('unknown enum values', () {
      for (final (table, field) in [
        ('medicines', 'form'),
        ('transactions', 'kind'),
        ('schedules', 'kind'),
        ('intakeLogs', 'status'),
      ]) {
        final j = copy();
        (rows(j, table).first as Map)[field] = 'from-the-future';
        refuses(j, BackupProblem.corrupt);
      }
    });

    test('broken references', () {
      for (final (table, field) in [
        ('packages', 'medicineId'),
        ('transactions', 'packageId'),
        ('schedules', 'medicineId'),
        ('intakeLogs', 'scheduleId'),
        ('intakeDeductions', 'intakeLogId'),
        ('intakeDeductions', 'packageId'),
      ]) {
        final j = copy();
        (rows(j, table).first as Map)[field] = 'nowhere';
        refuses(j, BackupProblem.inconsistent);
      }
    });

    test('duplicate ids and a second mark of one intake', () {
      final j = copy();
      final r = rows(j, 'medicines');
      r.add(Map.of(r.first as Map));
      (j['counts'] as Map)['medicines'] = r.length;
      refuses(j, BackupProblem.inconsistent);

      final k = copy();
      final l = rows(k, 'intakeLogs');
      l.add({...(l.first as Map), 'id': 'second'});
      (k['counts'] as Map)['intakeLogs'] = l.length;
      refuses(k, BackupProblem.inconsistent);
    });

    test('values the database would reject', () {
      void bad(String table, String field, Object? value) {
        final j = copy();
        (rows(j, table).first as Map)[field] = value;
        refuses(j, BackupProblem.corrupt);
      }

      bad('packages', 'quantity', -1);
      bad('packages', 'expiresOn', '2027-02-31');
      bad('schedules', 'dose', 0);
      bad('schedules', 'times', [1440]);
      bad('schedules', 'weekdays', [8]);
      bad('intakeLogs', 'slot', 5000);
      bad('intakeDeductions', 'amount', 0);
      bad('medicines', 'name', '');
      bad('medicines', 'createdAt', '2026-10-19T07:00:00'); // no zone
      bad('medicines', 'id', 5);
    });
  });

  test('a file from an old schema is filled with defaults', () async {
    // Schema 2: no times, no slot/status, no unit, no deductions table.
    final file = {
      'format': backupFormat,
      'formatVersion': 1,
      'schemaVersion': 2,
      'createdAt': '2026-01-01T00:00:00Z',
      'counts': {
        'medicines': 1,
        'packages': 2,
        'schedules': 1,
        'intakeLogs': 1,
      },
      'data': {
        'medicines': [
          {'id': 'm', 'name': 'Старое', 'createdAt': '2026-01-01T00:00:00Z'},
        ],
        'packages': [
          for (final (id, unit, at) in [
            ('p2', 'мл', '2026-01-03T00:00:00Z'),
            ('p1', 'шт.', '2026-01-02T00:00:00Z'),
          ])
            {
              'id': id,
              'medicineId': 'm',
              'initialQuantity': 5,
              'quantity': 5,
              'unit': unit,
              'createdAt': at,
            },
        ],
        'transactions': [],
        'schedules': [
          {
            'id': 's',
            'medicineId': 'm',
            'kind': 'daily',
            'startDate': '2026-01-01',
            'dose': 1,
            'doseUnit': 'шт.',
            'createdAt': '2026-01-01T00:00:00Z',
          },
        ],
        'intakeLogs': [
          {
            'id': 'l',
            'scheduleId': 's',
            'day': '2026-01-02',
            'takenAt': '2026-01-02T08:00:00Z',
          },
        ],
      },
    };
    final d = parseBackup(bytes(jsonEncode(file)));
    expect(d.medicines.single.unit, 'шт.', reason: 'oldest package');
    expect(d.medicines.single.archivedAt, isNull);
    expect(d.schedules.single.times, '');
    final l = d.intakeLogs.single;
    expect(l.slot, untimedSlot);
    expect(l.status, IntakeStatus.taken);
    expect(l.deductionsTracked, isFalse);
    expect(d.intakeDeductions, isEmpty);

    await backup.restore(d);
    expect((await backup.read()).intakeLogs.single.status, IntakeStatus.taken);

    // The same file claiming a current schema must not lack those fields.
    refuses(
      (jsonDecode(jsonEncode(file)) as Map<String, dynamic>)
        ..['schemaVersion'] = 6,
      BackupProblem.corrupt,
    );
  });

  test('unknown extra fields are ignored', () async {
    await seed();
    final j = json(await backup.read());
    (j['data']['medicines'] as List).first['somethingNew'] = 1;
    j['somethingNew'] = {};
    expect(parseBackup(bytes(jsonEncode(j))).medicines, isNotEmpty);
  });

  test('an empty database makes a valid file', () async {
    final d = parseBackup(bytes(await dump(backup)));
    expect(d.isEmpty, isTrue);
  });
}
