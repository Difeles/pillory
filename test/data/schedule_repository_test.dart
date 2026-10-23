import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/data/app_database.dart';
import 'package:pillory/data/drift_inventory_repository.dart';
import 'package:pillory/data/drift_schedule_repository.dart';
import 'package:pillory/domain/errors.dart';
import 'package:pillory/domain/medicine_form.dart';
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

  group('editing and ending schedules', () {
    // "Now" is 2026-10-19 12:00; the schedules started on 2026-10-01.
    final d17 = DateTime(2026, 10, 17), d18 = DateTime(2026, 10, 18);
    final d20 = DateTime(2026, 10, 20), d25 = DateTime(2026, 10, 25);
    late DriftScheduleRepository edit;

    setUp(
      () => edit = DriftScheduleRepository(
        db,
        inventory,
        now: () => DateTime(2026, 10, 19, 12),
      ),
    );

    ScheduleEdit same({
      List<int> times = const [8 * 60],
      double dose = 1,
      DateTime? start,
      DateTime? end,
    }) => ScheduleEdit(
      kind: ScheduleKind.daily,
      dose: dose,
      times: times,
      startDate: start,
      endDate: end,
    );

    /// What the history shows for a day: time, status and dose.
    Future<List<(int?, IntakeStatus, double)>> shown(DateTime d) async => [
      for (final i in (await edit.watchHistory(d, d).first)[d] ?? <DayIntake>[])
        (i.minuteOfDay, i.status, i.schedule.dose),
    ];

    Future<int> versions() async =>
        (await db.select(db.schedules).get()).length;

    Future<String> started(
      String medicineId, {
      List<int> times = const [8 * 60],
    }) => edit.createSchedule(daily(medicineId, times: times));

    test(
      'editing a started schedule leaves past days, marks and stock alone',
      () async {
        final mid = await medicine(10);
        final sid = await started(mid);
        await edit.markTaken(scheduleId: sid, day: d17, minuteOfDay: 480);
        await edit.markSkipped(scheduleId: sid, day: d18, minuteOfDay: 480);
        final before = [await shown(d17), await shown(d18)];
        final logs = await db.select(db.intakeLogs).get();

        final from = await edit.updateSchedule(
          sid,
          same(times: [9 * 60], dose: 2),
        );

        expect(from, day);
        expect([await shown(d17), await shown(d18)], before);
        expect(await shown(day), [(540, IntakeStatus.pending, 2.0)]);
        expect(await db.select(db.intakeLogs).get(), hasLength(logs.length));
        expect(await total(), 9);
        final rows = await db.select(db.schedules).get();
        expect(rows, hasLength(2));
        expect(rows.map((r) => r.medicineId).toSet(), {mid});
        expect(rows.firstWhere((r) => r.id == sid).endDate, d18);
        // The old mark can still be undone, by the packages it charged.
        await edit.resetMark(scheduleId: sid, day: d17, minuteOfDay: 480);
        expect(await total(), 10);
      },
    );

    test('with a mark today the change starts tomorrow', () async {
      final sid = await started(await medicine(10));
      await edit.markTaken(scheduleId: sid, day: day, minuteOfDay: 480);

      final from = await edit.updateSchedule(sid, same(dose: 3));

      expect(from, d20);
      expect(await shown(day), [(480, IntakeStatus.taken, 1.0)]);
      expect(await shown(d20), [(480, IntakeStatus.pending, 3.0)]);
    });

    test('a schedule that has not started is edited in place', () async {
      final sid = await edit.createSchedule(
        daily(await medicine(10)).copyWithStart(d25),
      );
      final from = await edit.updateSchedule(
        sid,
        same(times: [7 * 60], start: DateTime(2026, 10, 27)),
      );
      expect(from, day);
      expect(await versions(), 1);
      expect(await shown(DateTime(2026, 10, 26)), isEmpty);
      expect(await shown(DateTime(2026, 10, 27)), [
        (420, IntakeStatus.pending, 1.0),
      ]);
    });

    test('an edit that changes nothing creates no version', () async {
      final sid = await started(await medicine(10), times: [20 * 60, 8 * 60]);
      await edit.updateSchedule(sid, same(times: [8 * 60, 20 * 60]));
      expect(await versions(), 1);
      expect(
        (await db.select(db.schedules).get()).single.endDate,
        equals(null),
      );
    });

    test('repeated and parallel edits make one version', () async {
      final sid = await started(await medicine(10));
      final results = await Future.wait([
        for (var i = 0; i < 3; i++)
          edit
              .updateSchedule(sid, same(dose: 2))
              .then<Object>((v) => v)
              .catchError((Object e) => e),
      ]);
      expect(results.whereType<DateTime>(), hasLength(1));
      expect(results.whereType<ScheduleEndedException>(), hasLength(2));
      expect(await versions(), 2);
      await expectLater(
        edit.updateSchedule(sid, same(dose: 5)),
        throwsA(isA<ScheduleEndedException>()),
      );
      expect(await versions(), 2);
    });

    test('specific dates: past dates stay with the old version', () async {
      final sid = await edit.createSchedule(
        NewSchedule(
          medicineId: await medicine(10),
          kind: ScheduleKind.dates,
          dose: 1,
          doseUnit: 'шт.',
          startDate: d17,
          dates: [d17, day, d25],
          times: const [8 * 60],
        ),
      );
      await edit.markTaken(scheduleId: sid, day: d17, minuteOfDay: 480);
      ScheduleEdit dates(List<DateTime> l) => ScheduleEdit(
        kind: ScheduleKind.dates,
        dose: 1,
        times: const [8 * 60],
        dates: l,
      );

      // The same dates, including the past one: nothing to do.
      await edit.updateSchedule(sid, dates([d17, day, d25]));
      expect(await versions(), 1);

      // Only past dates left: invalid, nothing written.
      await expectLater(
        edit.updateSchedule(sid, dates([d17])),
        throwsA(isA<InvalidScheduleException>()),
      );
      expect(await versions(), 1);

      final move = DateTime(2026, 10, 26);
      await edit.updateSchedule(sid, dates([d17, day, move]));
      expect(await versions(), 2);
      expect(await shown(d17), [(480, IntakeStatus.taken, 1.0)]);
      expect(await shown(d25), isEmpty);
      expect(await shown(move), [(480, IntakeStatus.pending, 1.0)]);
      expect(await shown(day), [(480, IntakeStatus.pending, 1.0)]);
    });

    test('an end before the start is refused and nothing changes', () async {
      final sid = await started(await medicine(10));
      await expectLater(
        edit.updateSchedule(sid, same(end: d18)),
        throwsA(isA<InvalidScheduleException>()),
      );
      final future = await edit.createSchedule(
        daily(await medicine(10, name: 'Другое')).copyWithStart(d25),
      );
      await expectLater(
        edit.updateSchedule(
          future,
          same(start: d25, end: DateTime(2026, 10, 24)),
        ),
        throwsA(isA<InvalidScheduleException>()),
      );
      expect(await versions(), 2);
      expect(
        (await db.select(db.schedules).get()).every((r) => r.endDate == null),
        isTrue,
      );
    });

    test('ending keeps the past and removes the future', () async {
      final sid = await started(await medicine(10));
      await edit.markTaken(scheduleId: sid, day: d18, minuteOfDay: 480);
      final past = await shown(d18);

      expect(await edit.endSchedule(sid), day);
      expect(await shown(day), isEmpty);
      expect(await shown(d20), isEmpty);
      expect(await shown(d18), past);
      expect(await edit.endSchedule(sid), day); // repeating changes nothing
      expect((await db.select(db.schedules).get()).single.endDate, d18);
      await expectLater(
        edit.updateSchedule(sid, same(dose: 2)),
        throwsA(isA<ScheduleEndedException>()),
      );
      await edit.resetMark(scheduleId: sid, day: d18, minuteOfDay: 480);
      expect(await total(), 10);
    });

    test("ending keeps today's marks", () async {
      final sid = await started(await medicine(10));
      await edit.markTaken(scheduleId: sid, day: day, minuteOfDay: 480);
      expect(await edit.endSchedule(sid), d20);
      expect(await shown(day), [(480, IntakeStatus.taken, 1.0)]);
      expect(await shown(d20), isEmpty);
    });

    test('ending before the first intake hides it without deleting', () async {
      final sid = await edit.createSchedule(
        daily(await medicine(10)).copyWithStart(d25),
      );
      await edit.endSchedule(sid);
      expect(await versions(), 1);
      for (final d in [day, d25, DateTime(2026, 11, 1)]) {
        expect(await shown(d), isEmpty);
      }
      expect(
        isCurrent(
          (await edit.watchReminderSource(day).first).schedules.single.schedule,
          day,
        ),
        isFalse,
      );
      await expectLater(
        edit.updateSchedule(sid, same()),
        throwsA(isA<ScheduleEndedException>()),
      );
    });
  });

  group('medicine changes and history', () {
    final d17 = DateTime(2026, 10, 17), d18 = DateTime(2026, 10, 18);
    late DriftScheduleRepository r;
    late DriftInventoryRepository inv; // archiving reads the clock too
    setUp(() {
      final fixed = DateTime(2026, 10, 19, 12);
      inv = DriftInventoryRepository(db, now: () => fixed);
      r = DriftScheduleRepository(db, inv, now: () => fixed);
    });

    Future<String> tablets() => inventory.createMedicine(
      const NewMedicine(
        name: 'Аспирин',
        form: MedicineForm.tablet,
        strength: '500 мг',
        initialQuantity: 10,
        unit: 'шт.',
      ),
    );

    Future<(String, String, String?)> look(DateTime d) async {
      final i = ((await r.watchHistory(d, d).first)[d]!).single;
      return (i.medicineName, i.medicineForm?.name ?? '-', i.medicineStrength);
    }

    test('marked intakes keep the medicine as it was marked', () async {
      final mid = await tablets();
      final sid = await r.createSchedule(daily(mid));
      await r.markTaken(scheduleId: sid, day: d17);
      await r.markSkipped(scheduleId: sid, day: d18);
      await inventory.updateMedicine(
        mid,
        const MedicineEdit(
          name: 'Аспирин Кардио',
          form: MedicineForm.capsule,
          strength: '100 мг',
        ),
      );

      expect(await look(d17), ('Аспирин', 'tablet', '500 мг'));
      expect(await look(d18), ('Аспирин', 'tablet', '500 мг'));
      // Not marked: today follows the medicine.
      expect(await look(day), ('Аспирин Кардио', 'capsule', '100 мг'));
      // The day screen shows the same.
      expect((await r.watchDay(d17).first).single.medicineName, 'Аспирин');

      // Undoing the mark removes the fact; it follows the medicine again.
      await r.resetMark(scheduleId: sid, day: d17);
      expect(await look(d17), ('Аспирин Кардио', 'capsule', '100 мг'));
      // Marking again records the medicine as it is now.
      await r.markTaken(scheduleId: sid, day: d17);
      await inventory.updateMedicine(mid, const MedicineEdit(name: 'Другое'));
      expect(await look(d17), ('Аспирин Кардио', 'capsule', '100 мг'));
    });

    test('a mark without a snapshot follows the current medicine', () async {
      final mid = await tablets();
      final sid = await r.createSchedule(daily(mid));
      await db
          .into(db.intakeLogs)
          .insert(
            IntakeLogsCompanion.insert(
              id: 'old',
              scheduleId: sid,
              day: d17,
              takenAt: DateTime(2026, 10, 17),
            ),
          );
      await inventory.updateMedicine(mid, const MedicineEdit(name: 'Новое'));
      expect((await look(d17)).$1, 'Новое');
    });

    test('archiving ends schedules and keeps the history and stock', () async {
      final mid = await tablets();
      final sid = await r.createSchedule(daily(mid));
      await r.markTaken(scheduleId: sid, day: d17);
      final stock = await total();
      await inv.archiveMedicine(mid);

      expect(await r.watchDay(day).first, isEmpty);
      expect(await r.watchDay(DateTime(2026, 10, 20)).first, isEmpty);
      expect(await look(d17), ('Аспирин', 'tablet', '500 мг'));
      expect((await r.watchDay(d17).first).single.taken, isTrue);
      expect((await db.select(db.schedules).get()).single.endDate, d18);
      expect(
        (await db.select(db.medicinePackages).get()).single.quantity,
        stock,
      );
      expect(await db.select(db.intakeDeductions).get(), hasLength(1));

      // A past mark can still be undone, into the archived medicine's package.
      await r.resetMark(scheduleId: sid, day: d17);
      expect((await db.select(db.medicinePackages).get()).single.quantity, 10);

      // No new schedules, no reminders.
      await expectLater(
        r.createSchedule(daily(mid)),
        throwsA(isA<InvalidScheduleException>()),
      );
      expect((await r.watchReminderSource(day).first).schedules, isEmpty);
    });

    test("archiving keeps today's marks: the schedule ends tomorrow", () async {
      final mid = await tablets();
      final sid = await r.createSchedule(daily(mid));
      await r.markTaken(scheduleId: sid, day: day);
      await inv.archiveMedicine(mid);
      expect((await r.watchDay(day).first).single.taken, isTrue);
      expect(await r.watchDay(DateTime(2026, 10, 20)).first, isEmpty);
    });

    test('packages in another unit are never mixed in or used up', () async {
      final mid = await tablets(); // 10 шт.
      await db
          .into(db.medicinePackages)
          .insert(
            MedicinePackagesCompanion.insert(
              id: 'ml',
              medicineId: mid,
              initialQuantity: 100,
              quantity: 100,
              unit: 'мл',
              createdAt: DateTime(2020), // older, so it would be used first
            ),
          );
      final sid = await r.createSchedule(daily(mid, dose: 4));
      await r.markTaken(scheduleId: sid, day: day);
      final q = {
        for (final p in await db.select(db.medicinePackages).get())
          p.id: p.quantity,
      };
      expect(q['ml'], 100);
      expect(q.values.where((v) => v != 100).single, 6);
      expect(await total(), 6);

      // More than the counted stock: refused, the foreign package is no help.
      final big = await r.createSchedule(daily(mid, dose: 50));
      await expectLater(
        r.markTaken(scheduleId: big, day: day),
        throwsA(isA<InsufficientStockException>()),
      );
      expect(
        (await db.select(db.medicinePackages).get())
            .firstWhere((p) => p.id == 'ml')
            .quantity,
        100,
      );
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
        await old.customStatement(
          'ALTER TABLE medicines DROP COLUMN archived_at',
        );
        await old.customStatement('ALTER TABLE medicines DROP COLUMN unit');
        await old.customStatement(
          'ALTER TABLE medicines DROP COLUMN low_stock_threshold',
        );
        await _dropV7(old);
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
      await v3.customStatement('ALTER TABLE medicines DROP COLUMN archived_at');
      await v3.customStatement('ALTER TABLE medicines DROP COLUMN unit');
      await v3.customStatement(
        'ALTER TABLE medicines DROP COLUMN low_stock_threshold',
      );
      await _dropV7(v3);
      for (final c in ['medicine_name', 'medicine_form', 'medicine_strength']) {
        await v3.customStatement('ALTER TABLE intake_logs DROP COLUMN $c');
      }
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

    test(
      'a v4 database upgrades: medicines active, one unit, marks as before',
      () async {
        final v4 = AppDatabase(NativeDatabase(file));
        final inv = DriftInventoryRepository(v4);
        final r = DriftScheduleRepository(v4, inv);
        final mid = await inv.createMedicine(
          const NewMedicine(name: 'Старое', initialQuantity: 5, unit: 'шт.'),
        );
        // A package in another unit, as data from before units were enforced.
        await v4
            .into(v4.medicinePackages)
            .insert(
              MedicinePackagesCompanion.insert(
                id: 'foreign',
                medicineId: mid,
                initialQuantity: 100,
                quantity: 100,
                unit: 'мл',
                createdAt: DateTime.now().add(const Duration(days: 1)),
              ),
            );
        final sid = await r.createSchedule(daily(mid));
        await r.markTaken(scheduleId: sid, day: day);
        final stockBefore = await v4.select(v4.medicinePackages).get();
        final logsBefore = await v4.select(v4.intakeLogs).get();

        // Turn the file back into a v4 database.
        await v4.customStatement(
          'ALTER TABLE medicines DROP COLUMN archived_at',
        );
        await v4.customStatement('ALTER TABLE medicines DROP COLUMN unit');
        await v4.customStatement(
          'ALTER TABLE medicines DROP COLUMN low_stock_threshold',
        );
        await _dropV7(v4);
        for (final c in [
          'medicine_name',
          'medicine_form',
          'medicine_strength',
        ]) {
          await v4.customStatement('ALTER TABLE intake_logs DROP COLUMN $c');
        }
        await v4.customStatement('PRAGMA user_version = 4');
        await v4.close();

        final v5 = AppDatabase(NativeDatabase(file));
        addTearDown(v5.close);
        final med = (await v5.select(v5.medicines).get()).single;
        expect(med.unit, 'шт.'); // the oldest package's unit
        expect(med.archivedAt, equals(null));
        // Nothing was removed or changed.
        expect(
          (await v5.select(v5.medicinePackages).get()).map(
            (p) => (p.id, p.quantity, p.unit),
          ),
          unorderedEquals(stockBefore.map((p) => (p.id, p.quantity, p.unit))),
        );
        final logs = await v5.select(v5.intakeLogs).get();
        expect(
          logs.map((l) => (l.id, l.status, l.deductionsTracked)),
          logsBefore.map((l) => (l.id, l.status, l.deductionsTracked)),
        );
        expect(logs.single.medicineName, equals(null));
        // The foreign-unit package is kept but never counted.
        final inv2 = DriftInventoryRepository(v5);
        final stock = (await inv2.watchStock().first).single;
        expect(stock.unit, 'шт.');
        expect(stock.totalQuantity, 4);
        expect(stock.foreign.map((p) => p.id), ['foreign']);
        // History still shows the current name for the old mark.
        final r2 = DriftScheduleRepository(v5, inv2);
        expect((await r2.watchDay(day).first).single.medicineName, 'Старое');
      },
    );

    test(
      'a v5 database upgrades: thresholds start empty, data stays',
      () async {
        final v5 = AppDatabase(NativeDatabase(file));
        final inv = DriftInventoryRepository(v5);
        final r = DriftScheduleRepository(v5, inv);
        final mid = await inv.createMedicine(
          const NewMedicine(
            name: 'Старое',
            initialQuantity: 5,
            unit: 'шт.',
            lowStockThreshold: 2,
          ),
        );
        final other = await inv.createMedicine(
          const NewMedicine(name: 'Архивное', initialQuantity: 1, unit: 'мл'),
        );
        await inv.archiveMedicine(other);
        final sid = await r.createSchedule(daily(mid));
        await r.markTaken(scheduleId: sid, day: day);
        // Turn the file back into a v5 database.
        await v5.customStatement(
          'ALTER TABLE medicines DROP COLUMN low_stock_threshold',
        );
        await _dropV7(v5);
        await v5.customStatement('PRAGMA user_version = 5');
        await v5.close();

        final v6 = AppDatabase(NativeDatabase(file));
        addTearDown(v6.close);
        final rows = await v6.select(v6.medicines).get();
        expect(rows, hasLength(2));
        expect(rows.every((m) => m.lowStockThreshold == null), isTrue);
        expect(
          rows.firstWhere((m) => m.id == other).archivedAt != null,
          isTrue,
        );
        final inv2 = DriftInventoryRepository(v6);
        expect((await inv2.watchStock().first).single.totalQuantity, 4);
        expect(
          (await DriftScheduleRepository(
            v6,
            inv2,
          ).watchDay(day).first).single.taken,
          isTrue,
        );
        // A threshold can be set on the migrated database.
        await inv2.updateMedicine(
          mid,
          const MedicineEdit(name: 'Старое', lowStockThreshold: 3),
        );
        expect(
          (await inv2.watchStock().first).single.medicine.lowStockThreshold,
          3,
        );
      },
    );

    test('a v1 database upgrades to v2 and keeps its data', () async {
      final v1 = AppDatabase(NativeDatabase(file));
      final inv = DriftInventoryRepository(v1);
      await inv.createMedicine(
        const NewMedicine(name: 'Старое', initialQuantity: 3, unit: 'шт.'),
      );
      // Turn the file back into a v1 database.
      await v1.customStatement('ALTER TABLE medicines DROP COLUMN archived_at');
      await v1.customStatement('ALTER TABLE medicines DROP COLUMN unit');
      await v1.customStatement(
        'ALTER TABLE medicines DROP COLUMN low_stock_threshold',
      );
      await _dropV7(v1);
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

extension on NewSchedule {
  NewSchedule copyWithStart(DateTime start) => NewSchedule(
    medicineId: medicineId,
    kind: kind,
    dose: dose,
    doseUnit: doseUnit,
    startDate: start,
    times: times,
  );
}

/// Takes what v7 added out of a fresh database, to look like a v6 one.
Future<void> _dropV7(AppDatabase db) async {
  for (final c in ['category', 'storage', 'look']) {
    await db.customStatement('ALTER TABLE medicines DROP COLUMN $c');
  }
  await db.customStatement('ALTER TABLE schedules DROP COLUMN meal_relation');
  await db.customStatement('DROP TABLE shopping_items');
  await db.customStatement('DROP TABLE app_settings');
  // v8 and everything after it, which older files do not have either.
  await db.customStatement('DROP TABLE diary_entries');
}
