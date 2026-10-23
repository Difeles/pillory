import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/l10n/l10n.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/data/app_database.dart';
import 'package:pillory/data/backup_format.dart';
import 'package:pillory/data/drift_backup_repository.dart';
import 'package:pillory/data/drift_inventory_repository.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/features/profile/backup_files.dart';
import 'package:pillory/features/profile/settings_screen.dart';

import '../support/fake_diary_repository.dart';
import '../support/fake_extras_repository.dart';
import '../support/fake_inventory_repository.dart';

class _Files implements BackupFiles {
  Uint8List? picked;
  final saved = <Uint8List>[];

  @override
  Future<bool> save(
    String fileName,
    Uint8List bytes, {
    String mimeType = 'application/json',
  }) async {
    expect(fileName, endsWith('.pillory-backup'));
    saved.add(bytes);
    return true;
  }

  @override
  Future<Uint8List?> pick() async => picked;
}

void main() {
  late AppDatabase db;
  late _Files files;
  final inventory = FakeInventoryRepository();

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    files = _Files();
  });
  tearDown(() => db.close());

  Future<void> medicine(AppDatabase to, String name) =>
      DriftInventoryRepository(to).createMedicine(
        NewMedicine(name: name, initialQuantity: 5, unit: 'шт.'),
      );

  Future<List<String>> names() async =>
      (await db.select(db.medicines).get()).map((m) => m.name).toList();

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          // The screen's other data comes from fakes: a real database stream
          // does not complete under the widget tester's clock.
          extrasRepositoryProvider.overrideWithValue(FakeExtrasRepository()),
          diaryRepositoryProvider.overrideWithValue(FakeDiaryRepository()),
          inventoryRepositoryProvider.overrideWithValue(inventory),
          scheduleRepositoryProvider.overrideWithValue(
            FakeScheduleRepository(inventory),
          ),
          backupFilesProvider.overrideWithValue(files),
        ],
        child: MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: supportedAppLocales,
          localizationsDelegates: appLocalizationsDelegates,
          home: const SettingsScreen(),
        ),
      ),
    );
  }

  /// A valid file with one medicine, made by a second database.
  Future<Uint8List> fileWith(String name) async {
    final other = AppDatabase(NativeDatabase.memory());
    await medicine(other, name);
    final bytes = utf8.encode(
      encodeBackup(await DriftBackupRepository(other).read()),
    );
    await other.close();
    return Uint8List.fromList(bytes);
  }

  testWidgets('saving hands the file to the system dialog', (tester) async {
    await medicine(db, 'Аспирин');
    await open(tester);
    await tester.scrollUntilVisible(
      find.text('Сохранить резервную копию'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Сохранить резервную копию'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить резервную копию'));
    await tester.pumpAndSettle();

    expect(files.saved, hasLength(1));
    expect(utf8.decode(files.saved.single), contains('"Аспирин"'));
    expect(find.text('Копия сохранена'), findsOneWidget);
  });

  testWidgets('cancelling the confirmation changes nothing', (tester) async {
    await medicine(db, 'Старое');
    files.picked = await tester.runAsync(() => fileWith('Новое'));
    await open(tester);
    await tester.scrollUntilVisible(
      find.text('Восстановить из копии'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Восстановить из копии'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Восстановить из копии'));
    await tester.pumpAndSettle();

    expect(find.text('Заменить данные?'), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(await tester.runAsync(names), ['Старое']);
  });

  testWidgets('confirming replaces everything', (tester) async {
    await medicine(db, 'Старое');
    files.picked = await tester.runAsync(() => fileWith('Новое'));
    await open(tester);
    await tester.scrollUntilVisible(
      find.text('Восстановить из копии'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Восстановить из копии'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Восстановить из копии'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Заменить'));
    // The database works in real time, outside the test's fake clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();

    expect(await tester.runAsync(names), ['Новое']);
    expect(find.text('Данные восстановлены'), findsOneWidget);
  });

  testWidgets('"save first" exports and keeps asking', (tester) async {
    await medicine(db, 'Старое');
    files.picked = await tester.runAsync(() => fileWith('Новое'));
    await open(tester);
    await tester.scrollUntilVisible(
      find.text('Восстановить из копии'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Восстановить из копии'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Восстановить из копии'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сначала сохранить текущие'));
    await tester.pumpAndSettle();

    expect(files.saved, hasLength(1));
    expect(find.text('Заменить данные?'), findsOneWidget);
    expect(await tester.runAsync(names), ['Старое']);
  });

  testWidgets('a bad file is reported and nothing changes', (tester) async {
    await medicine(db, 'Старое');
    files.picked = Uint8List.fromList(utf8.encode('{"nope": true}'));
    await open(tester);
    await tester.scrollUntilVisible(
      find.text('Восстановить из копии'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Восстановить из копии'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Восстановить из копии'));
    await tester.pumpAndSettle();

    expect(find.text('Это не резервная копия PillPal'), findsOneWidget);
    expect(find.text('Заменить данные?'), findsNothing);
    expect(await tester.runAsync(names), ['Старое']);
  });

  testWidgets('an empty device restores without the warning', (tester) async {
    files.picked = await tester.runAsync(() => fileWith('Новое'));
    await open(tester);
    await tester.scrollUntilVisible(
      find.text('Восстановить из копии'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Восстановить из копии'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Восстановить из копии'));
    await tester.pumpAndSettle();

    expect(find.text('Заменить данные?'), findsNothing);
    expect(await tester.runAsync(names), ['Новое']);
  });
}
