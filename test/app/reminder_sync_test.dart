import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/reminder_sync.dart';
import 'package:pillory/data/app_database.dart';
import 'package:pillory/data/drift_inventory_repository.dart';
import 'package:pillory/data/drift_schedule_repository.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/domain/reminders.dart';
import 'package:pillory/domain/schedule.dart';

import '../support/fake_reminder_scheduler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftInventoryRepository inventory;
  late DriftScheduleRepository repo;
  late FakeReminderScheduler scheduler;
  late ReminderSync sync;
  // Monday 07:00.
  final now = DateTime(2026, 10, 19, 7);
  final today = DateTime(2026, 10, 19);

  ReminderSync newSync() => ReminderSync(repo, scheduler, now: () => now);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    inventory = DriftInventoryRepository(db, now: () => now);
    repo = DriftScheduleRepository(db, inventory, now: () => now);
    scheduler = FakeReminderScheduler();
    sync = newSync()..start();
  });
  tearDown(() async {
    await sync.dispose();
    await db.close();
  });

  /// Lets database streams emit and the sync finish its passes.
  Future<void> settle() async {
    for (var i = 0; i < 3; i++) {
      await pumpEventQueue();
      await sync.idle;
    }
  }

  Future<String> medicine() => inventory.createMedicine(
    const NewMedicine(name: 'Аспирин', initialQuantity: 100, unit: 'шт.'),
  );

  NewSchedule daily(
    String medicineId, {
    List<int> times = const [8 * 60],
    DateTime? end,
    double dose = 2,
  }) => NewSchedule(
    medicineId: medicineId,
    kind: ScheduleKind.daily,
    dose: dose,
    doseUnit: 'шт.',
    startDate: DateTime(2026, 10, 1),
    endDate: end,
    times: times,
  );

  Set<DateTime> fireTimes() => {
    for (final r in scheduler.scheduled.values) r.at,
  };

  test('a new schedule gets its reminders with name and dose', () async {
    final sid = await repo.createSchedule(
      daily(await medicine(), end: DateTime(2026, 10, 21)),
    );
    await settle();
    expect(fireTimes(), {
      DateTime(2026, 10, 19, 8),
      DateTime(2026, 10, 20, 8),
      DateTime(2026, 10, 21, 8),
    });
    final first = scheduler.scheduled.values.first;
    expect((first.title, first.body), ('Аспирин', '2 шт.'));
    expect(
      scheduler.scheduled.values.map(
        (r) => OpenIntakeRequest.fromPayload(r.payload)?.scheduleId,
      ),
      everyElement(sid),
    );
  });

  test('untimed schedules schedule nothing', () async {
    await repo.createSchedule(daily(await medicine(), times: []));
    await settle();
    expect(scheduler.scheduled, isEmpty);
  });

  test('taking cancels that reminder, undoing brings it back', () async {
    final sid = await repo.createSchedule(
      daily(await medicine(), times: [8 * 60, 20 * 60], end: today),
    );
    await settle();
    expect(scheduler.scheduled, hasLength(2));

    await repo.markTaken(scheduleId: sid, day: today, minuteOfDay: 480);
    await settle();
    expect(fireTimes(), {DateTime(2026, 10, 19, 20)});

    await repo.markSkipped(scheduleId: sid, day: today, minuteOfDay: 1200);
    await settle();
    expect(scheduler.scheduled, isEmpty);

    await repo.resetMark(scheduleId: sid, day: today, minuteOfDay: 480);
    await settle();
    expect(fireTimes(), {DateTime(2026, 10, 19, 8)});
  });

  test('repeated passes do not duplicate or reschedule', () async {
    await repo.createSchedule(daily(await medicine(), end: today));
    await settle();
    final calls = scheduler.scheduleCalls;
    expect(scheduler.scheduled, hasLength(1));
    sync.didChangeAppLifecycleState(AppLifecycleState.resumed);
    sync.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await settle();
    expect(scheduler.scheduled, hasLength(1));
    expect(scheduler.scheduleCalls, calls);
  });

  test('deleting the medicine cancels its reminders', () async {
    final id = await medicine();
    await repo.createSchedule(daily(id, end: DateTime(2026, 10, 20)));
    await settle();
    expect(scheduler.scheduled, hasLength(2));
    await (db.delete(db.medicines)..where((m) => m.id.equals(id))).go();
    await settle();
    expect(scheduler.scheduled, isEmpty);
  });

  test('a restart repairs stale and missing notifications', () async {
    final sid = await repo.createSchedule(daily(await medicine(), end: today));
    await settle();
    final id = scheduler.scheduled.keys.single;
    await sync.dispose();

    // While the app was closed: one stale leftover, the real one lost.
    scheduler.scheduled
      ..clear()
      ..[12345] = (at: now, title: 'x', body: 'x', payload: 'old');
    sync = newSync()..start();
    await settle();

    expect(scheduler.scheduled.keys, [id]);
    expect(
      OpenIntakeRequest.fromPayload(scheduler.scheduled[id]!.payload)!
          .scheduleId,
      sid,
    );
  });

  test('without permission nothing is scheduled and leftovers go', () async {
    scheduler.allowed = false;
    await repo.createSchedule(daily(await medicine(), end: today));
    await settle();
    expect(scheduler.scheduled, isEmpty);

    scheduler.allowed = true;
    sync.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await settle();
    expect(scheduler.scheduled, hasLength(1));

    scheduler.allowed = false;
    sync.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await settle();
    expect(scheduler.scheduled, isEmpty);
  });

  test('a time zone change reschedules the reminders', () async {
    await repo.createSchedule(daily(await medicine(), end: today));
    await settle();
    final before = scheduler.scheduleCalls;
    scheduler.zone = 'Asia/Tokyo';
    sync.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await settle();
    expect(scheduler.scheduled, hasLength(1));
    expect(scheduler.scheduleCalls, before + 1);
    expect(scheduler.scheduled.values.single.payload, contains('Asia/Tokyo'));
  });

  test('a changed dose replaces the notification text in place', () async {
    final id = await medicine();
    await repo.createSchedule(daily(id, end: today));
    await settle();
    await (db.update(db.schedules))
        .write(const SchedulesCompanion(dose: Value(3)));
    await settle();
    expect(scheduler.scheduled, hasLength(1));
    expect(scheduler.scheduled.values.single.body, '3 шт.');
  });

  test('at most 60 reminders are kept, the nearest ones', () async {
    await repo.createSchedule(
      daily(await medicine(), times: [8 * 60, 20 * 60]),
    );
    await settle();
    expect(scheduler.scheduled, hasLength(reminderLimit));
    final last = fireTimes().reduce((a, b) => a.isAfter(b) ? a : b);
    expect(last, DateTime(2026, 11, 17, 20));
  });

  test('editing replaces the reminders, ending cancels them', () async {
    final sid = await repo.createSchedule(
      daily(await medicine(), end: DateTime(2026, 10, 20)),
    );
    await settle();
    expect(fireTimes(), {DateTime(2026, 10, 19, 8), DateTime(2026, 10, 20, 8)});

    await repo.updateSchedule(
      sid,
      ScheduleEdit(
        kind: ScheduleKind.daily,
        dose: 2,
        times: const [9 * 60],
        endDate: DateTime(2026, 10, 20),
      ),
    );
    await settle();
    // The old version's reminders are gone, the new version's are there.
    expect(fireTimes(), {DateTime(2026, 10, 19, 9), DateTime(2026, 10, 20, 9)});

    final current = (await db.select(db.schedules).get()).firstWhere(
      (r) => r.id != sid,
    );
    await repo.endSchedule(current.id);
    await settle();
    expect(scheduler.scheduled, isEmpty);
  });

  test('renaming retitles the reminders, archiving cancels them', () async {
    final id = await medicine();
    await repo.createSchedule(daily(id, end: DateTime(2026, 10, 20)));
    await settle();
    expect(
      scheduler.scheduled.values.map((r) => r.title),
      everyElement('Аспирин'),
    );

    await inventory.updateMedicine(
      id,
      const MedicineEdit(name: 'Аспирин Кардио'),
    );
    await settle();
    expect(scheduler.scheduled, hasLength(2));
    expect(
      scheduler.scheduled.values.map((r) => r.title),
      everyElement('Аспирин Кардио'),
    );

    await inventory.archiveMedicine(id);
    await settle();
    expect(scheduler.scheduled, isEmpty);
  });
}
