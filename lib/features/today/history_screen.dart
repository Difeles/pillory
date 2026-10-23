import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/tokens.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import '../../domain/schedule.dart';
import 'today_providers.dart';
import 'today_screen.dart';

/// Read-only log of the last [historyDays] days, newest first, with the
/// status of every intake. Marks are corrected on the day screen.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  /// Medicine the log is narrowed to, or null for all.
  String? _medicineId;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.historyTitle)),
      body: SafeArea(
        child: history.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(context.l10n.historyLoadFailed)),
          data: (all) {
            if (all.values.every((l) => l.isEmpty)) {
              return Center(child: Text(context.l10n.historyEmpty));
            }
            // Medicines that appear in the log, by name.
            final medicines = <String, String>{
              for (final l in all.values)
                for (final i in l) i.schedule.medicineId: i.medicineName,
            };
            final byDay = {
              for (final e in all.entries)
                e.key: [
                  for (final i in e.value)
                    if (_medicineId == null ||
                        i.schedule.medicineId == _medicineId)
                      i,
                ],
            }..removeWhere((_, l) => l.isEmpty);
            final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
            final shown = [for (final l in byDay.values) ...l];
            final taken = shown.where((i) => i.taken).length;
            final today = DateTime.now();
            // An unmarked intake of an earlier day was missed; today's and
            // the future's are still ahead.
            final startOfToday = DateTime(today.year, today.month, today.day);
            final missed = [
              for (final e in byDay.entries)
                if (e.key.isBefore(startOfToday))
                  for (final i in e.value)
                    if (!i.taken && !i.skipped) i,
            ].length;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (medicines.length > 1)
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      ChoiceChip(
                        label: Text(context.l10n.all),
                        selected: _medicineId == null,
                        onSelected: (_) => setState(() => _medicineId = null),
                      ),
                      for (final m in medicines.entries)
                        ChoiceChip(
                          label: Text(m.value),
                          selected: _medicineId == m.key,
                          onSelected: (_) =>
                              setState(() => _medicineId = m.key),
                        ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    context.l10n.historySummary(historyDays, taken) +
                        (missed > 0 ? context.l10n.historyMissed(missed) : ''),
                    style: AppType.body.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                for (final d in days) ...[
                  Text(
                    formatDay(context, d),
                    style: AppType.cardTitle.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final i in byDay[d]!)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${i.minuteOfDay == null ? '' : '${formatMinute(i.minuteOfDay!)} · '}'
                              '${i.medicineName}${_details(context.l10n, i)}, '
                              '${context.l10n.quantity(i.schedule.dose, i.schedule.doseUnit)}',
                            ),
                          ),
                          intakeStatusLabel(i.status),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// " (Таблетки · 500 мг)": the form and strength the intake was marked with.
String _details(AppLocalizations l, DayIntake i) {
  final parts = [
    if (i.medicineForm != null) l.form(i.medicineForm!),
    if (i.medicineStrength != null) i.medicineStrength!,
  ];
  return parts.isEmpty ? '' : ' (${parts.join(' · ')})';
}
