import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/tokens.dart';
import '../inventory/format.dart';
import '../../domain/schedule.dart';
import 'today_providers.dart';
import 'today_screen.dart';

/// Read-only log of the last [historyDays] days, newest first, with the
/// status of every intake. Marks are corrected on the day screen.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final history = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('История')),
      body: SafeArea(
        child: history.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              const Center(child: Text('Не удалось загрузить историю')),
          data: (byDay) {
            final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
            if (days.isEmpty) return const Center(child: Text('История пуста'));
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                for (final d in days) ...[
                  Text(
                    formatDay(d),
                    style: text.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
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
                              '${i.medicineName}${_details(i)}, '
                              '${formatQuantity(i.schedule.dose)} ${i.schedule.doseUnit}',
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
String _details(DayIntake i) {
  final parts = [
    if (i.medicineForm != null) i.medicineForm!.label,
    if (i.medicineStrength != null) i.medicineStrength!,
  ];
  return parts.isEmpty ? '' : ' (${parts.join(' · ')})';
}
