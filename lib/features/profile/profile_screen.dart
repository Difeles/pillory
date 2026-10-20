import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/backup_format.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/app_top_bar.dart';
import '../../design_system/widgets/mascot_pill.dart';
import '../../design_system/widgets/pill_widgets.dart';
import '../../design_system/widgets/section_header.dart';
import '../../design_system/widgets/status_badge.dart';
import '../../domain/achievements.dart';
import '../../domain/extras.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/schedule.dart';
import '../../domain/stock_status.dart';
import '../../domain/streak.dart';
import '../inventory/inventory_providers.dart';
import '../today/today_providers.dart';
import '../inventory/format.dart';
import 'backup_files.dart';
import '../../design_system/motion.dart';

const _dayLetters = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider).value ?? const AppPrefs();
    final streak = ref.watch(streakProvider);
    final history = ref.watch(historyProvider).value ?? const {};
    final stock = ref.watch(medicineStockProvider).value ?? const [];
    final now = DateTime.now();
    final today = dateOnly(now);
    final badges = earnedBadges(
      streak: streak,
      medicines: stock.length,
      expired: stock.where((s) => assess(s, now).hasExpired).length,
    );
    final extras = ref.read(extrasRepositoryProvider);
    final monday = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1),
    );
    return Scaffold(
      appBar: const AppTopBar(title: 'Профиль'),
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
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.tint,
                  child: MascotPill(size: 44),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prefs.name.isEmpty ? 'Ваше имя' : prefs.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppType.title,
                      ),
                      if (streak > 0)
                        StatusBadge(
                          label: '$streak дн. подряд',
                          icon: Icons.local_fire_department,
                          tone: StatusTone.warning,
                        ),
                    ],
                  ),
                ),
                Pressable(
                  scale: .88,
                  child: IconButton(
                    tooltip: 'Изменить имя',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editName(context, extras, prefs.name),
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Итоги недели'),
          AppCard(
            child: Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: _WeekDay(
                      label: _dayLetters[i],
                      day: DateTime(monday.year, monday.month, monday.day + i),
                      today: today,
                      history: history,
                    ),
                  ),
              ],
            ),
          ),
          const SectionHeader(title: 'Достижения'),
          Row(
            spacing: AppSpacing.sm,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final b in AppBadge.values)
                Expanded(
                  child: _BadgeTile(badge: b, earned: badges.contains(b)),
                ),
            ],
          ),
          const SectionHeader(title: 'Настройки'),
          SettingToggleRow(
            icon: Icons.vibration,
            title: 'Тактильный отклик',
            subtitle: 'Приятная отдача при приёме',
            value: prefs.haptics,
            onChanged: (v) => extras.setPref(PrefKey.haptics, '$v'),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingToggleRow(
            icon: Icons.celebration_outlined,
            title: 'Конфетти при приёме',
            subtitle: 'Анимация победы над рутиной',
            value: prefs.confetti,
            onChanged: (v) => extras.setPref(PrefKey.confetti, '$v'),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingToggleRow(
            icon: Icons.notifications_active_outlined,
            title: 'Подсказки о сроках',
            subtitle: 'Напоминать в аптечке, что пора докупить',
            value: prefs.hints,
            onChanged: (v) => extras.setPref(PrefKey.hints, '$v'),
          ),
          const SectionHeader(title: 'Данные'),
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              'Данные хранятся только на этом устройстве. Резервная копия — '
              'файл, который вы сохраняете сами. Он не зашифрован: храните его '
              'там, где доверяете.',
              style: AppType.caption,
            ),
          ),
          Pressable(
            scale: .98,
            child: ListTile(
              leading: const Icon(Icons.upload_file_outlined),
              title: const Text('Сохранить резервную копию'),
              onTap: () => _guard(context, () => _export(context, ref)),
            ),
          ),
          Pressable(
            scale: .98,
            child: ListTile(
              leading: const Icon(Icons.restore_outlined),
              title: const Text('Восстановить из копии'),
              onTap: () => _guard(context, () => _import(context, ref)),
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
    title: const Text('Как вас зовут?'),
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
          child: const Text('Отмена'),
        ),
      ),
      Pressable(
        child: FilledButton(
          onPressed: () => Navigator.pop(context, _c.text.trim()),
          child: const Text('Сохранить'),
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
        ? (AppColors.success, Colors.white, Icons.check)
        : missed
        ? (AppColors.warningTint, AppColors.warning, Icons.close)
        : (AppColors.surfaceLow, AppColors.textSecondary, null);
    return Semantics(
      label:
          '$label: ${complete
              ? 'без пропусков'
              : missed
              ? 'есть пропуски'
              : 'нет данных'}',
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
              fontWeight: day == today ? FontWeight.w800 : FontWeight.w500,
              color: day == today ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.earned});

  final AppBadge badge;
  final bool earned;

  @override
  Widget build(BuildContext context) => Semantics(
    label:
        '${badge.title}: ${earned ? 'получено' : 'не получено'}. ${badge.hint}',
    excludeSemantics: true,
    child: Material(
      color: earned ? AppColors.tint : AppColors.surfaceLow,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.ms),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: earned ? AppColors.peach : AppColors.surfaceMid,
              child: Icon(
                earned ? Icons.emoji_events : Icons.lock_outline,
                color: earned ? AppColors.primaryDeep : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: AppType.label,
            ),
            Text(
              badge.hint,
              textAlign: TextAlign.center,
              style: AppType.caption.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}

void _say(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

Future<void> _alert(BuildContext context, String title, String text) =>
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          Pressable(
            child: TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );

/// Turns any failure into a message; the screen never leaves it unreported.
Future<void> _guard(BuildContext context, Future<void> Function() run) async {
  try {
    await run();
  } on BackupException catch (e) {
    if (context.mounted) await _alert(context, 'Не удалось', e.message);
  } on Object {
    if (context.mounted) {
      await _alert(
        context,
        'Не удалось',
        'Что-то пошло не так. Данные не изменены.',
      );
    }
  }
}

/// Returns whether a file was written.
Future<bool> _export(BuildContext context, WidgetRef ref) async {
  final data = await ref.read(backupRepositoryProvider).read();
  final d = data.createdAt!.toLocal();
  final name =
      'pillory-${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}.pillory-backup';
  final saved = await ref
      .read(backupFilesProvider)
      .save(name, Uint8List.fromList(utf8.encode(encodeBackup(data))));
  if (saved && context.mounted) _say(context, 'Копия сохранена');
  return saved;
}

String _describe(BackupData d) {
  final archived = d.archivedMedicines;
  final last = d.lastMarkDay;
  return '${d.medicines.length} лекарств'
      '${archived > 0 ? ' (в архиве: $archived)' : ''}, '
      '${d.schedules.length} расписаний, ${d.intakeLogs.length} отметок'
      '${last == null ? '' : ', последняя ${formatDate(last)}'}';
}

Future<void> _import(BuildContext context, WidgetRef ref) async {
  final bytes = await ref.read(backupFilesProvider).pick();
  if (bytes == null) return;
  final backup = parseBackup(bytes); // nothing is touched if this throws
  final repo = ref.read(backupRepositoryProvider);
  final current = await repo.read();
  if (!context.mounted) return;

  if (!current.isEmpty) {
    while (true) {
      final choice = await showDialog<String>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Заменить данные?'),
          content: Text(
            'В копии: ${_describe(backup)}.\n\n'
            'Сейчас на устройстве: ${_describe(current)}.\n\n'
            'Все текущие данные будут заменены полностью. '
            'Это нельзя отменить.',
          ),
          actions: [
            Pressable(
              child: TextButton(
                onPressed: () => Navigator.pop(c, 'save'),
                child: const Text('Сначала сохранить текущие'),
              ),
            ),
            Pressable(
              child: TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Отмена'),
              ),
            ),
            Pressable(
              child: TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                onPressed: () => Navigator.pop(c, 'replace'),
                child: const Text('Заменить'),
              ),
            ),
          ],
        ),
      );
      if (choice == 'save') {
        if (context.mounted) await _export(context, ref);
        if (!context.mounted) return;
        continue;
      }
      if (choice != 'replace') return;
      break;
    }
  }
  if (!context.mounted) return;

  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    ),
  );
  final navigator = Navigator.of(context, rootNavigator: true);
  try {
    await repo.restore(backup);
  } finally {
    navigator.pop();
  }
  // The notifications follow the restored schedules; a failure to plan them
  // does not undo the restore.
  await ref.read(reminderSyncProvider).resync();
  if (context.mounted) _say(context, 'Данные восстановлены');
}
