import 'dart:ui';

import 'package:flutter/material.dart';

import '../motion.dart';
import '../tokens.dart';

class DockItem {
  const DockItem(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// The floating capsule navigation bar.
class FloatingDock extends StatelessWidget {
  const FloatingDock({
    super.key,
    required this.items,
    required this.index,
    required this.onSelected,
  });

  final List<DockItem> items;
  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    // Sits closer to the screen edge than a plain SafeArea would put it.
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    final colors = context.colors;
    // Increase Contrast: no frosted glass, an opaque bar with a clear edge.
    final solid = MediaQuery.highContrastOf(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          inset > 12 ? inset - 4 : AppSpacing.sm,
        ),
        // The shadow sits outside the clip; the glass (blur, translucent
        // fill, ghost border) inside it.
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            shadows: colors.raisedShadow,
          ),
          child: ClipPath(
            clipper: const ShapeBorderClipper(shape: StadiumBorder()),
            child: _glass(
              solid: solid,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: solid ? colors.inputBorder : colors.glassBorder,
                      width: 1.5,
                    ),
                  ),
                  color: solid ? colors.surface : colors.glass,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Stack(
                    children: [
                      // One indicator that springs from tab to tab.
                      Positioned.fill(
                        child: AnimatedAlign(
                          duration: motionOf(context, AppMotion.tab),
                          curve: AppMotion.spring,
                          alignment: Alignment(
                            -1 + 2 * index / (items.length - 1),
                            0,
                          ),
                          child: FractionallySizedBox(
                            widthFactor: 1 / items.length,
                            heightFactor: 1,
                            child: DecoratedBox(
                              decoration: ShapeDecoration(
                                shape: StadiumBorder(),
                                color: context.colors.tint,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < items.length; i++)
                            Expanded(
                              child: _DockButton(
                                item: items[i],
                                selected: i == index,
                                onTap: () => onSelected(i),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _glass({required bool solid, required Widget child}) => solid
    ? child
    : BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: child,
      );

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final DockItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: Pressable(
        scale: .9,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                end: selected
                    ? context.colors.primaryDeep
                    : context.colors.textSecondary,
              ),
              duration: motionOf(context, AppMotion.tab),
              builder: (context, color, _) => Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The icon pops a little when its tab is chosen.
                  AnimatedScale(
                    scale: selected ? 1.18 : 1,
                    duration: motionOf(context, AppMotion.tab),
                    curve: AppMotion.spring,
                    child: Icon(
                      selected ? item.selectedIcon : item.icon,
                      color: color,
                    ),
                  ),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.micro.copyWith(color: color),
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
