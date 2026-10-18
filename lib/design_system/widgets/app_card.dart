import 'package:flutter/material.dart';

import '../tokens.dart';

enum AppCardVariant {
  normal,

  /// Done or archived: tinted, flat.
  muted,

  /// Pointed at (e.g. by a reminder): outlined in the primary colour.
  highlighted,
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
    final muted = variant == AppCardVariant.muted;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      side: variant == AppCardVariant.highlighted
          ? const BorderSide(color: AppColors.primary, width: 2)
          : BorderSide.none,
    );
    return Semantics(
      container: true,
      button: onTap != null,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape,
          shadows: muted ? null : AppShadows.card,
        ),
        child: Material(
          color: muted ? AppColors.tint : AppColors.surface,
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
