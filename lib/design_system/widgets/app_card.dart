import 'package:flutter/material.dart';

import '../tokens.dart';

enum AppCardVariant {
  normal,

  /// Done or archived: tinted, flat.
  muted,

  /// Pointed at (e.g. by a reminder): outlined in the primary colour.
  highlighted,

  /// Completed: mint fill.
  done,

  /// Stands out by a hairline and its contents rather than by elevation.
  outlined,
}

/// The one card surface. Tappable when [onTap] is set, and then announced as
/// a button; buttons inside it stay separately reachable.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.variant = AppCardVariant.normal,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final VoidCallback? onTap;
  final AppCardVariant variant;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final flat =
        variant == AppCardVariant.muted ||
        variant == AppCardVariant.outlined ||
        variant == AppCardVariant.done;
    final shape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      side: switch (variant) {
        AppCardVariant.highlighted => const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
        AppCardVariant.outlined => const BorderSide(color: AppColors.divider),
        _ => BorderSide.none,
      },
    );
    return Semantics(
      container: true,
      button: onTap != null,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape,
          shadows: flat ? null : AppShadows.card,
        ),
        child: Material(
          color: switch (variant) {
            AppCardVariant.muted => AppColors.surfaceLow,
            AppCardVariant.done => AppColors.successTint,
            _ => AppColors.surface,
          },
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: kMinTapSize),
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
