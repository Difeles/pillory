import 'package:pillory/domain/reminder_scheduler.dart';

/// Keeps scheduled notifications in memory; survives a "restart" because the
/// test keeps the instance.
class FakeReminderScheduler implements ReminderScheduler {
  bool allowed = true;
  bool grantOnRequest = true;
  String zone = 'Europe/Moscow';
  int scheduleCalls = 0;
  int requests = 0;

  /// The reminders themselves; the "didn't you forget" repeats are in
  /// [followUps].
  final scheduled =
      <int, ({DateTime at, String title, String body, String payload})>{};
  final styles = <int, ReminderStyle>{};
  final followUps =
      <int, ({DateTime at, String title, String body, String payload})>{};

  @override
  Future<bool> notificationsAllowed() async => allowed;

  @override
  Future<bool> requestPermission() async {
    requests++;
    return allowed = grantOnRequest;
  }

  @override
  Future<bool> exactAllowed() async => false;

  @override
  Future<void> requestExact() async {}

  @override
  Future<void> showTest() async {}

  @override
  Future<String> timeZone() async => zone;

  @override
  Future<List<PendingReminder>> pending() async => [
    for (final e in [...scheduled.entries, ...followUps.entries])
      PendingReminder(e.key, e.value.payload),
  ];

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required String payload,
    ReminderStyle style = const ReminderStyle(),
  }) async {
    scheduleCalls++;
    styles[id] = style;
    (title.startsWith('Не забыли?') ? followUps : scheduled)[id] = (
      at: at,
      title: title,
      body: body,
      payload: payload,
    );
  }

  @override
  Future<void> cancel(int id) async {
    scheduled.remove(id);
    followUps.remove(id);
  }
}
