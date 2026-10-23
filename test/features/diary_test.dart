import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/app.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/data/app_database.dart';
import 'package:pillory/data/backup_format.dart';
import 'package:pillory/data/drift_backup_repository.dart';
import 'package:pillory/data/drift_cycle_repository.dart';
import 'package:pillory/data/drift_diary_repository.dart';
import 'package:pillory/domain/diary.dart';

import '../support/fake_diary_repository.dart';
import '../support/fake_extras_repository.dart';
import '../support/fake_inventory_repository.dart';

void main() {
  final at = DateTime(2026, 10, 20, 9, 30);

  group('validation', () {
    test('an empty entry is refused, any one value is enough', () {
      expect(validateDiaryEntry(NewDiaryEntry(at: at)), isNotNull);
      expect(validateDiaryEntry(NewDiaryEntry(at: at, mood: 3)), isNull);
      expect(validateDiaryEntry(NewDiaryEntry(at: at, note: '  ')), isNotNull);
    });

    test('too many troubles are refused', () {
      final many = [for (var i = 0; i < 13; i++) 'x$i'];
      expect(
        validateDiaryEntry(NewDiaryEntry(at: at, symptoms: many)),
        isNotNull,
      );
      expect(
        validateDiaryEntry(NewDiaryEntry(at: at, symptoms: ['headache'])),
        isNull,
      );
    });
  });

  group('storage', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('entries come back newest first', () async {
      final repo = DriftDiaryRepository(db);
      await repo.add(NewDiaryEntry(at: at, mood: 4));
      await repo.add(
        NewDiaryEntry(
          at: at.add(const Duration(hours: 5)),
          symptoms: ['headache', 'Мои ушки'],
        ),
      );
      final list = await repo.watchEntries().first;
      expect(list.first.symptoms, ['headache', 'Мои ушки']);
      expect(list.last.symptoms, isEmpty);
      await repo.delete(list.first.id);
      expect((await repo.watchEntries().first).single.mood, 4);
    });

    test('migraine and period days survive a backup', () async {
      await DriftDiaryRepository(db).add(NewDiaryEntry(at: at, migraine: 3));
      final cycle = DriftCycleRepository(db);
      await cycle.setDay(DateTime(2026, 10, 1), on: true);
      await cycle.setDay(DateTime(2026, 10, 2), on: true);
      await cycle.setDay(DateTime(2026, 10, 2), on: false);
      final bytes = Uint8List.fromList(
        encodeBackup(await DriftBackupRepository(db).read()).codeUnits,
      );
      final parsed = parseBackup(bytes);
      expect(parsed.diary.single.migraine, 3);
      expect(parsed.periodDays.map((p) => p.day), [DateTime(2026, 10, 1)]);

      final other = AppDatabase(NativeDatabase.memory());
      addTearDown(other.close);
      await DriftBackupRepository(other).restore(parsed);
      expect((await DriftCycleRepository(other).watchDays().first), {
        DateTime(2026, 10, 1),
      });
      expect(
        (await DriftDiaryRepository(
          other,
        ).watchEntries().first).single.migraine,
        3,
      );
    });

    test('a backup carries the diary, shopping list and settings', () async {
      await DriftDiaryRepository(db)
          .add(NewDiaryEntry(at: at, symptoms: ['cough']));
      await db
          .into(db.appSettings)
          .insert(AppSettingsCompanion.insert(key: 'k', value: 'v'));
      final repo = DriftBackupRepository(db);
      final bytes = Uint8List.fromList(
        encodeBackup(await repo.read()).codeUnits,
      );
      final parsed = parseBackup(bytes);
      expect(parsed.diary.single.symptoms, contains('cough'));
      expect(parsed.settings.single.key, 'k');

      final other = AppDatabase(NativeDatabase.memory());
      addTearDown(other.close);
      await DriftBackupRepository(other).restore(parsed);
      expect(
        decodeSymptoms(
          (await other.select(other.diaryEntries).get()).single.symptoms,
        ),
        ['cough'],
      );
    });

    test('a copy from before the diary leaves the diary alone', () async {
      await DriftDiaryRepository(db)
          .add(NewDiaryEntry(at: at, symptoms: ['cough']));
      final old = BackupData(
        schemaVersion: 7,
        medicines: const [],
        packages: const [],
        transactions: const [],
        schedules: const [],
        intakeLogs: const [],
        intakeDeductions: const [],
      );
      await DriftBackupRepository(db).restore(old);
      expect(await db.select(db.diaryEntries).get(), hasLength(1));
    });
  });

  testWidgets('a diary entry is added from the profile', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final inventory = FakeInventoryRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryRepositoryProvider.overrideWithValue(inventory),
          extrasRepositoryProvider.overrideWithValue(FakeExtrasRepository()),
          scheduleRepositoryProvider.overrideWithValue(
            FakeScheduleRepository(inventory),
          ),
          diaryRepositoryProvider.overrideWithValue(FakeDiaryRepository()),
        ],
        child: const PilloryApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Дневник самочувствия'));
    await tester.tap(find.text('Дневник самочувствия'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Отмечайте самочувствие'), findsOneWidget);

    await tester.tap(find.text('Запись'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Заполните хотя бы одно поле'), findsOneWidget);

    await tester.tap(find.byTooltip('Хорошо'));
    expect(find.text('Слабая'), findsNothing);
    await tester.tap(find.text('Головная боль'));
    await tester.pumpAndSettle();
    expect(find.text('Слабая'), findsOneWidget);
    await tester.tap(find.text('Другое'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Шум в ушах');
    await tester.tap(find.text('Сохранить').last);
    await tester.pumpAndSettle();
    expect(find.text('Шум в ушах'), findsOneWidget);
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(find.byType(Chip), findsNWidgets(2));
    expect(find.byTooltip('Хорошо'), findsOneWidget);
  });

  testWidgets('a migraine shows in the diary calendar', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final inventory = FakeInventoryRepository();
    final diary = FakeDiaryRepository();
    await diary.add(NewDiaryEntry(at: DateTime.now(), migraine: 3));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryRepositoryProvider.overrideWithValue(inventory),
          extrasRepositoryProvider.overrideWithValue(FakeExtrasRepository()),
          scheduleRepositoryProvider.overrideWithValue(
            FakeScheduleRepository(inventory),
          ),
          diaryRepositoryProvider.overrideWithValue(diary),
        ],
        child: const PilloryApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Дневник самочувствия'));
    await tester.tap(find.text('Дневник самочувствия'));
    await tester.pumpAndSettle();
    expect(find.text('Дней с мигренью в этом месяце: 1'), findsOneWidget);
    expect(find.text('Мигрень: Сильная'), findsOneWidget);

    // The day can be chosen to show only its entries.
    await tester.tap(find.bySemanticsLabel(RegExp('Мигрень: Сильная')).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Записи за'), findsOneWidget);
  });
}
