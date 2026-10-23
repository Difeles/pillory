import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/cloud_sync.dart';
import 'package:pillory/data/app_database.dart';
import 'package:pillory/data/backup_format.dart';
import 'package:pillory/data/drift_backup_repository.dart';
import 'package:pillory/data/drift_inventory_repository.dart';
import 'package:pillory/domain/models.dart';

import '../support/fake_cloud_service.dart';
import '../support/fake_extras_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const email = 'a@b.c';
  late AppDatabase db;
  late FakeCloudService cloud;
  late FakeExtrasRepository extras;
  late CloudSync sync;
  var restores = 0;

  CloudSync newSync(AppDatabase on) => CloudSync(
    cloud: cloud,
    backups: DriftBackupRepository(on),
    extras: extras,
    localChanges: mergeSignals([
      on
          .tableUpdates()
          .where((u) => u.any((x) => x.table != 'app_settings'))
          .map((_) {}),
      extras.userSettingsChanged,
    ]),
    afterRestore: () async => restores++,
    debounce: const Duration(milliseconds: 20),
  );

  Future<void> medicine(AppDatabase on, String name) =>
      DriftInventoryRepository(on).createMedicine(
        NewMedicine(name: name, initialQuantity: 5, unit: 'шт.'),
      );

  Future<List<String>> names(AppDatabase on) async =>
      (await on.select(on.medicines).get()).map((m) => m.name).toList();

  /// Lets streams and timers run, then waits for the sync to finish.
  Future<void> settle() async {
    for (var i = 0; i < 6; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      await sync.idle;
    }
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    cloud = FakeCloudService();
    extras = FakeExtrasRepository();
    restores = 0;
    sync = newSync(db)..start();
  });
  tearDown(() async {
    await sync.dispose();
    await db.close();
  });

  test(
    'the first sign-in uploads a device the cloud knows nothing of',
    () async {
      await medicine(db, 'Аспирин');
      await cloud.register(email, 'secret1');
      await settle();

      expect(sync.state.value.phase, CloudPhase.idle);
      expect(cloud.snapshotOf(email)!.revision, 1);
      expect(cloud.snapshotOf(email)!.json, contains('Аспирин'));
    },
  );

  test('an empty device takes what the cloud has', () async {
    final other = AppDatabase(NativeDatabase.memory());
    addTearDown(other.close);
    await medicine(other, 'Нурофен');
    cloud.plant(
      email,
      encodeBackup(await DriftBackupRepository(other).read()),
      3,
    );

    await cloud.register(email, 'secret1');
    await settle();

    expect(await names(db), ['Нурофен']);
    expect(restores, 1);
    expect(sync.state.value.phase, CloudPhase.idle);
    expect(cloud.pushes, 0, reason: 'the restore is not a change to upload');
  });

  test('data on both sides is a conflict the user settles', () async {
    final other = AppDatabase(NativeDatabase.memory());
    addTearDown(other.close);
    await medicine(other, 'Облачное');
    cloud.plant(
      email,
      encodeBackup(await DriftBackupRepository(other).read()),
      2,
    );
    await medicine(db, 'Локальное');

    await cloud.register(email, 'secret1');
    await settle();
    expect(sync.state.value.phase, CloudPhase.conflict);
    expect(await names(db), ['Локальное']);

    await sync.resolve(useCloud: true);
    await settle();
    expect(await names(db), ['Облачное']);
    expect(sync.state.value.phase, CloudPhase.idle);
  });

  test('or the device wins and replaces the cloud', () async {
    final other = AppDatabase(NativeDatabase.memory());
    addTearDown(other.close);
    await medicine(other, 'Облачное');
    cloud.plant(
      email,
      encodeBackup(await DriftBackupRepository(other).read()),
      2,
    );
    await medicine(db, 'Локальное');
    await cloud.register(email, 'secret1');
    await settle();

    await sync.resolve(useCloud: false);
    await settle();
    expect(cloud.snapshotOf(email)!.revision, 3);
    expect(cloud.snapshotOf(email)!.json, contains('Локальное'));
    expect(await names(db), ['Локальное']);
  });

  test('a later change is uploaded once and does not loop', () async {
    await cloud.register(email, 'secret1');
    await settle();
    expect(cloud.pushes, 0, reason: 'nothing to upload from an empty device');

    await medicine(db, 'Аспирин');
    await settle();
    final pushed = cloud.pushes;
    expect(pushed, greaterThan(0));
    expect(cloud.snapshotOf(email)!.json, contains('Аспирин'));
    await settle();
    expect(cloud.pushes, pushed, reason: 'the upload is not itself a change');
  });

  test('returning to the app downloads a newer cloud revision', () async {
    await medicine(db, 'Аспирин');
    await cloud.register(email, 'secret1');
    await settle();
    final rev = cloud.snapshotOf(email)!.revision;

    final other = AppDatabase(NativeDatabase.memory());
    addTearDown(other.close);
    await medicine(other, 'С другого телефона');
    cloud.plant(
      email,
      encodeBackup(await DriftBackupRepository(other).read()),
      rev + 1,
    );
    await sync.syncNow();
    await settle();

    expect(await names(db), ['С другого телефона']);
    expect(sync.state.value.phase, CloudPhase.idle);
  });

  test('a newer cloud revision with local changes too is a conflict', () async {
    await cloud.register(email, 'secret1');
    await settle();
    await medicine(db, 'Локальное');
    // Offline: the change stays unsent.
    cloud.offline = true;
    await settle();
    cloud.offline = false;

    final other = AppDatabase(NativeDatabase.memory());
    addTearDown(other.close);
    await medicine(other, 'Чужое');
    cloud.plant(
      email,
      encodeBackup(await DriftBackupRepository(other).read()),
      9,
    );
    await sync.syncNow();
    await settle();
    expect(sync.state.value.phase, CloudPhase.conflict);
  });

  test('a failed upload is reported and retried by syncNow', () async {
    await cloud.register(email, 'secret1');
    await settle();
    cloud.offline = true;
    await medicine(db, 'Аспирин');
    await settle();
    expect(sync.state.value.phase, CloudPhase.error);
    expect(sync.state.value.problem, CloudSyncProblem.network);

    cloud.offline = false;
    await sync.syncNow();
    await settle();
    expect(sync.state.value.phase, CloudPhase.idle);
    expect(cloud.snapshotOf(email)!.json, contains('Аспирин'));
  });

  test(
    'a change of settings alone is uploaded, a device setting is not',
    () async {
      await medicine(db, 'Аспирин');
      await cloud.register(email, 'secret1');
      await settle();
      final pushes = cloud.pushes;

      await extras.setPref('local.something', '1');
      await settle();
      expect(
        cloud.pushes,
        pushes,
        reason: 'device settings stay on the device',
      );

      await extras.setPref('language', 'en');
      await settle();
      expect(cloud.pushes, pushes + 1);
    },
  );

  test('signing out forgets the account and keeps the data', () async {
    await medicine(db, 'Аспирин');
    await cloud.register(email, 'secret1');
    await settle();
    await sync.signOut();
    expect(sync.state.value.phase, CloudPhase.signedOut);
    expect(await names(db), ['Аспирин']);
    expect(await extras.getPref('local.cloudUid'), '');
  });

  test('device settings are not part of the backup', () async {
    await extras.setPref('local.cloudRevision', '4');
    await db
        .into(db.appSettings)
        .insert(AppSettingsCompanion.insert(key: 'local.x', value: '1'));
    await db
        .into(db.appSettings)
        .insert(AppSettingsCompanion.insert(key: 'theme', value: 'dark'));
    final data = await DriftBackupRepository(db).read();
    expect(data.settings.map((s) => s.key), ['theme']);

    await DriftBackupRepository(db).restore(data);
    final kept = await db.select(db.appSettings).get();
    expect(kept.map((s) => s.key).toSet(), {'local.x', 'theme'});
  });
}
