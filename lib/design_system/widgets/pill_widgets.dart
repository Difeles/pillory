import 'package:flutter/material.dart';

import '../motion.dart';
import '../tokens.dart';

/// Capsule segmented control; a [Wrap]-free equal-width row.
class SegmentedPills<T> extends StatelessWidget {
  const SegmentedPills({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: ShapeDecoration(
      shape: StadiumBorder(),
      color: context.colors.surfaceLow,
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Stack(
        children: [
          // One indicator that springs to the chosen option, like the dock's.
          Positioned.fill(
            child: AnimatedAlign(
              duration: motionOf(context, AppMotion.tab),
              curve: AppMotion.spring,
              alignment: Alignment(
                options.length < 2
                    ? 0
                    : -1 +
                          2 *
                              options.keys.toList().indexOf(selected) /
                              (options.length - 1),
                0,
              ),
              child: FractionallySizedBox(
                widthFactor: 1 / options.length,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: StadiumBorder(),
                    color: context.colors.surface,
                    shadows: context.colors.cardShadow,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final e in options.entries)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: e.key == selected,
                    child: Pressable(
                      scale: .94,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(e.key),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 44),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: TweenAnimationBuilder<Color?>(
                                tween: ColorTween(
                                  end: e.key == selected
                                      ? context.colors.primaryDeep
                                      : context.colors.textSecondary,
                                ),
                                duration: motionOf(context, AppMotion.tab),
                                builder: (context, color, _) => Text(
                                  e.value,
                                  textAlign: TextAlign.center,
                                  style: AppType.label.copyWith(color: color),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// A squircle tile with an icon over a label; used for forms and categories.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? context.colors.primaryDeep
        : context.colors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        scale: .93,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: motionOf(context, AppMotion.base),
            curve: AppMotion.smooth,
            decoration: ShapeDecoration(
              color: selected ? context.colors.tint : context.colors.surfaceLow,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                // Always as wide, so choosing a tile does not resize it.
                side: BorderSide(
                  color: selected ? context.colors.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.ms,
              ),
              // Centred, so a tile stretched to its row's height stays tidy.
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppType.captionStrong.copyWith(color: color),
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

/// A settings row: tinted icon, title, subtitle and a switch.
class SettingToggleRow extends StatelessWidget {
  const SettingToggleRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Material(
    color: context.colors.surfaceLow,
    shape: RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(AppRadii.sm),
    ),
    child: Pressable(
      scale: .98,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        secondary: CircleAvatar(
          backgroundColor: context.colors.tint,
          child: Icon(icon, color: context.colors.primaryDeep),
        ),
        title: Text(title, style: AppType.cardTitle),
        subtitle: Text(subtitle, style: AppType.caption),
      ),
    ),
  );
}

/// A settings row with a choice between a few options, under its title.
class SettingChoiceRow<T> extends StatelessWidget {
  const SettingChoiceRow({
    super.key,
    required this.icon,
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Material(
    color: context.colors.surfaceLow,
    shape: RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(AppRadii.sm),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: context.colors.tint,
                child: Icon(icon, color: context.colors.primaryDeep),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(title, style: AppType.cardTitle)),
            ],
          ),
          const SizedBox(height: AppSpacing.ms),
          SegmentedPills<T>(
            options: options,
            selected: selected,
            onChanged: onChanged,
          ),
        ],
      ),
    ),
  );
}
