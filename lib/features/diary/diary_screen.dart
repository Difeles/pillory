import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/motion.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../domain/diary.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import '../today/today_screen.dart' show formatDay, formatMinute;
import 'add_diary_screen.dart';

/// Moods from bad to great: the icon and its name (not colour alone).
const moodIcons = [
  Icons.sentiment_very_dissatisfied,
  Icons.sentiment_dissatisfied,
  Icons.sentiment_neutral,
  Icons.sentiment_satisfied,
  Icons.sentiment_very_satisfied,
];

/// The name of mood 1..5.
String moodName(AppLocalizations l, int mood) =>
    [l.moodBad, l.moodSoSo, l.moodOk, l.moodGood, l.moodGreat][mood - 1];

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(diaryProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.diaryTitle)),
      floatingActionButton: Pressable(
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const AddDiaryScreen()),
          ),
          icon: const Icon(Icons.add),
          label: Text(context.l10n.diaryEntry),
        ),
      ),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  context.l10n.diaryEmpty,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                96,
              ),
              children: [
                for (final e in entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _EntryCard(entry: e),
                  ),
              ],
            ),
    );
  }
}

class _EntryCard extends ConsumerWidget {
  const _EntryCard({required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final at = entry.at;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.mood != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.ms),
              child: Tooltip(
                message: moodName(context.l10n, entry.mood!),
                child: Icon(
                  moodIcons[entry.mood! - 1],
                  color: context.colors.primary,
                  semanticLabel: moodName(context.l10n, entry.mood!),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatDay(context, at)}, ${formatMinute(at.hour * 60 + at.minute)}',
                  style: AppType.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                if (entry.symptoms.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final k in entry.symptoms)
                          Chip(
                            label: Text(context.l10n.symptom(k)),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                if (entry.note != null) Text(entry.note!),
              ],
            ),
          ),
          Pressable(
            scale: .88,
            child: IconButton(
              tooltip: context.l10n.deleteEntry,
              icon: const Icon(Icons.delete_outline),
              onPressed: () =>
                  ref.read(diaryRepositoryProvider).delete(entry.id),
            ),
          ),
        ],
      ),
    );
  }
}
