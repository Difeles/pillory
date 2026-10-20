import 'package:flutter/material.dart';

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
    decoration: const ShapeDecoration(
      shape: StadiumBorder(),
      color: AppColors.surfaceLow,
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Row(
        children: [
          for (final e in options.entries)
            Expanded(
              child: Semantics(
                button: true,
                selected: e.key == selected,
                child: Material(
                  color: e.key == selected
                      ? AppColors.surface
                      : Colors.transparent,
                  shape: const StadiumBorder(),
                  elevation: e.key == selected ? 1 : 0,
                  shadowColor: AppColors.primary,
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: () => onChanged(e.key),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            e.value,
                            textAlign: TextAlign.center,
                            style: AppType.label.copyWith(
                              color: e.key == selected
                                  ? AppColors.primaryDeep
                                  : AppColors.textSecondary,
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
    final color = selected ? AppColors.primaryDeep : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.tint : AppColors.surfaceLow,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          side: selected
              ? const BorderSide(color: AppColors.primary, width: 1.5)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.ms,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
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
    color: AppColors.surfaceLow,
    shape: RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(AppRadii.sm),
    ),
    child: SwitchListTile(
      value: value,
      onChanged: onChanged,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      secondary: CircleAvatar(
        backgroundColor: AppColors.tint,
        child: Icon(icon, color: AppColors.primaryDeep),
      ),
      title: Text(title, style: AppType.cardTitle),
      subtitle: Text(subtitle, style: AppType.caption),
    ),
  );
}
