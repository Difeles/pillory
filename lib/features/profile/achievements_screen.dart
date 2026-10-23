import 'package:flutter/material.dart';

import '../../l10n/labels.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../domain/achievements.dart';
import '../../domain/stock_status.dart';
import '../../l10n/l10n.dart';
import '../inventory/inventory_providers.dart';
import '../today/today_providers.dart';

/// The badges earned so far.
final earnedBadgesProvider = Provider<Set<AppBadge>>((ref) {
  final now = DateTime.now();
  final history = ref.watch(historyProvider).value ?? const {};
  final stock = ref.watch(medicineStockProvider).value ?? const [];
  return earnedBadges(
    streak: ref.watch(streakProvider),
    medicines: stock.length,
    expired: stock.where((s) => assess(s, now).hasExpired).length,
    takenMarks: periodSummary(history, now, days: historyDays).taken,
    perfectWeek: isPerfectWeek(history, now),
    diaryEntries: (ref.watch(diaryProvider).value ?? const []).length,
  );
});

/// The badges the person has and has not earned yet, the week and the next
/// streak goal.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(earnedBadgesProvider);
    final streak = ref.watch(streakProvider);
    final history = ref.watch(historyProvider).value ?? const {};
    final week = periodSummary(history, DateTime.now(), days: 7);
    final goal = nextStreakGoal(streak);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.achievementsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          if (week.planned > 0 || goal != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (week.planned > 0)
                      Text(
                        context.l10n.weekSummary(
                          week.taken,
                          week.planned,
                          (100 * week.taken / week.planned).round(),
                        ),
                        style: AppType.cardTitle,
                      ),
                    if (goal != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        context.l10n.goalText(goal, goal - streak),
                        style: AppType.body,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: streak / goal,
                          minHeight: 8,
                          backgroundColor: context.colors.surfaceMid,
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          LayoutBuilder(
            builder: (context, c) {
              // Three to a row, however many badges there are.
              final w = (c.maxWidth - 2 * AppSpacing.sm) / 3;
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final b in AppBadge.values)
                    SizedBox(
                      width: w,
                      child: _BadgeTile(badge: b, earned: badges.contains(b)),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.earned});

  final AppBadge badge;
  final bool earned;

  @override
  Widget build(BuildContext context) => Semantics(
    label:
        '${context.l10n.badgeTitle(badge)}: '
        '${earned ? context.l10n.badgeEarned : context.l10n.badgeLocked}. '
        '${context.l10n.badgeHint(badge)}',
    excludeSemantics: true,
    child: Material(
      color: earned ? context.colors.tint : context.colors.surfaceLow,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.ms),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: earned
                  ? AppColors.peach
                  : context.colors.surfaceMid,
              child: Icon(
                earned ? Icons.emoji_events : Icons.lock_outline,
                color: earned
                    ? AppColors.primaryDeep
                    : context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.badgeTitle(badge),
              textAlign: TextAlign.center,
              style: AppType.label,
            ),
            Text(
              context.l10n.badgeHint(badge),
              textAlign: TextAlign.center,
              style: AppType.micro.copyWith(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    ),
  );
}
