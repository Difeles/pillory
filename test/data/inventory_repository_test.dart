import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/data/app_database.dart';
import 'package:pillory/data/drift_inventory_repository.dart';
import 'package:pillory/domain/errors.dart';
import 'package:pillory/domain/medicine_form.dart';
import 'package:pillory/domain/models.dart';

void main() {
  late AppDatabase db;
  late DriftInventoryRepository repo;
  var tick = 0;

  // Every call gets a later instant, so history order is unambiguous.
  DateTime clock() => DateTime(2026, 10, 17, 12).add(Duration(seconds: tick++));

  setUp(() {
    tick = 0;
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftInventoryRepository(db, now: clock);
  });
  tearDown(() => db.close());

  const aspirin = NewMedicine(
    name: 'Аспирин',
    form: MedicineForm.tablet,
    strength: '500 мг',
    initialQuantity: 10,
    unit: 'шт.',
  );

  Future<MedicineStock> only() async => (await repo.watchStock().first).single;

  group('creating', () {
    test(
      'creates the medicine, its first package and an initial history entry',
      () async {
        await repo.createMedicine(
          NewMedicine(
            name: 'Аспирин',
            form: MedicineForm.tablet,
            strength: '500 мг',
            initialQuantity: 10,
            unit: 'шт.',
            expiresOn: DateTime(2027, 3, 5, 23, 59),
          ),
        );

        final stock = await only();
        expect(stock.medicine.name, 'Аспирин');
        expect(stock.medicine.form, MedicineForm.tablet);
        expect(stock.medicine.strength, '500 мг');
        expect(stock.packages, hasLength(1));
        final package = stock.packages.single;
        expect(package.medicineId, stock.medicine.id);
        expect(package.initialQuantity, 10);
        expect(package.quantity, 10);
        expect(package.unit, 'шт.');
        // Stored as a calendar date: the time of day is gone.
        expect(package.expiresOn, DateTime(2027, 3, 5));

        final history = await repo.history(package.id);
        expect(history, hasLength(1));
        expect(history.single.kind, TransactionKind.initial);
        expect(history.single.delta, 10);
        expect(history.single.quantityAfter, 10);
      },
    );

    test('optional fields may be missing', () async {
      await repo.createMedicine(
        const NewMedicine(name: 'Бинт', initialQuantity: 2, unit: 'шт.'),
      );
      final stock = await only();
      expect(stock.medicine.form, isNull);
      expect(stock.medicine.strength, isNull);
      expect(stock.primaryPackage.expiresOn, isNull);
    });

    test('invalid input writes nothing', () async {
      await expectLater(
        repo.createMedicine(
          const NewMedicine(name: '  ', initialQuantity: 1, unit: 'шт.'),
        ),
        throwsA(isA<InvalidMedicineException>()),
      );
      await expectLater(
        repo.createMedicine(
          const NewMedicine(name: 'X', initialQuantity: -1, unit: 'шт.'),
        ),
        throwsA(isA<InvalidMedicineException>()),
      );
      expect(await repo.watchStock().first, isEmpty);
      expect(await db.select(db.inventoryTransactions).get(), isEmpty);
    });

    test('lists medicines by name regardless of case', () async {
      for (final n in ['ибупрофен', 'Аспирин', 'Цитрамон']) {
        await repo.createMedicine(
          NewMedicine(name: n, initialQuantity: 1, unit: 'шт.'),
        );
      }
      final names = (await repo.watchStock().first)
          .map((s) => s.medicine.name)
          .toList();
      expect(names, ['Аспирин', 'ибупрофен', 'Цитрамон']);
    });
  });

  group('adjusting quantity', () {
    test('increase and decrease update the quantity and the history', () async {
      await repo.createMedicine(aspirin);
      final packageId = (await only()).primaryPackage.id;

      await repo.adjustQuantity(packageId: packageId, delta: 5);
      await repo.adjustQuantity(packageId: packageId, delta: -3);

      expect((await only()).primaryPackage.quantity, 12);
      final history = await repo.history(packageId); // newest first
      expect(history.map((t) => t.kind), [
        TransactionKind.decrease,
        TransactionKind.increase,
        TransactionKind.initial,
      ]);
      expect(history.map((t) => t.delta), [-3, 5, 10]);
      expect(history.map((t) => t.quantityAfter), [12, 15, 10]);
    });

    test('can go down to exactly zero', () async {
      await repo.createMedicine(aspirin);
      final id = (await only()).primaryPackage.id;
      await repo.adjustQuantity(packageId: id, delta: -10);
      expect((await only()).primaryPackage.quantity, 0);
    });

    test(
      'refuses to go below zero and leaves quantity and history untouched',
      () async {
        await repo.createMedicine(aspirin);
        final id = (await only()).primaryPackage.id;
        await repo.adjustQuantity(packageId: id, delta: -10);
        final before = (await repo.history(id)).length;

        await expectLater(
          repo.adjustQuantity(packageId: id, delta: -1),
          throwsA(isA<InsufficientStockException>()),
        );

        expect((await only()).primaryPackage.quantity, 0);
        expect(await repo.history(id), hasLength(before));
      },
    );

    test('unknown package and zero delta are rejected', () async {
      await expectLater(
        repo.adjustQuantity(packageId: 'nope', delta: 1),
        throwsA(isA<PackageNotFoundException>()),
      );
      await repo.createMedicine(aspirin);
      final id = (await only()).primaryPackage.id;
      await expectLater(
        repo.adjustQuantity(packageId: id, delta: 0),
        throwsArgumentError,
      );
    });

    test('the database itself refuses a negative quantity', () async {
      await repo.createMedicine(aspirin);
      await expectLater(
        db.customStatement('UPDATE medicine_packages SET quantity = -1'),
        throwsA(anything),
      );
    });

    test('the stock stream re-emits after a change', () async {
      await repo.createMedicine(aspirin);
      final id = (await only()).primaryPackage.id;
      final seen = <double>[];
      final sub = repo.watchStock().listen(
        (s) => seen.add(s.single.totalQuantity),
      );
      await pumpEventQueue(times: 200);
      await repo.adjustQuantity(packageId: id, delta: 1);
      await pumpEventQueue(times: 200);
      await sub.cancel();
      expect(seen, [10, 11]);
    });
  });

  group('several packages of one medicine', () {
    test('keep their own expiry dates, quantities and histories', () async {
      final medicineId = await repo.createMedicine(
        NewMedicine(
          name: 'Аспирин',
          initialQuantity: 10,
          unit: 'шт.',
          expiresOn: DateTime(2027, 6, 1),
        ),
      );
      final secondId = await repo.addPackage(
        medicineId: medicineId,
        quantity: 20,
        unit: 'шт.',
        expiresOn: DateTime(2026, 12, 1),
      );

      final stock = await only();
      expect(stock.packages, hasLength(2));
      expect(stock.totalQuantity, 30);
      // Different expiry dates stay separate; the earliest one is reported.
      expect(stock.nearestExpiry, DateTime(2026, 12, 1));

      await repo.adjustQuantity(packageId: secondId, delta: -5);
      final first = (await only()).packages.first;
      expect(first.quantity, 10);
      expect(await repo.history(first.id), hasLength(1));
      expect(await repo.history(secondId), hasLength(2));
    });
  });

  test('deleting a medicine removes its packages and history', () async {
    final id = await repo.createMedicine(aspirin);
    await (db.delete(db.medicines)..where((m) => m.id.equals(id))).go();
    expect(await db.select(db.medicinePackages).get(), isEmpty);
    expect(await db.select(db.inventoryTransactions).get(), isEmpty);
  });

  test('data survives closing and reopening the database file', () async {
    // Two databases on purpose (closed and reopened, like an app restart).
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(
      () => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false,
    );
    final dir = await Directory.systemTemp.createTemp('pillory_test_');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/pillory.sqlite');

    final first = AppDatabase(NativeDatabase(file));
    final firstRepo = DriftInventoryRepository(first);
    await firstRepo.createMedicine(
      NewMedicine(
        name: 'Нурофен',
        initialQuantity: 8,
        unit: 'шт.',
        expiresOn: DateTime(2027, 1, 31),
      ),
    );
    final packageId =
        (await firstRepo.watchStock().first).single.primaryPackage.id;
    await firstRepo.adjustQuantity(packageId: packageId, delta: -3);
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    final secondRepo = DriftInventoryRepository(second);
    final stock = (await secondRepo.watchStock().first).single;
    expect(stock.medicine.name, 'Нурофен');
    expect(stock.primaryPackage.quantity, 5);
    expect(stock.primaryPackage.expiresOn, DateTime(2027, 1, 31));
    expect(await secondRepo.history(packageId), hasLength(2));
  });
}
