import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/data/app_database.dart';
import 'package:pillory/data/backup_format.dart';
import 'package:pillory/data/drift_backup_repository.dart';
import 'package:pillory/data/drift_inventory_repository.dart';
import 'package:pillory/design_system/widgets/pill_view.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/domain/pill_look.dart';
import 'package:pillory/features/inventory/add_medicine_screen.dart';
import 'package:pillory/l10n/l10n.dart';

import '../support/fake_extras_repository.dart';
import '../support/fake_inventory_repository.dart';

void main() {
  group('PillLook', () {
    test('survives encoding', () {
      const look = PillLook(
        shape: PillShape.capsule,
        color: 0xFFE5566D,
        color2: 0xFFFFFFFF,
      );
      expect(PillLook.tryParse(look.encode()), look);
      const scored = PillLook(score: PillScore.cross, color: 0xFF4F8EF0);
      expect(PillLook.tryParse(scored.encode()), scored);
    });

    test('text that is not a look is refused', () {
      for (final bad in [null, '', 'round', 'x:ff::none', 'round:zz::none']) {
        expect(PillLook.tryParse(bad), isNull, reason: '$bad');
      }
    });
  });

  group('storage', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('a look is saved, edited, cleared and backed up', () async {
      final repo = DriftInventoryRepository(db);
      const look = PillLook(shape: PillShape.oval, score: PillScore.line);
      final id = await repo.createMedicine(
        const NewMedicine(
          name: 'Аспирин',
          initialQuantity: 5,
          unit: 'шт.',
          look: look,
        ),
      );
      Future<Medicine> medicine() async =>
          (await repo.watchStock().first).single.medicine;
      expect((await medicine()).look, look);

      final backup = parseBackup(
        Uint8List.fromList(
          utf8.encode(encodeBackup(await DriftBackupRepository(db).read())),
        ),
      );
      expect(backup.medicines.single.look, look.encode());

      await repo.updateMedicine(
        id,
        const MedicineEdit(
          name: 'Аспирин',
          look: PillLook(shape: PillShape.capsule, color: 0xFFE5566D),
        ),
      );
      expect((await medicine()).look!.shape, PillShape.capsule);
      await repo.updateMedicine(id, const MedicineEdit(name: 'Аспирин'));
      expect((await medicine()).look, isNull);
    });
  });

  testWidgets('the pill is drawn for tablets and capsules only', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryRepositoryProvider.overrideWithValue(
            FakeInventoryRepository(),
          ),
          extrasRepositoryProvider.overrideWithValue(FakeExtrasRepository()),
        ],
        child: MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: supportedAppLocales,
          localizationsDelegates: appLocalizationsDelegates,
          home: const AddMedicineScreen(),
        ),
      ),
    );
    expect(find.text('Разрез'), findsNothing);

    await tester.tap(find.text('Таблетки'));
    await tester.pumpAndSettle();
    expect(find.text('Разрез'), findsOneWidget);
    expect(find.text('Форма'), findsOneWidget);
    expect(find.text('Цвет второй половины'), findsNothing);

    await tester.tap(find.text('Капсулы'));
    await tester.pumpAndSettle();
    expect(find.text('Цвет второй половины'), findsOneWidget);
    expect(find.text('Разрез'), findsNothing);
    expect(find.text('Форма'), findsNothing);

    await tester.tap(find.text('Сироп'));
    await tester.pumpAndSettle();
    expect(find.text('Цвет второй половины'), findsNothing);
    expect(find.byType(PillView), findsNothing);
  });
}
