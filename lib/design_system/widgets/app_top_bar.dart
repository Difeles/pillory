import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens.dart';
import 'mascot_pill.dart';
import '../motion.dart';

/// Brand + screen title on the left, quick action and avatar on the right.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, required this.title, this.actions = const []});

  /// Buttons at the right end.
  final List<Widget> actions;

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    // The bar has a fixed height, so its text scales only up to a point.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Status bar icons: light on the dark appearance, dark on the light.
      value: Theme.brightnessOf(context) == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  const MascotPill(size: 36),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PILLPAL',
                          style: AppType.overline.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.title.copyWith(height: 1.1),
                        ),
                      ],
                    ),
                  ),
                  ...actions,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The round "+" button for a top bar.
class TopBarAddButton extends StatelessWidget {
  const TopBarAddButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
  });

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Pressable(
    scale: .88,
    child: IconButton.filled(
      tooltip: tooltip,
      onPressed: onPressed,
      // Smaller than the tap target: the button pads itself to 48 for touch.
      style: IconButton.styleFrom(
        minimumSize: const Size.square(40),
        iconSize: 22,
      ),
      icon: const Icon(Icons.add),
    ),
  );
}
