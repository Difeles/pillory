import 'package:flutter/material.dart';

import '../motion.dart';
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
                  context,
                  DateTime(monday.year, monday.month, monday.day + i),
                  i,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, DateTime day, int i) {
    final active = day == selected;
    return Semantics(
      button: true,
      selected: active,
      child: Pressable(
        scale: .92,
        child: GestureDetector(
          onTap: () => onSelected(day),
          child: AnimatedContainer(
            duration: motionOf(context, AppMotion.base),
            curve: AppMotion.smooth,
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: active
                  ? context.colors.primary
                  : context.colors.surfaceLow,
              shadows: active
                  ? [
                      BoxShadow(
                        color: context.colors.primary.withValues(alpha: .4),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.ms),
              child: Column(
                children: [
                  Text(
                    _short[i],
                    style: AppType.captionStrong.copyWith(
                      color: active
                          ? context.colors.onPrimary.withValues(alpha: .85)
                          : context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${day.day}',
                    style: AppType.cardTitle.copyWith(
                      color: active
                          ? context.colors.onPrimary
                          : context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done(day)
                          ? (active
                                ? context.colors.onPrimary
                                : context.colors.success)
                          : Colors.transparent,
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
