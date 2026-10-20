import 'package:flutter/material.dart';

import '../tokens.dart';
import '../motion.dart';

/// Nothing to show: an icon illustration, a title, an optional explanation
/// and an optional next step. Centred, and scrolls if the text is large.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.iconColor,
    this.iconBackground,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final Color? iconColor;
  final Color? iconBackground;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.illustration,
              height: AppSizes.illustration,
              decoration: BoxDecoration(
                color: iconBackground ?? context.colors.tint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppSizes.illustrationIcon,
                color: iconColor ?? context.colors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppType.title, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppType.body.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A load failed: what happened and a way to try again.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.error_outline,
    iconColor: context.colors.danger,
    iconBackground: context.colors.dangerTint,
    title: message,
    action: Pressable(
      child: FilledButton.tonalIcon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Повторить'),
      ),
    ),
  );
}

/// Placeholder cards while a list loads; pulses unless the system asks for
/// reduced motion.
class LoadingState extends StatefulWidget {
  const LoadingState({super.key, this.cards = 3});

  final int cards;

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: AppMotion.slow * 2,
    lowerBound: 0.5,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _pulse.value = 1;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget bar(double widthFactor, double height) => FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: context.colors.divider,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
    );
    return Semantics(
      label: 'Загрузка',
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: _pulse,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < widget.cards; i++)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.ms),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bar(0.6, AppSpacing.md),
                      const SizedBox(height: AppSpacing.sm),
                      bar(0.35, AppSpacing.ms),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
