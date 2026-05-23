import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';

/// Nori — blue cloud ghost, wispy base, dot eyes, map pin detail
class NoriPainter extends CustomPainter {
  const NoriPainter(this.size);
  final double size;

  @override
  void paint(Canvas canvas, Size sz) {
    final s = size / 60.0;
    final cx = sz.width / 2;

    final body = Paint()..color = const Color(0xFF5BA8FF);
    final bodyL = Paint()..color = const Color(0xFF9DCFFF);
    final white = Paint()..color = Colors.white;
    final dark = Paint()..color = AppColors.text1;
    final cheek = Paint()
      ..color = const Color(0xFF5BA8FF).withValues(alpha: 0.3);

    // Ghost body — cloud shape made of overlapping circles + rect
    canvas.drawCircle(Offset(cx, 32 * s), 18 * s, body);
    canvas.drawCircle(Offset(cx - 10 * s, 26 * s), 12 * s, body);
    canvas.drawCircle(Offset(cx + 10 * s, 26 * s), 12 * s, body);
    canvas.drawCircle(Offset(cx - 16 * s, 30 * s), 9 * s, body);
    canvas.drawCircle(Offset(cx + 16 * s, 30 * s), 9 * s, body);

    // Body fill rectangle
    canvas.drawRect(
      Rect.fromLTRB(cx - 17 * s, 30 * s, cx + 17 * s, 56 * s),
      body,
    );

    // Wispy bottom — three curved bumps
    canvas.drawCircle(Offset(cx - 12 * s, 56 * s), 5 * s, body);
    canvas.drawCircle(Offset(cx, 57 * s), 5 * s, body);
    canvas.drawCircle(Offset(cx + 12 * s, 56 * s), 5 * s, body);

    // Inner glow
    canvas.drawCircle(Offset(cx, 30 * s), 12 * s, bodyL);

    // Eyes
    canvas.drawCircle(Offset(cx - 7 * s, 28 * s), 4 * s, white);
    canvas.drawCircle(Offset(cx + 7 * s, 28 * s), 4 * s, white);
    canvas.drawCircle(Offset(cx - 7 * s, 29 * s), 2.5 * s, dark);
    canvas.drawCircle(Offset(cx + 7 * s, 29 * s), 2.5 * s, dark);
    canvas.drawCircle(Offset(cx - 6 * s, 27 * s), 1 * s, white);
    canvas.drawCircle(Offset(cx + 8 * s, 27 * s), 1 * s, white);

    // Cheeks
    canvas.drawCircle(Offset(cx - 13 * s, 34 * s), 4 * s, cheek);
    canvas.drawCircle(Offset(cx + 13 * s, 34 * s), 4 * s, cheek);

    // Smile
    final smile = Paint()
      ..color = AppColors.text1
      ..strokeWidth = 1.8 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final smilePath = Path();
    smilePath.moveTo(cx - 4 * s, 36 * s);
    smilePath.quadraticBezierTo(cx, 40 * s, cx + 4 * s, 36 * s);
    canvas.drawPath(smilePath, smile);

    // Map pin detail on body
    canvas.drawCircle(Offset(cx, 47 * s), 5 * s, white);
    canvas.drawCircle(Offset(cx, 47 * s), 3 * s, body);
    final pinStem = Paint()
      ..color = white.color
      ..strokeWidth = 2 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, 50 * s), Offset(cx, 53 * s), pinStem);
  }

  @override
  bool shouldRepaint(covariant NoriPainter old) => old.size != size;
}
