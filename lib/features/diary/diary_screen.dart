import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/motion.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/month_grid.dart';
import '../../design_system/widgets/status_badge.dart';
import '../../domain/inventory_rules.dart';
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

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  /// The day the list is limited to, or null for all entries.
  DateTime? _day;

  DayMark _mark(
    BuildContext context,
    DateTime day,
    Map<DateTime, List<DiaryEntry>> byDay,
  ) {
    final entries = byDay[day];
    if (entries == null) return const DayMark();
    final c = context.colors;
    final level = entries
        .map((e) => e.migraine ?? 0)
        .reduce((a, b) => a > b ? a : b);
    final l = context.l10n;
    if (level == 0) return DayMark(dot: c.accent);
    return DayMark(
      fill: switch (level) {
        1 => c.dangerTint,
        2 => c.danger.withValues(alpha: .6),
        _ => c.danger,
      },
      onFill: level == 3 ? c.onDanger : null,
      label: l.migraineLevel(l.migraine(level)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final entries = ref.watch(diaryProvider).value ?? const [];
    final byDay = <DateTime, List<DiaryEntry>>{};
    for (final e in entries) {
      (byDay[dateOnly(e.at)] ??= []).add(e);
    }
    final shown = _day == null ? entries : byDay[_day] ?? const <DiaryEntry>[];
    final migraineDays = byDay.entries
        .where(
          (e) =>
              e.key.year == _month.year &&
              e.key.month == _month.month &&
              e.value.any((x) => x.migraine != null),
        )
        .length;
    return Scaffold(
      appBar: AppBar(title: Text(l.diaryTitle)),
      floatingActionButton: Pressable(
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => AddDiaryScreen(day: _day)),
          ),
          icon: const Icon(Icons.add),
          label: Text(l.diaryEntry),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          96,
        ),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MonthGrid(
                  month: _month,
                  selected: _day,
                  onMonthChanged: (m) => setState(() => _month = m),
                  markOf: (d) => _mark(context, d, byDay),
                  onDayTap: (d) => setState(() => _day = _day == d ? null : d),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l.migraineDays(migraineDays), style: AppType.caption),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_day != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.entriesOfDay(context.dayMonth(_day!)),
                      style: AppType.cardTitle,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _day = null),
                    child: Text(l.showAllEntries),
                  ),
                ],
              ),
            ),
          if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                _day == null ? l.diaryEmpty : l.noEntriesThatDay,
                textAlign: TextAlign.center,
              ),
            ),
          for (final e in shown)
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
                if (entry.migraine != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: StatusBadge(
                      label: context.l10n.migraineLevel(
                        context.l10n.migraine(entry.migraine!),
                      ),
                      icon: Icons.bolt,
                      tone: StatusTone.danger,
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
