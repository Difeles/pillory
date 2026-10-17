import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/data/app_database.dart';
import 'package:pillory/data/drift_inventory_repository.dart';
import 'package:pillory/data/drift_schedule_repository.dart';
import 'package:pillory/domain/errors.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/domain/schedule.dart';

void main() {
  late AppDatabase db;
  late DriftInventoryRepository inventory;
  late DriftScheduleRepository repo;
  final day = DateTime(2026, 10, 19);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    inventory = DriftInventoryRepository(db);
    repo = DriftScheduleRepository(db, inventory);
  });
  tearDown(() => db.close());

  Future<String> medicine(double qty, {String name = 'Аспирин'}) =>
      inventory.createMedicine(
        NewMedicine(name: name, initialQuantity: qty, unit: 'шт.'),
      );

  NewSchedule daily(
    String medicineId, {
    double dose = 1,
    List<int> times = const [],
  }) => NewSchedule(
    medicineId: medicineId,
    kind: ScheduleKind.daily,
    dose: dose,
    doseUnit: 'шт.',
    startDate: DateTime(2026, 10, 1),
    times: times,
  );

  Future<List<DayIntake>> intakes([DateTime? d]) =>
      repo.watchDay(d ?? day).first;
  Future<double> total() async =>
      (await inventory.watchStock().first).single.totalQuantity;

  test('several times give independent intakes and doses', () async {
    final id = await medicine(10);
    final sid = await repo.createSchedule(
      daily(id, dose: 2, times: [20 * 60, 8 * 60, 8 * 60]),
    );
    final list = await intakes();
    expect(list.map((i) => i.minuteOfDay), [480, 1200]);

    await repo.markTaken(scheduleId: sid, day: day, minuteOfDay: 1200);
    expect((await intakes()).map((i) => i.taken), [false, true]);
    expect(await total(), 8);

    // Repeat of the same time is a no-op; the other time still deducts.
    await repo.markTaken(scheduleId: sid, day: day, minuteOfDay: 1200);
    expect(await total(), 8);
    await repo.markTaken(scheduleId: sid, day: day, minuteOfDay: 480);
    expect(await total(), 6);
    expect((await intakes()).every((i) => i.taken), isTrue);

    expect(
      () => repo.markTaken(scheduleId: sid, day: day, minuteOfDay: 600),
      throwsArgumentError,
    );
    expect(
      () => repo.markTaken(scheduleId: sid, day: day),
      throwsArgumentError,
    );
  });

  test('rejects an out-of-range time', () {
    expect(
      () => repo.createSchedule(daily('m', times: [24 * 60])),
      throwsA(isA<InvalidScheduleException>()),
    );
  });

  test(
    'a schedule references the existing medicine and shows on its days',
    () async {
      final id = await medicine(20);
      await repo.createSchedule(
        NewSchedule(
          medicineId: id,
          kind: ScheduleKind.weekdays,
          weekdays: {DateTime.monday},
          dose: 1,
          doseUnit: 'шт.',
          startDate: DateTime(2026, 10, 1),
        ),
      );
      final mon = await intakes();
      expect(mon.single.medicineName, 'Аспирин');
      expect(mon.single.schedule.medicineId, id);
      expect(mon.single.schedule.weekdays, {DateTime.monday});
      expect(await intakes(DateTime(2026, 10, 20)), isEmpty);
      expect(await total(), 20, reason: 'dose is not the stock');
      expect((await db.select(db.medicines).get()).length, 1);
    },
  );

  test('marking deducts the dose and writes a decrease transaction', () async {
    final id = await medicine(20);
    final sid = await repo.createSchedule(daily(id));
    await repo.markTaken(scheduleId: sid, day: day);

    expect(await total(), 19);
    final pkg = (await inventory.watchStock().first).single.primaryPackage;
    final h = await inventory.history(pkg.id);
    expect(h.first.kind, TransactionKind.decrease);
    expect(h.first.delta, -1);
    final i = (await intakes()).single;
    expect(i.taken, isTrue);
  });

  test('marking again does not deduct twice', () async {
    final id = await medicine(20);
    final sid = await repo.createSchedule(daily(id));
    await repo.markTaken(scheduleId: sid, day: day);
    await repo.markTaken(scheduleId: sid, day: day);
    await Future.wait([
      repo.markTaken(scheduleId: sid, day: day),
      repo.markTaken(scheduleId: sid, day: day),
    ]);
    expect(await total(), 19);
    expect(await db.select(db.intakeLogs).get(), hasLength(1));
    // The next day is a separate intake.
    await repo.markTaken(
      scheduleId: sid,
      day: day.add(const Duration(days: 1)),
    );
    expect(await total(), 18);
  });

  test('insufficient stock writes nothing and never goes negative', () async {
    final id = await medicine(1);
    await inventory.addPackage(medicineId: id, quantity: 1, unit: 'шт.');
    final sid = await repo.createSchedule(daily(id, dose: 3));
    await expectLater(
      repo.markTaken(scheduleId: sid, day: day),
      throwsA(isA<InsufficientStockException>()),
    );
    expect(await total(), 2);
    expect(await db.select(db.intakeLogs).get(), isEmpty);
    expect((await intakes()).single.taken, isFalse);
  });

  test('a dose spanning two packages is deducted from both', () async {
    final id = await inventory.createMedicine(
      NewMedicine(
        name: 'Аспирин',
        initialQuantity: 1,
        unit: 'шт.',
        expiresOn: DateTime(2027, 1, 1),
      ),
    );
    await inventory.addPackage(
      medicineId: id,
      quantity: 5,
      unit: 'шт.',
      expiresOn: DateTime(2028, 1, 1),
    );
    final sid = await repo.createSchedule(daily(id, dose: 2));
    await repo.markTaken(scheduleId: sid, day: day);
    expect(await total(), 4);
    expect(
      (await db.select(db.inventoryTransactions).get()).where(
        (t) => t.kind == TransactionKind.decrease,
      ),
      hasLength(2),
    );
  });

  test('a failed mark rolls back deductions already made', () async {
    final id = await medicine(5);
    final sid = await repo.createSchedule(daily(id));
    await db.customStatement('DROP TABLE intake_logs');
    await expectLater(
      repo.markTaken(scheduleId: sid, day: day),
      throwsA(anything),
    );
    expect(await total(), 5);
  });

  test('unknown schedule, day without an intake, invalid input', () async {
    final id = await medicine(5);
    await expectLater(
      repo.markTaken(scheduleId: 'nope', day: day),
      throwsA(isA<ScheduleNotFoundException>()),
    );
    final sid = await repo.createSchedule(
      NewSchedule(
        medicineId: id,
        kind: ScheduleKind.dates,
        dates: [DateTime(2026, 10, 25)],
        dose: 1,
        doseUnit: 'шт.',
        startDate: DateTime(2026, 10, 25),
      ),
    );
    await expectLater(
      repo.markTaken(scheduleId: sid, day: day),
      throwsArgumentError,
    );
    await expectLater(
      repo.createSchedule(daily(id, dose: 0)),
      throwsA(isA<InvalidScheduleException>()),
    );
    expect(await total(), 5);
  });

  test('deleting the medicine removes its schedules and marks', () async {
    final id = await medicine(5);
    final sid = await repo.createSchedule(daily(id));
    await repo.markTaken(scheduleId: sid, day: day);
    await (db.delete(db.medicines)..where((m) => m.id.equals(id))).go();
    expect(await db.select(db.schedules).get(), isEmpty);
    expect(await db.select(db.intakeLogs).get(), isEmpty);
  });

  group('skip, undo and history', () {
    Future<Map<String, double>> packages() async => {
      for (final p in await db.select(db.medicinePackages).get())
        p.id: p.quantity,
    };

    test('skipping leaves stock alone and shows as skipped', () async {
      final id = await medicine(5);
      final sid = await repo.createSchedule(daily(id));
      await repo.markSkipped(scheduleId: sid, day: day);
      await repo.markSkipped(scheduleId: sid, day: day);
      expect((await intakes()).single.skipped, isTrue);
      expect(await total(), 5);
      expect(await db.select(db.inventoryTransactions).get(), hasLength(1));
    });

    test(
      'a taken intake cannot be skipped; a skipped one can be taken',
      () async {
        final id = await medicine(5);
        final sid = await repo.createSchedule(daily(id));
        await repo.markTaken(scheduleId: sid, day: day);
        expect(
          () => repo.markSkipped(scheduleId: sid, day: day),
          throwsA(isA<IntakeStateException>()),
        );
        await repo.resetMark(scheduleId: sid, day: day);
        await repo.markSkipped(scheduleId: sid, day: day);
        await repo.markTaken(scheduleId: sid, day: day);
        expect((await intakes()).single.taken, isTrue);
        expect(await total(), 4);
      },
    );

    test('resetting a skip needs no stock change', () async {
      final id = await medicine(5);
      final sid = await repo.createSchedule(daily(id));
      await repo.markSkipped(scheduleId: sid, day: day);
      await repo.resetMark(scheduleId: sid, day: day);
      expect((await intakes()).single.status, IntakeStatus.pending);
      expect(await total(), 5);
    });

    test('undo restores exactly the packages that were charged', () async {
      final id = await medicine(2);
      await inventory.addPackage(
        medicineId: id,
        quantity: 1,
        unit: 'шт.',
        expiresOn: DateTime(2027, 1, 1),
      );
      await inventory.addPackage(
        medicineId: id,
        quantity: 2,
        unit: 'шт.',
        expiresOn: DateTime(2027, 6, 1),
      );
      final sid = await repo.createSchedule(daily(id, dose: 3.5));
      final before = await packages();

      await repo.markTaken(scheduleId: sid, day: day);
      expect((await packages()).values.toList()..sort(), [0, 0, 1.5]);
      final charged = await db.select(db.intakeDeductions).get();
      expect(charged.map((x) => x.amount).toList()..sort(), [0.5, 1, 2]);

      await repo.resetMark(scheduleId: sid, day: day);
      expect(await packages(), before);
      expect((await intakes()).single.status, IntakeStatus.pending);
      // Nothing is deleted: deductions are marked restored, history kept.
      final after = await db.select(db.intakeDeductions).get();
      expect(after.every((x) => x.restoredAt != null), isTrue);
      expect(
        (await db.select(db.inventoryTransactions).get()).where(
          (t) => t.kind == TransactionKind.increase,
        ),
        hasLength(3),
      );
      expect(await db.select(db.intakeLogs).get(), hasLength(1));
    });

    test('repeated and parallel undo restore once', () async {
      final id = await medicine(5);
      final sid = await repo.createSchedule(daily(id, dose: 2));
      await repo.markTaken(scheduleId: sid, day: day);
      await Future.wait([
        for (var i = 0; i < 4; i++) repo.resetMark(scheduleId: sid, day: day),
      ]);
      await repo.resetMark(scheduleId: sid, day: day);
      expect(await total(), 5);
    });

    test('parallel marking deducts once', () async {
      final id = await medicine(5);
      final sid = await repo.createSchedule(daily(id, dose: 2));
      await Future.wait([
        for (var i = 0; i < 4; i++) repo.markTaken(scheduleId: sid, day: day),
      ]);
      expect(await total(), 3);
      expect(await db.select(db.intakeDeductions).get(), hasLength(1));
    });

    test('taking again after an undo charges and undoes again', () async {
      final id = await medicine(5);
      final sid = await repo.createSchedule(daily(id, dose: 2));
      await repo.markTaken(scheduleId: sid, day: day);
      await repo.resetMark(scheduleId: sid, day: day);
      await repo.markTaken(scheduleId: sid, day: day);
      await repo.markTaken(scheduleId: sid, day: day);
      expect(await total(), 3);
      await repo.resetMark(scheduleId: sid, day: day);
      expect(await total(), 5);
      expect(await db.select(db.intakeDeductions).get(), hasLength(2));
    });

    test('times of one medicine are marked and undone independently', () async {
      final id = await medicine(10);
      final sid = await repo.createSchedule(
        daily(id, times: [8 * 60, 20 * 60]),
      );
      await repo.markTaken(scheduleId: sid, day: day, minuteOfDay: 480);
      await repo.markSkipped(scheduleId: sid, day: day, minuteOfDay: 1200);
      expect((await intakes()).map((i) => i.status), [
        IntakeStatus.taken,
        IntakeStatus.skipped,
      ]);
      await repo.resetMark(scheduleId: sid, day: day, minuteOfDay: 480);
      expect((await intakes()).map((i) => i.status), [
        IntakeStatus.pending,
        IntakeStatus.skipped,
      ]);
      expect(await total(), 10);
    });

    test('an untracked (legacy) taken mark cannot be undone', () async {
      final id = await medicine(5);
      final sid = await repo.createSchedule(daily(id));
      await db
          .into(db.intakeLogs)
          .insert(
            IntakeLogsCompanion.insert(
              id: 'old',
              scheduleId: sid,
              day: day,
              takenAt: DateTime(2026, 10, 19),
            ),
          );
      final i = (await intakes()).single;
      expect(i.taken, isTrue);
      expect(i.deductionsTracked, isFalse);
      expect(i.canReset, isFalse);
      await expectLater(
        repo.resetMark(scheduleId: sid, day: day),
        throwsA(isA<UntrackedIntakeException>()),
      );
      expect((await intakes()).single.taken, isTrue);
      expect(await total(), 5);
    });

    test('history groups past days with statuses', () async {
      final id = await medicine(10);
      final sid = await repo.createSchedule(daily(id));
      final d1 = DateTime(2026, 10, 18), d2 = DateTime(2026, 10, 19);
      await repo.markTaken(scheduleId: sid, day: d1);
      await repo.markSkipped(scheduleId: sid, day: d2);
      final h = await repo.watchHistory(d1, d2).first;
      expect(h.keys, [d1, d2]);
      expect(h[d1]!.single.status, IntakeStatus.taken);
      expect(h[d2]!.single.status, IntakeStatus.skipped);
      await repo.resetMark(scheduleId: sid, day: d1);
      final h2 = await repo.watchHistory(d1, d2).first;
      expect(h2[d1]!.single.status, IntakeStatus.pending);
    });
  });

  group('on disk', () {
    late File file;
    setUp(() async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final dir = await Directory.systemTemp.createTemp('pillory_test_');
      addTearDown(() => dir.delete(recursive: true));
      addTearDown(
        () => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false,
      );
      file = File('${dir.path}/pillory.sqlite');
    });

    test('schedules and marks survive reopening', () async {
      final first = AppDatabase(NativeDatabase(file));
      final inv = DriftInventoryRepository(first);
      final r = DriftScheduleRepository(first, inv);
      final id = await inv.createMedicine(
        const NewMedicine(name: 'Нурофен', initialQuantity: 8, unit: 'шт.'),
      );
      final sid = await r.createSchedule(daily(id, times: [8 * 60 + 30]));
      await r.markTaken(scheduleId: sid, day: day, minuteOfDay: 510);
      await first.close();

      final second = AppDatabase(NativeDatabase(file));
      addTearDown(second.close);
      final inv2 = DriftInventoryRepository(second);
      final r2 = DriftScheduleRepository(second, inv2);
      final i = (await r2.watchDay(day).first).single;
      expect(i.minuteOfDay, 510);
      expect(i.taken, isTrue);
      expect((await inv2.watchStock().first).single.totalQuantity, 7);
    });

    test(
      'a v2 database upgrades keeping schedules and marks per time',
      () async {
        final old = AppDatabase(NativeDatabase(file));
        final inv = DriftInventoryRepository(old);
        final mid = await inv.createMedicine(
          const NewMedicine(name: 'Старое', initialQuantity: 5, unit: 'шт.'),
        );
        await old.customStatement('DROP TABLE intake_logs');
        await old.customStatement('DROP TABLE schedules');
        await old.customStatement('''CREATE TABLE schedules (
        id TEXT NOT NULL PRIMARY KEY,
        medicine_id TEXT NOT NULL REFERENCES medicines (id) ON DELETE CASCADE,
        kind TEXT NOT NULL, weekdays TEXT NOT NULL DEFAULT '',
        dates TEXT NOT NULL DEFAULT '', start_date TEXT NOT NULL,
        end_date TEXT, minute_of_day INTEGER,
        dose REAL NOT NULL CHECK (dose > 0), dose_unit TEXT NOT NULL,
        created_at INTEGER NOT NULL)''');
        await old.customStatement('''CREATE TABLE intake_logs (
        id TEXT NOT NULL PRIMARY KEY,
        schedule_id TEXT NOT NULL REFERENCES schedules (id) ON DELETE CASCADE,
        day TEXT NOT NULL, taken_at INTEGER NOT NULL,
        UNIQUE (schedule_id, day))''');
        await old.customStatement(
          "INSERT INTO schedules VALUES ('timed', '$mid', 'daily', '', '', "
          "'2026-10-01', NULL, 480, 1, 'шт.', 0), "
          "('untimed', '$mid', 'daily', '', '', '2026-10-01', NULL, NULL, 1, "
          "'шт.', 0)",
        );
        await old.customStatement(
          "INSERT INTO intake_logs VALUES ('l1', 'timed', '2026-10-19', 0), "
          "('l2', 'untimed', '2026-10-19', 0)",
        );
        await old.customStatement('PRAGMA user_version = 2');
        await old.close();

        final db3 = AppDatabase(NativeDatabase(file));
        addTearDown(db3.close);
        final r = DriftScheduleRepository(db3, DriftInventoryRepository(db3));
        final list = await r.watchDay(day).first;
        expect(list.map((i) => (i.minuteOfDay, i.taken)), [
          (480, true),
          (null, true),
        ]);
        // Migrated marks stay taken but cannot be undone.
        expect(list.every((i) => i.taken && !i.canReset), isTrue);
        // A later time on the migrated schedule is still independent.
        await db3.customStatement(
          "UPDATE schedules SET times = '480,1200' WHERE id = 'timed'",
        );
        db3.markTablesUpdated([db3.schedules]);
        final again = await r.watchDay(day).first;
        expect(again.map((i) => (i.minuteOfDay, i.taken)), [
          (480, true),
          (1200, false),
          (null, true),
        ]);
      },
    );

    test('a v3 database upgrades keeping marks and stock untouched', () async {
      final v3 = AppDatabase(NativeDatabase(file));
      final inv = DriftInventoryRepository(v3);
      final r = DriftScheduleRepository(v3, inv);
      final mid = await inv.createMedicine(
        const NewMedicine(name: 'Старое', initialQuantity: 5, unit: 'шт.'),
      );
      final sid = await r.createSchedule(daily(mid));
      await r.markTaken(scheduleId: sid, day: day);
      // Turn the file back into a v3 database (no status/tracking, no
      // deductions table).
      await v3.customStatement('DROP TABLE intake_deductions');
      await v3.customStatement('ALTER TABLE intake_logs DROP COLUMN status');
      await v3.customStatement(
        'ALTER TABLE intake_logs DROP COLUMN deductions_tracked',
      );
      await v3.customStatement('PRAGMA user_version = 3');
      await v3.close();

      final v4 = AppDatabase(NativeDatabase(file));
      addTearDown(v4.close);
      final inv2 = DriftInventoryRepository(v4);
      final r2 = DriftScheduleRepository(v4, inv2);
      final i = (await r2.watchDay(day).first).single;
      expect(i.taken, isTrue);
      expect(i.canReset, isFalse);
      expect((await inv2.watchStock().first).single.totalQuantity, 4);
      // New marks work on the migrated database.
      await r2.resetMark(scheduleId: sid, day: day).catchError((_) {});
      await r2.markSkipped(scheduleId: sid, day: DateTime(2026, 10, 20));
      expect(
        (await r2.watchDay(DateTime(2026, 10, 20)).first).single.skipped,
        isTrue,
      );
    });

    test('a v1 database upgrades to v2 and keeps its data', () async {
      final v1 = AppDatabase(NativeDatabase(file));
      final inv = DriftInventoryRepository(v1);
      await inv.createMedicine(
        const NewMedicine(name: 'Старое', initialQuantity: 3, unit: 'шт.'),
      );
      // Turn the file back into a v1 database.
      await v1.customStatement('DROP TABLE intake_logs');
      await v1.customStatement('DROP TABLE schedules');
      await v1.customStatement('PRAGMA user_version = 1');
      await v1.close();

      final v2 = AppDatabase(NativeDatabase(file));
      addTearDown(v2.close);
      final inv2 = DriftInventoryRepository(v2);
      final r = DriftScheduleRepository(v2, inv2);
      final stock = (await inv2.watchStock().first).single;
      expect(stock.medicine.name, 'Старое');
      final sid = await r.createSchedule(daily(stock.medicine.id));
      await r.markTaken(scheduleId: sid, day: day);
      expect((await inv2.watchStock().first).single.totalQuantity, 2);
    });
  });
}
