import 'package:flutter/material.dart';

import '../tokens.dart';

enum StatusTone { neutral, accent, success, warning, danger }

/// A status as icon + text on a tinted pill: never colour alone.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.icon,
    this.tone = StatusTone.neutral,
  });

  final String label;
  final IconData icon;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (tone) {
      StatusTone.neutral => (
        context.colors.textSecondary,
        context.colors.background,
      ),
      StatusTone.accent => (context.colors.primaryDeep, context.colors.tint),
      StatusTone.success => (
        context.colors.success,
        context.colors.successTint,
      ),
      StatusTone.warning => (
        context.colors.warning,
        context.colors.warningTint,
      ),
      StatusTone.danger => (context.colors.danger, context.colors.dangerTint),
    };
    return DecoratedBox(
      decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.badgeIcon, color: fg),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(label, style: AppType.caption.copyWith(color: fg)),
            ),
          ],
        ),
      ),
    );
  }
}
