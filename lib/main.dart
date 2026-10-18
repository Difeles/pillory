import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'data/local_notifications_scheduler.dart';
import 'domain/reminder_scheduler.dart';
import 'domain/reminders.dart';
import 'features/today/today_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  late final ProviderContainer container;
  ReminderScheduler scheduler;
  try {
    scheduler = await LocalNotificationsScheduler.create(
      onTap: (payload) {
        final request = OpenIntakeRequest.fromPayload(payload);
        if (request != null) {
          container.read(openIntakeProvider.notifier).open(request);
        }
      },
    );
  } on Object catch (e) {
    debugPrint('Notifications unavailable: $e');
    scheduler = const NoopReminderScheduler();
  }
  container = ProviderContainer(
    overrides: [reminderSchedulerProvider.overrideWithValue(scheduler)],
  );
  container.read(reminderSyncProvider).start();
  runApp(
    UncontrolledProviderScope(container: container, child: const PilloryApp()),
  );
}
