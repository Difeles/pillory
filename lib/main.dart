import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'cloud/cloud_service.dart';
import 'cloud/firebase_cloud_service.dart';
import 'data/local_notifications_scheduler.dart';
import 'domain/reminder_scheduler.dart';
import 'domain/reminders.dart';
import 'features/today/today_providers.dart';
import 'firebase_options.dart';

/// Firebase when the project is configured (`flutterfire configure`), else no
/// cloud: the app works fully offline either way.
Future<CloudService> _initCloud() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return FirebaseCloudService();
  } on Object catch (e) {
    debugPrint('Cloud unavailable: $e');
    return const NoCloudService();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ProviderContainer? container;
  // A notification that launched the app arrives before the container exists.
  final early = <(String?, String?)>[];
  void handle(String? payload, String? action) {
    final c = container;
    if (c == null) return early.add((payload, action));
    final request = OpenIntakeRequest.fromPayload(payload);
    if (request == null) return;
    if (action == 'taken') {
      c
          .read(scheduleRepositoryProvider)
          .markTaken(
            scheduleId: request.scheduleId,
            day: request.day,
            minuteOfDay: request.minuteOfDay,
          )
          .catchError((Object e) => debugPrint('Mark from reminder: $e'));
    }
    c.read(openIntakeProvider.notifier).open(request);
  }

  ReminderScheduler scheduler;
  try {
    scheduler = await LocalNotificationsScheduler.create(onTap: handle);
  } on Object catch (e) {
    debugPrint('Notifications unavailable: $e');
    scheduler = const NoopReminderScheduler();
  }
  final cloud = await _initCloud();
  final c = container = ProviderContainer(
    overrides: [
      reminderSchedulerProvider.overrideWithValue(scheduler),
      cloudServiceProvider.overrideWithValue(cloud),
    ],
  );
  c.read(reminderSyncProvider).start();
  if (cloud.available) c.read(cloudSyncProvider).start();
  for (final (payload, action) in early) {
    handle(payload, action);
  }
  runApp(UncontrolledProviderScope(container: c, child: const PilloryApp()));
}
