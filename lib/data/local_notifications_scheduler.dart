import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder_scheduler.dart';
import '../l10n/l10n.dart';
import '../domain/reminders.dart';

/// [ReminderScheduler] on top of flutter_local_notifications.
class LocalNotificationsScheduler implements ReminderScheduler {
  LocalNotificationsScheduler._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _category = 'intake';

  // "Taken" opens the app: the database lives in the main isolate only.
  // "Later" only schedules another notification, so it works in the
  // background.
  // The buttons speak the device's language: the saved choice is in the
  // database, which the background isolate cannot open.
  static NotificationDetails _details(ReminderStyle style) {
    final l = appL10n();
    return NotificationDetails(
      android: AndroidNotificationDetails(
        // A channel's sound cannot change once created, so each mix of
        // sound and vibration has its own.
        'reminders_s${style.sound ? 1 : 0}_v${style.vibration ? 1 : 0}',
        l.channelName,
        channelDescription: l.channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: style.sound,
        enableVibration: style.vibration,
        actions: [
          AndroidNotificationAction(
            takenAction,
            l.actionTaken,
            showsUserInterface: true,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'snooze',
            l.actionSnooze,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'snooze30',
            l.actionSnooze30,
            cancelNotification: true,
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: _category,
        presentSound: style.sound,
      ),
    );
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  /// The plugin's settings, the same for every isolate that sets it up: the
  /// buttons' category must be registered whichever starts the plugin, and
  /// permissions are asked in context, never here.
  static InitializationSettings _initSettings() {
    final l = appL10n();
    return InitializationSettings(
      android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: [
          DarwinNotificationCategory(
            _category,
            actions: [
              DarwinNotificationAction.plain(
                takenAction,
                l.actionTaken,
                options: {DarwinNotificationActionOption.foreground},
              ),
              DarwinNotificationAction.plain('snooze', l.actionSnooze),
              DarwinNotificationAction.plain('snooze30', l.actionSnooze30),
            ],
          ),
        ],
      ),
    );
  }

  /// [onTap] gets the payload and the pressed button (null for a tap on the
  /// notification itself) of a notification, also the one that launched the
  /// app.
  static Future<LocalNotificationsScheduler> create({
    required void Function(String? payload, String? action) onTap,
  }) async {
    tzdata.initializeTimeZones();
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: _initSettings(),
      onDidReceiveNotificationResponse: (r) {
        if (snoozeActions.containsKey(r.actionId)) {
          _snooze(plugin, r);
        } else {
          onTap(r.payload, r.actionId == takenAction ? takenAction : null);
        }
      },
      onDidReceiveBackgroundNotificationResponse: snoozeInBackground,
    );
    // Reminders were once on a single channel; its settings are fixed, so the
    // channels per sound and vibration replaced it.
    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.deleteNotificationChannel(channelId: 'intake_reminders');
    final launch = await plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      final r = launch!.notificationResponse;
      onTap(r?.payload, r?.actionId == takenAction ? takenAction : null);
    }
    return LocalNotificationsScheduler._(plugin);
  }

  @override
  Future<bool> notificationsAllowed() async {
    final android = _android;
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    return (await _ios?.checkPermissions())?.isEnabled ?? false;
  }

  @override
  Future<bool> requestPermission() async {
    final android = _android;
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return await _ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  @override
  Future<bool> exactAllowed() async =>
      await _android?.canScheduleExactNotifications() ?? false;

  @override
  Future<void> requestExact() async => _android?.requestExactAlarmsPermission();

  @override
  Future<void> showTest() => _plugin.show(
    id: 1,
    title: 'PillPal',
    body: appL10n().testNotificationBody,
    notificationDetails: _details(const ReminderStyle()),
  );

  @override
  Future<String> timeZone() async {
    try {
      final name = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(name));
    } on Object {
      // Keep the previous zone (UTC at first) if the platform name is unknown.
    }
    return tz.local.name;
  }

  @override
  Future<List<PendingReminder>> pending() async => [
    for (final p in await _plugin.pendingNotificationRequests())
      PendingReminder(p.id, p.payload ?? ''),
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
    // Exact only if Android already allows it; the user is never asked.
    final exact = await _android?.canScheduleExactNotifications() ?? false;
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: tz.TZDateTime(
        tz.local,
        at.year,
        at.month,
        at.day,
        at.hour,
        at.minute,
      ),
      notificationDetails: _details(style),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      title: title,
      body: body,
      payload: payload,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);
}

/// A "later" button pressed while the app is not running.
@pragma('vm:entry-point')
Future<void> snoozeInBackground(NotificationResponse r) async {
  if (!snoozeActions.containsKey(r.actionId)) return;
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    settings: LocalNotificationsScheduler._initSettings(),
  );
  await _snooze(plugin, r);
}

/// Schedules the reminder again for later, as [SnoozePlan] says.
Future<void> _snooze(
  FlutterLocalNotificationsPlugin plugin,
  NotificationResponse r,
) async {
  final plan = SnoozePlan.from(
    id: r.id,
    payload: r.payload,
    actionId: r.actionId,
  );
  if (plan == null) return;
  final exact =
      await plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.canScheduleExactNotifications() ??
      false;
  await plugin.cancel(id: plan.cancelId);
  await plugin.zonedSchedule(
    id: plan.newId,
    // An instant, so the zone does not matter.
    scheduledDate: tz.TZDateTime.now(tz.UTC).add(plan.after),
    notificationDetails: LocalNotificationsScheduler._details(plan.style),
    androidScheduleMode: exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle,
    title: plan.title,
    body: plan.body,
    payload: plan.payload,
  );
}
