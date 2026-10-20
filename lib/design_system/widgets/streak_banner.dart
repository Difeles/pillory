import 'package:flutter/material.dart';

import '../tokens.dart';

String _days(int n) {
  final m10 = n % 10, m100 = n % 100;
  if (m10 == 1 && m100 != 11) return '$n день';
  if (m10 >= 2 && m10 <= 4 && (m100 < 12 || m100 > 14)) return '$n дня';
  return '$n дней';
}

const _flame = Color(0xFFF0845C);
const _onPeach = Color(0xFF79422C);

/// The warm banner celebrating a run of fully taken days.
class StreakBanner extends StatelessWidget {
  const StreakBanner({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: DecoratedBox(
      decoration: ShapeDecoration(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        gradient: LinearGradient(
          colors: [
            context.colors.warningTint,
            context.colors.tint,
            context.colors.successTint,
          ],
        ),
        shadows: context.colors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: context.colors.surface.withValues(alpha: .7),
              child: Icon(
                Icons.local_fire_department,
                // A soft peach flame.
                color: _flame,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.ms),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Огненный страйк!', style: AppType.label),
                      DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: StadiumBorder(),
                          color: AppColors.peach,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          child: Text(
                            _days(days),
                            // Dark on the peach pill in both appearances.
                            style: AppType.captionStrong.copyWith(
                              color: _onPeach,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Дни без пропусков подряд. Так держать!',
                    style: AppType.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
