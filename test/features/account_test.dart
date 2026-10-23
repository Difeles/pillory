import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/app.dart';
import 'package:pillory/app/cloud_sync.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/data/app_database.dart';
import 'package:pillory/data/drift_backup_repository.dart';

import '../support/fake_cloud_service.dart';
import '../support/fake_diary_repository.dart';
import '../support/fake_extras_repository.dart';
import '../support/fake_inventory_repository.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    FakeCloudService? cloud,
    CloudSync? sync,
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final inventory = FakeInventoryRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryRepositoryProvider.overrideWithValue(inventory),
          extrasRepositoryProvider.overrideWithValue(FakeExtrasRepository()),
          diaryRepositoryProvider.overrideWithValue(FakeDiaryRepository()),
          scheduleRepositoryProvider.overrideWithValue(
            FakeScheduleRepository(inventory),
          ),
          if (cloud != null) cloudServiceProvider.overrideWithValue(cloud),
          if (sync != null) cloudSyncProvider.overrideWithValue(sync),
        ],
        child: const PilloryApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Аккаунт и облако'));
    await tester.pumpAndSettle();
  }

  testWidgets('without a connected cloud the screen says so', (tester) async {
    await open(tester);
    expect(find.textContaining('пока не подключено'), findsOneWidget);
    expect(find.text('Войти'), findsNothing);
  });

  testWidgets('signing in asks for both fields and reports a bad password', (
    tester,
  ) async {
    final cloud = FakeCloudService();
    await cloud.register('a@b.c', 'secret1');
    await cloud.signOut();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final sync = CloudSync(
      cloud: cloud,
      backups: DriftBackupRepository(db),
      extras: FakeExtrasRepository(),
      localChanges: const Stream.empty(),
      afterRestore: () async {},
    );
    await open(tester, cloud: cloud, sync: sync);

    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(find.text('Введите почту и пароль'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Электронная почта'),
      'a@b.c',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Пароль'), 'wrong');
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(find.text('Неверная почта или пароль'), findsOneWidget);
  });
}
