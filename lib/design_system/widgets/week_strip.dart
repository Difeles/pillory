import 'package:flutter/material.dart';

import '../tokens.dart';

const _short = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

/// The seven days (Mon..Sun) around [selected]; [done] days get a mint dot.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.selected,
    required this.done,
    required this.onSelected,
  });

  final DateTime selected;
  final bool Function(DateTime day) done;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final monday = DateTime(
      selected.year,
      selected.month,
      selected.day - (selected.weekday - 1),
    );
    // A horizontal swipe moves to the same weekday of the next/previous week.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v.abs() < 200) return;
        onSelected(
          DateTime(
            selected.year,
            selected.month,
            selected.day + (v < 0 ? 7 : -7),
          ),
        );
      },
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _cell(
                  DateTime(monday.year, monday.month, monday.day + i),
                  i,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(DateTime day, int i) {
    final active = day == selected;
    return Semantics(
      button: true,
      selected: active,
      child: Material(
        color: active ? AppColors.primary : AppColors.surfaceLow,
        shape: const StadiumBorder(),
        elevation: active ? 4 : 0,
        shadowColor: AppColors.primary,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => onSelected(day),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.ms),
            child: Column(
              children: [
                Text(
                  _short[i],
                  style: AppType.caption.copyWith(
                    color: active ? AppColors.tint : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${day.day}',
                  style: AppType.label.copyWith(
                    fontSize: 16,
                    color: active ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done(day)
                        ? (active ? Colors.white : AppColors.success)
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
