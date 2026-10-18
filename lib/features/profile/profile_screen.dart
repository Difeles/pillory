import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/backup_format.dart';
import '../../design_system/tokens.dart';
import '../inventory/format.dart';
import 'backup_files.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Профиль')),
    body: ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Данные хранятся только на этом устройстве. Резервная копия — '
            'файл, который вы сохраняете сами. Он не зашифрован: храните его '
            'там, где доверяете.',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.upload_file_outlined),
          title: const Text('Сохранить резервную копию'),
          onTap: () => _guard(context, () => _export(context, ref)),
        ),
        ListTile(
          leading: const Icon(Icons.restore_outlined),
          title: const Text('Восстановить из копии'),
          onTap: () => _guard(context, () => _import(context, ref)),
        ),
      ],
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
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('OK'),
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
            TextButton(
              onPressed: () => Navigator.pop(c, 'save'),
              child: const Text('Сначала сохранить текущие'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Отмена'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(c, 'replace'),
              child: const Text('Заменить'),
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
