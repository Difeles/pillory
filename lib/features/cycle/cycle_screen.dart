import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/motion.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/month_grid.dart';
import '../../design_system/widgets/section_header.dart';
import '../../domain/cycle.dart';
import '../../domain/inventory_rules.dart';
import '../../l10n/l10n.dart';

/// The period calendar: tap days to log them; the cycle and the next periods
/// are worked out from the log.
class CycleScreen extends ConsumerStatefulWidget {
  const CycleScreen({super.key});

  @override
  ConsumerState<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends ConsumerState<CycleScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  DayMark _mark(BuildContext context, CycleForecast f, DateTime day) {
    final l = context.l10n;
    final c = context.colors;
    return switch (f.kindOf(day)) {
      CycleDay.period => DayMark(
        fill: c.danger,
        onFill: c.onDanger,
        label: l.cyclePeriod,
      ),
      CycleDay.predictedPeriod => DayMark(
        fill: c.dangerTint,
        ring: c.danger,
        label: l.cyclePredicted,
      ),
      CycleDay.ovulation => DayMark(
        fill: c.success,
        onFill: c.onSuccess,
        label: l.cycleOvulation,
      ),
      CycleDay.fertile => DayMark(fill: c.successTint, label: l.cycleFertile),
      null => const DayMark(),
    };
  }

  Future<void> _toggle(Set<DateTime> days, DateTime day) async {
    final d = dateOnly(day);
    // Only the past and today are logged; the future is predicted.
    if (d.isAfter(dateOnly(DateTime.now()))) return;
    await ref.read(cycleRepositoryProvider).setDay(d, on: !days.contains(d));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final days = ref.watch(periodDaysProvider).value ?? const <DateTime>{};
    final forecast = CycleForecast.from(days);
    final today = dateOnly(DateTime.now());
    final marked = days.contains(today);
    return Scaffold(
      appBar: AppBar(title: Text(l.cycleTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          AppCard(
            child: _Summary(forecast: forecast, today: today),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                MonthGrid(
                  month: _month,
                  onMonthChanged: (m) => setState(() => _month = m),
                  markOf: (d) => _mark(context, forecast, d),
                  onDayTap: (d) => _toggle(days, d),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _Legend(color: context.colors.danger, text: l.cyclePeriod),
                    _Legend(
                      color: context.colors.dangerTint,
                      ring: context.colors.danger,
                      text: l.cyclePredicted,
                    ),
                    _Legend(
                      color: context.colors.successTint,
                      text: l.cycleFertile,
                    ),
                    _Legend(
                      color: context.colors.success,
                      text: l.cycleOvulation,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Pressable(
            child: marked
                ? OutlinedButton.icon(
                    onPressed: () => _toggle(days, today),
                    icon: const Icon(Icons.undo),
                    label: Text(l.cycleUnmarkToday),
                  )
                : FilledButton.icon(
                    onPressed: () => _toggle(days, today),
                    icon: const Icon(Icons.water_drop_outlined),
                    label: Text(l.cycleMarkToday),
                  ),
          ),
          SectionHeader(title: l.cycleYours),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.cycleAverage(forecast.cycleLength),
                  style: AppType.cardTitle,
                ),
                Text(
                  l.cycleAveragePeriod(forecast.periodLength),
                  style: AppType.cardTitle,
                ),
                if (forecast.measured == 0)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(l.cycleDefaults, style: AppType.caption),
                  ),
                if (forecast.cycleLengths.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(l.cycleHistory, style: AppType.label),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final n in forecast.cycleLengths.take(6))
                        Chip(
                          label: Text(l.cycleLengthDays(n)),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l.cycleDisclaimer, style: AppType.caption),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.forecast, required this.today});

  final CycleForecast forecast;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final day = forecast.cycleDay(today);
    final next = forecast.nextStart;
    final until = forecast.daysUntilNext(today);
    if (day == null || next == null || until == null) {
      return Text(l.cycleEmpty);
    }
    final nextText = until > 0
        ? l.cycleNextIn(context.dayMonth(next), until)
        : until == 0
        ? l.cycleNextToday
        : l.cycleLate(context.dayMonth(next), -until);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.cycleDayN(day), style: AppType.title),
        const SizedBox(height: AppSpacing.xs),
        Text(nextText, style: AppType.body),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text, this.ring});

  final Color color;
  final Color? ring;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: ring == null ? null : Border.all(color: ring!, width: 1.5),
        ),
      ),
      const SizedBox(width: AppSpacing.xs),
      Text(text, style: AppType.caption),
    ],
  );
}
