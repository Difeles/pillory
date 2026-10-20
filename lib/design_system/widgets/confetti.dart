import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.dart';

/// Shows a short confetti burst over the whole screen; fire and forget.
void showConfetti(BuildContext context) {
  if (MediaQuery.disableAnimationsOf(context)) return;
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => IgnorePointer(child: _Burst(onDone: () => entry.remove())),
  );
  overlay.insert(entry);
}

typedef _Part = ({double angle, double speed, Color color});

class _Burst extends StatefulWidget {
  const _Burst({required this.onDone});
  final VoidCallback onDone;

  @override
  State<_Burst> createState() => _BurstState();
}

class _BurstState extends State<_Burst> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward().whenComplete(widget.onDone);
  final _rng = math.Random();
  static const _colors = [
    AppColors.primary,
    AppColors.peach,
    AppColors.mintFill,
    AppColors.pink,
    AppColors.blue,
  ];
  late final List<_Part> _parts = List.generate(
    36,
    (_) => (
      angle: math.pi + _rng.nextDouble() * math.pi, // upwards
      speed: .25 + _rng.nextDouble() * .35,
      color: _colors[_rng.nextInt(_colors.length)],
    ),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedBuilder(
      animation: _c,
      builder: (_, _) =>
          CustomPaint(size: Size.infinite, painter: _P(_c.value, _parts)),
    ),
  );
}

class _P extends CustomPainter {
  _P(this.t, this.parts);
  final double t;
  final List<_Part> parts;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * .65);
    for (final p in parts) {
      final d = p.speed * size.height * Curves.easeOut.transform(t);
      final pos =
          origin +
          Offset(math.cos(p.angle) * d, math.sin(p.angle) * d + t * t * 260);
      canvas.drawCircle(
        pos,
        5,
        Paint()..color = p.color.withValues(alpha: 1 - t),
      );
    }
  }

  @override
  bool shouldRepaint(_P o) => o.t != t;
}
