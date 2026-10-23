import 'dart:async';

import 'settings_screen.dart';
import 'achievements_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/app_top_bar.dart';
import '../../design_system/widgets/mascot_pill.dart';
import '../../design_system/widgets/section_header.dart';
import '../../design_system/widgets/status_badge.dart';
import '../../domain/achievements.dart';
import '../../domain/extras.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/schedule.dart';
import '../../domain/streak.dart';
import '../today/today_providers.dart';
import '../../l10n/l10n.dart';
import '../account/account_screen.dart';
import '../cycle/cycle_screen.dart';
import '../diary/diary_screen.dart';
import 'report_screen.dart';
import '../../design_system/motion.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider).value ?? const AppPrefs();
    final streak = ref.watch(streakProvider);
    final history = ref.watch(historyProvider).value ?? const {};
    final badges = ref.watch(earnedBadgesProvider);
    final now = DateTime.now();
    final extras = ref.read(extrasRepositoryProvider);
    final today = dateOnly(now);
    final monday = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1),
    );
    return Scaffold(
      appBar: AppTopBar(title: context.l10n.titleProfile),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl + AppSpacing.xl,
        ),
        children: [
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: context.colors.tint,
                  child: MascotPill(size: 44),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prefs.name.isEmpty ? context.l10n.yourName : prefs.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppType.title,
                      ),
                      if (streak > 0)
                        StatusBadge(
                          label: context.l10n.streakDaysInRow(streak),
                          icon: Icons.local_fire_department,
                          tone: StatusTone.warning,
                        ),
                    ],
                  ),
                ),
                Pressable(
                  scale: .88,
                  child: IconButton(
                    tooltip: context.l10n.accountTitle,
                    icon: const Icon(Icons.cloud_outlined),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AccountScreen(),
                      ),
                    ),
                  ),
                ),
                Pressable(
                  scale: .88,
                  child: IconButton(
                    tooltip: context.l10n.editName,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editName(context, extras, prefs.name),
                  ),
                ),
              ],
            ),
          ),
          SectionHeader(title: context.l10n.secWeek),
          AppCard(
            child: Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: _WeekDay(
                      label: context.l10n.weekdayShort(i + 1),
                      day: DateTime(monday.year, monday.month, monday.day + i),
                      today: today,
                      history: history,
                    ),
                  ),
              ],
            ),
          ),
          SectionHeader(title: context.l10n.secHealth),
          Pressable(
            scale: .98,
            child: ListTile(
              leading: const Icon(Icons.monitor_heart_outlined),
              title: Text(context.l10n.diaryTitle),
              subtitle: Text(context.l10n.diarySubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const DiaryScreen()),
              ),
            ),
          ),
          Pressable(
            scale: .98,
            child: ListTile(
              leading: const Icon(Icons.water_drop_outlined),
              title: Text(context.l10n.cycleTitle),
              subtitle: Text(context.l10n.cycleSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CycleScreen()),
              ),
            ),
          ),
          Pressable(
            scale: .98,
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(context.l10n.reportTitle),
              subtitle: Text(context.l10n.reportSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ReportScreen()),
              ),
            ),
          ),
          Pressable(
            scale: .98,
            child: ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: Text(context.l10n.achievementsTitle),
              subtitle: Text(
                context.l10n.badgesCount(badges.length, AppBadge.values.length),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AchievementsScreen(),
                ),
              ),
            ),
          ),
          Pressable(
            scale: .98,
            child: ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(context.l10n.secSettings),
              subtitle: Text(context.l10n.settingsSub),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _editName(
  BuildContext context,
  ExtrasRepository extras,
  String current,
) async {
  final name = await showDialog<String>(
    context: context,
    builder: (_) => _NameDialog(current: current),
  );
  if (name != null) await extras.setPref(PrefKey.name, name);
}

/// Owns its controller, so it is disposed with the dialog and not while the
/// dialog's closing animation still shows the field.
class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.current});

  final String current;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _c = TextEditingController(text: widget.current);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.whatsYourName),
    content: TextField(
      controller: _c,
      autofocus: true,
      maxLength: 40,
      textCapitalization: TextCapitalization.words,
    ),
    actions: [
      Pressable(
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
      ),
      Pressable(
        child: FilledButton(
          onPressed: () => Navigator.pop(context, _c.text.trim()),
          child: Text(context.l10n.save),
        ),
      ),
    ],
  );
}

class _WeekDay extends StatelessWidget {
  const _WeekDay({
    required this.label,
    required this.day,
    required this.today,
    required this.history,
  });

  final String label;
  final DateTime day;
  final DateTime today;
  final Map<DateTime, List<DayIntake>> history;

  @override
  Widget build(BuildContext context) {
    final intakes = history[day];
    final future = day.isAfter(today);
    final complete = dayComplete(intakes);
    final missed =
        !future &&
        !complete &&
        intakes != null &&
        intakes.isNotEmpty &&
        day != today;
    final (bg, fg, icon) = complete
        ? (context.colors.success, context.colors.onSuccess, Icons.check)
        : missed
        ? (context.colors.warningTint, context.colors.warning, Icons.close)
        : (context.colors.surfaceLow, context.colors.textSecondary, null);
    return Semantics(
      label:
          '$label: ${complete
              ? context.l10n.weekdayDone
              : missed
              ? context.l10n.weekdayMissed
              : context.l10n.weekdayNoData}',
      excludeSemantics: true,
      child: Column(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: bg,
            child: icon == null ? null : Icon(icon, size: 16, color: fg),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppType.caption.copyWith(
              fontWeight: day == today ? FontWeight.w700 : FontWeight.w500,
              color: day == today
                  ? context.colors.primary
                  : context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
