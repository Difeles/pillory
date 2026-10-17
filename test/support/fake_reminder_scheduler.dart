import 'package:pillory/domain/reminder_scheduler.dart';

/// Keeps scheduled notifications in memory; survives a "restart" because the
/// test keeps the instance.
class FakeReminderScheduler implements ReminderScheduler {
  bool allowed = true;
  bool grantOnRequest = true;
  String zone = 'Europe/Moscow';
  int scheduleCalls = 0;
  int requests = 0;
  final scheduled =
      <int, ({DateTime at, String title, String body, String payload})>{};

  @override
  Future<bool> notificationsAllowed() async => allowed;

  @override
  Future<bool> requestPermission() async {
    requests++;
    return allowed = grantOnRequest;
  }

  @override
  Future<String> timeZone() async => zone;

  @override
  Future<List<PendingReminder>> pending() async => [
    for (final e in scheduled.entries) PendingReminder(e.key, e.value.payload),
  ];

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required String payload,
  }) async {
    scheduleCalls++;
    scheduled[id] = (at: at, title: title, body: body, payload: payload);
  }

  @override
  Future<void> cancel(int id) async => scheduled.remove(id);
}
