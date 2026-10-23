import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../domain/extras.dart';
import '../domain/reminder_scheduler.dart';
import '../domain/reminders.dart';
import '../l10n/l10n.dart';
import '../l10n/labels.dart';
import '../domain/schedule.dart';
import '../domain/inventory_rules.dart';

/// How long after a reminder the second one comes if the intake is still open.
const followUpDelay = Duration(minutes: 15);

/// Keeps the scheduled notifications equal to what the schedules call for.
///
/// It compares instead of reacting to individual changes: every change of a
/// schedule or a mark, every return to the app and every start re-plans, so a
/// restart, a missed event or a new time zone is repaired by the next pass.
class ReminderSync with WidgetsBindingObserver {
  ReminderSync(
    this._repo,
    this._scheduler, {
    DateTime Function()? now,
    Future<AppPrefs> Function()? prefs,
  }) : _now = now ?? DateTime.now,
       _prefs = prefs ?? (() async => const AppPrefs());

  final ScheduleRepository _repo;
  final ReminderScheduler _scheduler;
  final DateTime Function() _now;
  final Future<AppPrefs> Function() _prefs;

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
    final prefs = await _prefs();
    final l = appL10n(prefs.language);
    final want = <int, _Want>{};
    if (await _scheduler.notificationsAllowed()) {
      // Every intake gets a second reminder, so half as many fit the limit.
      // Planned from a quarter of an hour back: an intake whose first
      // reminder has fired still has its follow-up coming.
      final now = _now();
      for (final r in planReminders(
        source,
        now.subtract(followUpDelay),
        limit: reminderLimit ~/ 2,
      )) {
        final body = l.quantity(r.dose, r.doseUnit);
        final followUp = r.fireAt.add(followUpDelay);
        if (r.fireAt.isAfter(now)) {
          _add(want, r.id, r, r.fireAt, r.medicineName, body, zone, prefs, l);
        }
        if (followUp.isAfter(now)) {
          _add(
            want,
            r.id ^ followUpBit,
            r,
            followUp,
            l.followUpTitle(r.medicineName),
            body,
            zone,
            prefs,
            l,
          );
        }
      }
    }
    final have = {for (final p in pending) p.id: p.payload};
    for (final e in have.entries) {
      if (!want.containsKey(e.key) && !_liveSnooze(e.value, source)) {
        await _scheduler.cancel(e.key);
      }
    }
    for (final e in want.entries) {
      if (have[e.key] == e.value.payload) continue;
      await _scheduler.schedule(
        id: e.key,
        at: e.value.at,
        title: e.value.title,
        body: e.value.body,
        payload: e.value.payload,
        style: e.value.style,
      );
    }
  }

  void _add(
    Map<int, _Want> want,
    int id,
    PlannedReminder r,
    DateTime at,
    String title,
    String body,
    String zone,
    AppPrefs prefs,
    AppLocalizations l,
  ) {
    final quiet = prefs.isQuiet(at.hour * 60 + at.minute);
    final style = ReminderStyle(
      sound: prefs.sound && !quiet,
      vibration: prefs.vibration && !quiet,
    );
    want[id] = _Want(
      title,
      body,
      at,
      _payload(r, zone, style, title, body, l.localeName),
      style,
    );
  }

  /// A reminder the user postponed from its button: it lives until it fires,
  /// unless its intake has since been marked or its schedule is gone.
  bool _liveSnooze(String payload, ReminderSource source) {
    try {
      if ((jsonDecode(payload) as Map)['z'] != 1) return false;
      final request = OpenIntakeRequest.fromPayload(payload);
      return request != null &&
          source.schedules.any((s) => s.schedule.id == request.scheduleId) &&
          !source.settled.contains(
            intakeKey(request.scheduleId, request.day, request.minuteOfDay),
          );
    } on Object {
      return false;
    }
  }

  /// Everything a notification shows or fires on, so any change (dose, name,
  /// time, zone, sound) makes it differ from the scheduled one and replaces it.
  String _payload(
    PlannedReminder r,
    String zone,
    ReminderStyle style,
    String title,
    String body,
    String language,
  ) => jsonEncode({
    ...r.request.toJson(),
    'at': r.fireAt.toIso8601String(),
    'tz': zone,
    'n': r.medicineName,
    'q': r.dose,
    'u': r.doseUnit,
    // What the notification says, so it can be postponed without the
    // database and is replaced when the language changes.
    't': title,
    'b': body,
    'lc': language,
    'ss': style.sound,
    'sv': style.vibration,
    // Bumped when what a notification carries (its buttons) changes, so the
    // ones already scheduled are replaced.
    'ui': 2,
  });
}

class _Want {
  const _Want(this.title, this.body, this.at, this.payload, this.style);

  final String title;
  final String body;
  final DateTime at;
  final String payload;
  final ReminderStyle style;
}
