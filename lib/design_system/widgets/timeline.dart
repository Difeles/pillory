import 'package:flutter/material.dart';

import '../tokens.dart';

enum TimelineDotState {
  pending,

  /// The next thing to do: a primary ring with a soft halo.
  next,
  done,
  skipped,
}

/// One entry of a vertical timeline: an optional [leading] column (the
/// time), the rail with its status dot, and [child]. The rail runs through
/// consecutive entries; [first] and [last] trim it at the ends.
class TimelineEntry extends StatelessWidget {
  const TimelineEntry({
    super.key,
    required this.dot,
    required this.child,
    this.leading,
    this.leadingWidth = 0,
    this.first = false,
    this.last = false,
    this.dotTop = AppSpacing.md,
  });

  final TimelineDotState dot;
  final Widget child;
  final Widget? leading;

  /// Width kept for [leading], also when it is null, so rows line up.
  final double leadingWidth;
  final bool first;
  final bool last;

  /// Offset of the dot's centre from the entry's top, to sit on the first
  /// line of [child].
  final double dotTop;

  @override
  Widget build(BuildContext context) {
    const rail = AppSizes.timelineRail;
    const dotSize = AppSizes.timelineDot;
    final lineX = leadingWidth + (rail - AppSizes.timelineLine) / 2;
    return Stack(
      children: [
        if (!first)
          Positioned(left: lineX, top: 0, height: dotTop, child: const _Line()),
        if (!last)
          Positioned(left: lineX, top: dotTop, bottom: 0, child: const _Line()),
        Positioned(
          left: leadingWidth + (rail - dotSize) / 2,
          top: dotTop - dotSize / 2,
          child: _Dot(dot),
        ),
        Padding(
          padding: EdgeInsets.only(left: leadingWidth + rail + AppSpacing.sm),
          child: child,
        ),
        if (leading != null)
          Positioned(left: 0, top: 0, width: leadingWidth, child: leading!),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: AppSizes.timelineLine,
    child: ColoredBox(color: context.colors.divider),
  );
}

class _Dot extends StatelessWidget {
  const _Dot(this.state);

  final TimelineDotState state;

  @override
  Widget build(BuildContext context) {
    const size = AppSizes.timelineDot;
    // Each state has its own shape, not only a colour; the entry also spells
    // the status out, so the dot stays out of the semantics tree.
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: switch (state) {
          TimelineDotState.pending => BoxDecoration(
            color: context.colors.background,
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.inputBorder, width: 1.5),
          ),
          TimelineDotState.next => BoxDecoration(
            color: context.colors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.surface, width: 2),
            boxShadow: [BoxShadow(color: context.colors.tint, spreadRadius: 3)],
          ),
          TimelineDotState.done => BoxDecoration(
            color: context.colors.success,
            shape: BoxShape.circle,
          ),
          TimelineDotState.skipped => BoxDecoration(
            color: context.colors.background,
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.textSecondary, width: 1.5),
          ),
        },
        child: switch (state) {
          TimelineDotState.done => Icon(
            Icons.check,
            size: size - 3,
            color: context.colors.onSuccess,
          ),
          TimelineDotState.skipped => Icon(
            Icons.remove,
            size: size - 4,
            color: context.colors.textSecondary,
          ),
          _ => null,
        },
      ),
    );
  }
}
