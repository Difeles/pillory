import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/pill_look.dart';

/// A pill drawn from a [PillLook]: its silhouette, colours and score.
class PillView extends StatelessWidget {
  const PillView({super.key, required this.look, this.size = 40});

  final PillLook look;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(size: Size.square(size), painter: _PillPainter(look)),
  );
}

class _PillPainter extends CustomPainter {
  _PillPainter(this.look);

  final PillLook look;

  Color _shade(Color c, double by) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + by).clamp(0.0, 1.0)).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final base = Color(look.color);
    final second = Color(look.color2 ?? look.color);
    canvas.save();
    canvas.translate(s / 2, s / 2);
    // Long pills lie diagonally.
    final long =
        look.shape == PillShape.capsule ||
        look.shape == PillShape.caplet ||
        look.shape == PillShape.oval;
    if (long) canvas.rotate(-math.pi / 4);

    // The body, in a box centred on the origin.
    final (w, h) = switch (look.shape) {
      PillShape.round => (s * .78, s * .78),
      PillShape.square => (s * .72, s * .72),
      PillShape.oval => (s * .86, s * .56),
      PillShape.caplet => (s * .94, s * .44),
      PillShape.capsule => (s * .94, s * .46),
    };
    final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    final radius = switch (look.shape) {
      PillShape.round => h / 2,
      PillShape.oval => h / 2,
      PillShape.capsule => h / 2,
      PillShape.caplet => h * .38,
      PillShape.square => h * .22,
    };
    final body = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final outline = _shade(base, look.color == 0xFFFFFFFF ? -.18 : -.16);

    canvas.save();
    canvas.clipRRect(body);
    final paint = Paint()..isAntiAlias = true;
    if (look.isCapsule) {
      canvas.drawRect(
        Rect.fromLTRB(rect.left, rect.top, 0, rect.bottom),
        paint..color = base,
      );
      canvas.drawRect(
        Rect.fromLTRB(0, rect.top, rect.right, rect.bottom),
        paint..color = second,
      );
    } else {
      canvas.drawRRect(body, paint..color = base);
    }
    // A soft light along the top edge.
    canvas.drawRRect(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: .35),
            Colors.white.withValues(alpha: 0),
            Colors.black.withValues(alpha: .08),
          ],
          stops: const [0, .55, 1],
        ).createShader(rect),
    );
    canvas.restore();
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, s * .035)
        ..color = outline,
    );

    // The score: a groove across the middle.
    final groove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1, s * .045)
      ..color = outline;
    if (look.isCapsule) {
      canvas.drawLine(
        Offset(0, rect.top + h * .06),
        Offset(0, rect.bottom - h * .06),
        groove..color = outline.withValues(alpha: .55),
      );
    } else if (look.score != PillScore.none) {
      final across = h * .44;
      canvas.drawLine(Offset(0, -across), Offset(0, across), groove);
      if (look.score == PillScore.cross) {
        final along = math.min(w, h * 1.6) * .38;
        canvas.drawLine(Offset(-along, 0), Offset(along, 0), groove);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PillPainter old) => old.look != look;
}
