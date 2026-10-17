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

  NewSchedule daily(String medicineId, {double dose = 1, int? minute}) =>
      NewSchedule(
        medicineId: medicineId,
        kind: ScheduleKind.daily,
        dose: dose,
        doseUnit: 'шт.',
        startDate: DateTime(2026, 10, 1),
        minuteOfDay: minute,
      );

  Future<List<DayIntake>> intakes([DateTime? d]) =>
      repo.watchDay(d ?? day).first;
  Future<double> total() async =>
      (await inventory.watchStock().first).single.totalQuantity;

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
      final sid = await r.createSchedule(daily(id, minute: 8 * 60 + 30));
      await r.markTaken(scheduleId: sid, day: day);
      await first.close();

      final second = AppDatabase(NativeDatabase(file));
      addTearDown(second.close);
      final inv2 = DriftInventoryRepository(second);
      final r2 = DriftScheduleRepository(second, inv2);
      final i = (await r2.watchDay(day).first).single;
      expect(i.schedule.minuteOfDay, 510);
      expect(i.taken, isTrue);
      expect((await inv2.watchStock().first).single.totalQuantity, 7);
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
