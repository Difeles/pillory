import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/motion.dart';
import '../../design_system/pickers.dart';
import '../../design_system/widgets/pill_widgets.dart';
import '../../domain/extras.dart';
import '../../l10n/l10n.dart';

import '../today/today_screen.dart' show formatMinute;
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/status_badge.dart';

/// Whether reminders can reach the user, and what to do when they cannot.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with WidgetsBindingObserver {
  bool? _allowed;
  bool _exact = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // The user comes back from the system settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final scheduler = ref.read(reminderSchedulerProvider);
    final allowed = await scheduler.notificationsAllowed();
    final exact = !Platform.isAndroid || await scheduler.exactAllowed();
    if (!mounted) return;
    setState(() {
      _allowed = allowed;
      _exact = exact;
    });
    // Reminders are planned only while they are allowed.
    await ref.read(reminderSyncProvider).resync();
  }

  Future<void> _allow() async {
    await ref.read(reminderSchedulerProvider).requestPermission();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final scheduler = ref.read(reminderSchedulerProvider);
    final allowed = _allowed;
    final prefs = ref.watch(prefsProvider).value ?? const AppPrefs();
    final extras = ref.read(extrasRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.notificationsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (allowed != null)
                  StatusBadge(
                    label: allowed
                        ? context.l10n.notificationsOn
                        : context.l10n.notificationsOff,
                    icon: allowed
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    tone: allowed ? StatusTone.neutral : StatusTone.warning,
                  ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  allowed == false
                      ? context.l10n.notifDeniedText
                      : context.l10n.notifOnText,
                  style: AppType.body.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (allowed == false)
            Pressable(
              scale: .98,
              child: ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(context.l10n.allowNotifications),
                onTap: _allow,
              ),
            ),
          if (!_exact)
            Pressable(
              scale: .98,
              child: ListTile(
                leading: const Icon(Icons.alarm),
                title: Text(context.l10n.exactAlarms),
                subtitle: Text(context.l10n.exactAlarmsSub),
                onTap: () async {
                  await scheduler.requestExact();
                  await _refresh();
                },
              ),
            ),
          Pressable(
            scale: .98,
            child: ListTile(
              leading: const Icon(Icons.send_outlined),
              title: Text(context.l10n.testNotification),
              onTap: allowed == false ? _allow : scheduler.showTest,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SettingToggleRow(
            icon: Icons.volume_up_outlined,
            title: context.l10n.soundTitle,
            subtitle: context.l10n.soundSub,
            value: prefs.sound,
            onChanged: (v) => extras.setPref(PrefKey.sound, '$v'),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingToggleRow(
            icon: Icons.vibration,
            title: context.l10n.vibrationTitle,
            subtitle: Platform.isIOS
                ? context.l10n.vibrationIos
                : context.l10n.vibrationSub,
            value: prefs.vibration,
            onChanged: (v) => extras.setPref(PrefKey.vibration, '$v'),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingToggleRow(
            icon: Icons.bedtime_outlined,
            title: context.l10n.quietTitle,
            subtitle: context.l10n.quietSub,
            value: prefs.quiet,
            onChanged: (v) => extras.setPref(PrefKey.quiet, '$v'),
          ),
          if (prefs.quiet) ...[
            _TimeRow(
              label: context.l10n.quietFromLabel,
              pickerTitle: context.l10n.quietFromTitle,
              minutes: prefs.quietFrom,
              onPick: (m) => extras.setPref(PrefKey.quietFrom, '$m'),
            ),
            _TimeRow(
              label: context.l10n.quietToLabel,
              pickerTitle: context.l10n.quietToTitle,
              minutes: prefs.quietTo,
              onPick: (m) => extras.setPref(PrefKey.quietTo, '$m'),
            ),
          ],
          if (Platform.isAndroid)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(context.l10n.batteryNote, style: AppType.caption),
            ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.pickerTitle,
    required this.minutes,
    required this.onPick,
  });

  final String label;
  final String pickerTitle;
  final int minutes;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) => Pressable(
    scale: .98,
    child: ListTile(
      title: Text(label),
      trailing: Text(formatMinute(minutes), style: AppType.numeric),
      onTap: () async {
        final t = await pickTime(
          context,
          initial: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
          title: pickerTitle,
        );
        if (t != null) onPick(t.hour * 60 + t.minute);
      },
    ),
  );
}
