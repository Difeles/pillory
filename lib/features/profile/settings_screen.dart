import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/backup_format.dart';
import '../../design_system/motion.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/pill_widgets.dart';
import '../../design_system/widgets/section_header.dart';
import '../../domain/extras.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import '../inventory/format.dart';
import 'backup_files.dart';
import 'notifications_screen.dart';

/// Every setting of the app in one place: look, language, feedback,
/// notifications and the data copy.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider).value ?? const AppPrefs();
    final extras = ref.read(extrasRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.secSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          SettingChoiceRow<Appearance>(
            icon: Icons.contrast,
            title: context.l10n.themeTitle,
            options: {
              Appearance.system: context.l10n.themeSystem,
              Appearance.light: context.l10n.themeLight,
              Appearance.dark: context.l10n.themeDark,
            },
            selected: prefs.appearance,
            onChanged: (v) => extras.setPref(PrefKey.appearance, v.name),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingChoiceRow<String>(
            icon: Icons.language,
            title: context.l10n.languageTitle,
            options: {
              'system': context.l10n.langSystem,
              'ru': 'Русский',
              'en': 'English',
            },
            selected: prefs.language,
            onChanged: (v) => extras.setPref(PrefKey.language, v),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingToggleRow(
            icon: Icons.vibration,
            title: context.l10n.hapticsTitle,
            subtitle: context.l10n.hapticsSub,
            value: prefs.haptics,
            onChanged: (v) => extras.setPref(PrefKey.haptics, '$v'),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingToggleRow(
            icon: Icons.celebration_outlined,
            title: context.l10n.confettiTitle,
            subtitle: context.l10n.confettiSub,
            value: prefs.confetti,
            onChanged: (v) => extras.setPref(PrefKey.confetti, '$v'),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingToggleRow(
            icon: Icons.notifications_active_outlined,
            title: context.l10n.hintsTitle,
            subtitle: context.l10n.hintsSub,
            value: prefs.hints,
            onChanged: (v) => extras.setPref(PrefKey.hints, '$v'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Pressable(
            scale: .98,
            child: ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: Text(context.l10n.notificationsTitle),
              subtitle: Text(context.l10n.notificationsSub),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NotificationsScreen(),
                ),
              ),
            ),
          ),
          SectionHeader(title: context.l10n.secData),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(context.l10n.dataNote, style: AppType.caption),
          ),
          Pressable(
            scale: .98,
            child: ListTile(
              leading: const Icon(Icons.upload_file_outlined),
              title: Text(context.l10n.saveBackup),
              onTap: () => _guard(context, () => _export(context, ref)),
            ),
          ),
          Pressable(
            scale: .98,
            child: ListTile(
              leading: const Icon(Icons.restore_outlined),
              title: Text(context.l10n.restoreBackup),
              onTap: () => _guard(context, () => _import(context, ref)),
            ),
          ),
        ],
      ),
    );
  }
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
              child: Text(context.l10n.ok),
            ),
          ),
        ],
      ),
    );

/// Turns any failure into a message; the screen never leaves it unreported.
Future<void> _guard(BuildContext context, Future<void> Function() run) async {
  final l = context.l10n;
  try {
    await run();
  } on BackupException catch (e) {
    // Russian keeps the file's own, more detailed message.
    final text = l.localeName == 'ru' ? e.message : l.backupProblem(e.problem);
    if (context.mounted) await _alert(context, l.backupFailedTitle, text);
  } on Object {
    if (context.mounted) {
      await _alert(context, l.backupFailedTitle, l.somethingWrong);
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
  if (saved && context.mounted) _say(context, context.l10n.backupSaved);
  return saved;
}

String _describe(AppLocalizations l, BackupData d) {
  final archived = d.archivedMedicines;
  final last = d.lastMarkDay;
  return l.backupDescribe(
    d.medicines.length,
    archived > 0 ? l.backupArchivedPart(archived) : '',
    d.schedules.length,
    d.intakeLogs.length,
    last == null ? '' : l.backupLastPart(formatDate(last)),
  );
}

Future<void> _import(BuildContext context, WidgetRef ref) async {
  final l = context.l10n;
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
          title: Text(l.replaceTitle),
          content: Text(
            l.replaceText(_describe(l, backup), _describe(l, current)),
          ),
          actions: [
            Pressable(
              child: TextButton(
                onPressed: () => Navigator.pop(c, 'save'),
                child: Text(l.saveCurrentFirst),
              ),
            ),
            Pressable(
              child: TextButton(
                onPressed: () => Navigator.pop(c),
                child: Text(context.l10n.cancel),
              ),
            ),
            Pressable(
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.danger,
                ),
                onPressed: () => Navigator.pop(c, 'replace'),
                child: Text(l.replace),
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
  if (context.mounted) _say(context, context.l10n.dataRestored);
}
