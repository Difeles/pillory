import 'package:flutter/material.dart';

import '../tokens.dart';

/// The pill mascot, drawn in code. [happy] toggles the smile.
class MascotPill extends StatelessWidget {
  const MascotPill({super.key, this.size = 40, this.color, this.happy = true});

  final double size;

  /// The body colour; the appearance's primary when null.
  final Color? color;
  final bool happy;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _MascotPainter(color ?? context.colors.primary, happy),
    ),
  );
}

class _MascotPainter extends CustomPainter {
  _MascotPainter(this.color, this.happy);

  final Color color;
  final bool happy;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * .12, w * .06, w * .76, w * .88),
      Radius.circular(w * .38),
    );
    canvas.drawRRect(body, Paint()..color = color);
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(
      Rect.fromLTWH(0, w * .56, w, w),
      Paint()..color = Colors.white.withValues(alpha: .28),
    );
    canvas.restore();
    final eye = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * .38, w * .4), w * .055, eye);
    canvas.drawCircle(Offset(w * .62, w * .4), w * .055, eye);
    final cheek = Paint()..color = AppColors.peach.withValues(alpha: .8);
    canvas.drawCircle(Offset(w * .29, w * .5), w * .05, cheek);
    canvas.drawCircle(Offset(w * .71, w * .5), w * .05, cheek);
    final mouth = Path()
      ..moveTo(w * .42, w * .52)
      ..quadraticBezierTo(w * .5, w * (happy ? .62 : .5), w * .58, w * .52);
    canvas.drawPath(
      mouth,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * .045,
    );
  }

  @override
  bool shouldRepaint(_MascotPainter o) => o.color != color || o.happy != happy;
}
