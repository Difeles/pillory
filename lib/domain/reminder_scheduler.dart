class PendingReminder {
  const PendingReminder(this.id, this.payload);

  final int id;
  final String payload;
}

/// The device's local notification scheduler. Implemented in `data/`.
abstract class ReminderScheduler {
  /// Whether the user lets the app show notifications.
  Future<bool> notificationsAllowed();

  /// Asks the user (the system shows its prompt at most once on iOS, and on
  /// Android 13+ until the user declines for good). Returns the outcome.
  Future<bool> requestPermission();

  /// IANA name of the device's current time zone, which [schedule] uses.
  Future<String> timeZone();

  Future<List<PendingReminder>> pending();

  /// Schedules a notification at the wall-clock time [at] in [timeZone]. The
  /// same [id] replaces the earlier one.
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required String payload,
  });

  Future<void> cancel(int id);
}

/// Used where notifications are unavailable (tests, unsupported platforms).
class NoopReminderScheduler implements ReminderScheduler {
  const NoopReminderScheduler();

  @override
  Future<bool> notificationsAllowed() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<String> timeZone() async => 'UTC';

  @override
  Future<List<PendingReminder>> pending() async => const [];

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required String payload,
  }) async {}

  @override
  Future<void> cancel(int id) async {}
}
