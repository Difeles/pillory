import 'package:flutter/material.dart';

import '../tokens.dart';

String _days(int n) {
  final m10 = n % 10, m100 = n % 100;
  if (m10 == 1 && m100 != 11) return '$n день';
  if (m10 >= 2 && m10 <= 4 && (m100 < 12 || m100 > 14)) return '$n дня';
  return '$n дней';
}

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
        gradient: const LinearGradient(
          colors: [Color(0xFFFFDBCE), AppColors.tint, Color(0xFFBFF3E1)],
        ),
        shadows: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white70,
              child: Icon(
                Icons.local_fire_department,
                color: AppColors.warning,
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
                        decoration: const ShapeDecoration(
                          shape: StadiumBorder(),
                          color: AppColors.warning,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          child: Text(
                            _days(days),
                            style: AppType.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
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
