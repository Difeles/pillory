import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../domain/reminder_scheduler.dart';
import '../domain/reminders.dart';
import '../domain/schedule.dart';
import '../features/inventory/format.dart';
import '../domain/inventory_rules.dart';

/// Keeps the scheduled notifications equal to what the schedules call for.
///
/// It compares instead of reacting to individual changes: every change of a
/// schedule or a mark, every return to the app and every start re-plans, so a
/// restart, a missed event or a new time zone is repaired by the next pass.
class ReminderSync with WidgetsBindingObserver {
  ReminderSync(this._repo, this._scheduler, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final ScheduleRepository _repo;
  final ReminderScheduler _scheduler;
  final DateTime Function() _now;

  StreamSubscription<ReminderSource>? _sub;
  ReminderSource? _latest;
  Future<void>? _worker;
  bool _dirty = false;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _listen();
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _sub?.cancel();
    await idle;
  }

  /// Completes when no pass is running.
  Future<void> get idle async {
    while (_worker != null) {
      await _worker;
    }
  }

  /// Plans once from the data as it is now and completes when that pass is
  /// done; for after a bulk change such as a restore.
  Future<void> resync() async {
    _latest = await _repo.watchReminderSource(dateOnly(_now())).first;
    _dirty = true;
    _worker ??= _drain();
    await idle;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The planning window moves with the clock and the zone may have changed.
    if (state == AppLifecycleState.resumed) _listen();
  }

  void _listen() {
    _sub?.cancel();
    _sub = _repo.watchReminderSource(dateOnly(_now())).listen((source) {
      _latest = source;
      _dirty = true;
      _worker ??= _drain();
    });
  }

  /// Passes never overlap; changes that arrive meanwhile cause one more pass.
  Future<void> _drain() async {
    try {
      while (_dirty) {
        _dirty = false;
        await _reconcile(_latest!);
      }
    } on Object catch (e, st) {
      debugPrint('Reminder sync failed: $e\n$st');
    } finally {
      _worker = null;
    }
  }

  Future<void> _reconcile(ReminderSource source) async {
    final zone = await _scheduler.timeZone();
    final pending = await _scheduler.pending();
    final want = <int, (PlannedReminder, String)>{};
    if (await _scheduler.notificationsAllowed()) {
      for (final r in planReminders(source, _now())) {
        want[r.id] = (r, _payload(r, zone));
      }
    }
    final have = {for (final p in pending) p.id: p.payload};
    for (final id in have.keys) {
      if (!want.containsKey(id)) await _scheduler.cancel(id);
    }
    for (final e in want.entries) {
      if (have[e.key] == e.value.$2) continue;
      final r = e.value.$1;
      await _scheduler.schedule(
        id: e.key,
        at: r.fireAt,
        title: r.medicineName,
        body: '${formatQuantity(r.dose)} ${r.doseUnit}',
        payload: e.value.$2,
      );
    }
  }

  /// Everything a notification shows or fires on, so any change (dose, name,
  /// time, zone) makes it differ from the scheduled one and replaces it.
  String _payload(PlannedReminder r, String zone) => jsonEncode({
    ...r.request.toJson(),
    'at': r.fireAt.toIso8601String(),
    'tz': zone,
    'n': r.medicineName,
    'q': r.dose,
    'u': r.doseUnit,
  });
}
