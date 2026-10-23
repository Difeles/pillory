import 'package:flutter/material.dart';

import '../../domain/inventory_rules.dart';
import '../../l10n/l10n.dart';
import '../motion.dart';
import '../tokens.dart';

/// How a day looks in a [MonthGrid]. The number is always shown, so colour
/// is never the only carrier: [label] says it to a screen reader.
class DayMark {
  const DayMark({this.fill, this.onFill, this.ring, this.dot, this.label});

  final Color? fill;
  final Color? onFill;
  final Color? ring;
  final Color? dot;
  final String? label;
}

/// One month as a grid of days, Monday first, with arrows to move between
/// months. What a day shows comes from [markOf].
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.month,
    required this.onMonthChanged,
    required this.markOf,
    this.onDayTap,
    this.selected,
  });

  /// Any day of the shown month.
  final DateTime month;
  final ValueChanged<DateTime> onMonthChanged;
  final DayMark Function(DateTime day) markOf;
  final ValueChanged<DateTime>? onDayTap;
  final DateTime? selected;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final lead = first.weekday - 1;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final today = dateOnly(DateTime.now());
    final rows = ((lead + days) / 7).ceil();
    return Column(
      children: [
        Row(
          children: [
            Pressable(
              scale: .88,
              child: IconButton(
                tooltip: context.l10n.previousMonth,
                icon: const Icon(Icons.chevron_left),
                onPressed: () =>
                    onMonthChanged(DateTime(month.year, month.month - 1)),
              ),
            ),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  context.monthYear(first),
                  textAlign: TextAlign.center,
                  style: AppType.cardTitle,
                ),
              ),
            ),
            Pressable(
              scale: .88,
              child: IconButton(
                tooltip: context.l10n.nextMonth,
                icon: const Icon(Icons.chevron_right),
                onPressed: () =>
                    onMonthChanged(DateTime(month.year, month.month + 1)),
              ),
            ),
          ],
        ),
        Row(
          children: [
            for (var i = 1; i <= 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    context.l10n.weekdayShort(i),
                    style: AppType.caption.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: _cell(context, r * 7 + c - lead + 1, days, today),
                ),
            ],
          ),
      ],
    );
  }

  Widget _cell(BuildContext context, int n, int days, DateTime today) {
    if (n < 1 || n > days) return const SizedBox(height: 44);
    final day = DateTime(month.year, month.month, n);
    final mark = markOf(day);
    final isToday = day == today;
    final isSelected = selected != null && dateOnly(selected!) == day;
    final ring = isSelected
        ? context.colors.textPrimary
        : isToday
        ? context.colors.accent
        : mark.ring;
    return Semantics(
      button: onDayTap != null,
      selected: isSelected,
      label:
          '${context.dayMonth(day)}${mark.label == null ? '' : ', ${mark.label}'}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDayTap == null ? null : () => onDayTap!(day),
        child: SizedBox(
          height: 44,
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mark.fill,
                border: ring == null
                    ? null
                    : Border.all(color: ring, width: isSelected ? 2.5 : 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '$n',
                    style: AppType.label.copyWith(
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color: mark.onFill ?? context.colors.textPrimary,
                    ),
                  ),
                  if (mark.dot != null)
                    Positioned(
                      bottom: 3,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: mark.dot,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
