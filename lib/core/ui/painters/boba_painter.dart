import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';

/// Boba — green alien with antennae, big eyes, round head
class BobaPainter extends CustomPainter {
  const BobaPainter(this.size);
  final double size;

  @override
  void paint(Canvas canvas, Size sz) {
    final s = size / 60.0;
    final cx = sz.width / 2;

    final body = Paint()..color = AppColors.green;
    final bodyL = Paint()..color = const Color(0xFF5DDBA0);
    final dark = Paint()..color = AppColors.text1;
    final white = Paint()..color = Colors.white;
    final cheek = Paint()..color = AppColors.green.withValues(alpha: 0.3);

    // Antennae stems
    final antPaint = Paint()
      ..color = AppColors.green
      ..strokeWidth = 2.5 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(cx - 8 * s, 16 * s), Offset(cx - 12 * s, 6 * s), antPaint);
    canvas.drawLine(
        Offset(cx + 8 * s, 16 * s), Offset(cx + 12 * s, 6 * s), antPaint);
    // Antenna tips
    canvas.drawCircle(Offset(cx - 12 * s, 5 * s), 3.5 * s, bodyL);
    canvas.drawCircle(Offset(cx + 12 * s, 5 * s), 3.5 * s, bodyL);

    // Head
    canvas.drawCircle(Offset(cx, 28 * s), 18 * s, body);

    // Ears (small bumps)
    canvas.drawCircle(Offset(cx - 17 * s, 26 * s), 5 * s, body);
    canvas.drawCircle(Offset(cx + 17 * s, 26 * s), 5 * s, body);

    // Big eyes — whites
    canvas.drawCircle(Offset(cx - 7 * s, 25 * s), 7 * s, white);
    canvas.drawCircle(Offset(cx + 7 * s, 25 * s), 7 * s, white);
    // Pupils
    canvas.drawCircle(Offset(cx - 6 * s, 26 * s), 4 * s, dark);
    canvas.drawCircle(Offset(cx + 8 * s, 26 * s), 4 * s, dark);
    // Eye shines
    canvas.drawCircle(Offset(cx - 5 * s, 24 * s), 1.5 * s, white);
    canvas.drawCircle(Offset(cx + 9 * s, 24 * s), 1.5 * s, white);

    // Cheeks
    canvas.drawCircle(Offset(cx - 13 * s, 32 * s), 4 * s, cheek);
    canvas.drawCircle(Offset(cx + 13 * s, 32 * s), 4 * s, cheek);

    // Smile
    final smile = Paint()
      ..color = AppColors.text1
      ..strokeWidth = 2 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final smilePath = Path();
    smilePath.moveTo(cx - 5 * s, 33 * s);
    smilePath.quadraticBezierTo(cx, 38 * s, cx + 5 * s, 33 * s);
    canvas.drawPath(smilePath, smile);

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, 52 * s), width: 28 * s, height: 20 * s),
        Radius.circular(12 * s),
      ),
      body,
    );
    // Tummy
    canvas.drawCircle(Offset(cx, 53 * s), 7 * s, bodyL);
  }

  @override
  bool shouldRepaint(covariant BobaPainter old) => old.size != size;
}
