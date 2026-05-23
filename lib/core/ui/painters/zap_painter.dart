import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';

/// Zap — purple/teal robot with antenna, screen face, chunky arms
class ZapPainter extends CustomPainter {
  const ZapPainter(this.size);
  final double size;

  @override
  void paint(Canvas canvas, Size sz) {
    final s = size / 60.0;
    final cx = sz.width / 2;

    final body = Paint()..color = AppColors.purple;
    final bodyL = Paint()..color = AppColors.purpleC;
    final screen = Paint()..color = AppColors.purpleL;
    final dark = Paint()..color = AppColors.text1;
    final teal = Paint()..color = AppColors.teal;

    // Antenna
    final antPaint = Paint()
      ..color = AppColors.purpleC
      ..strokeWidth = 2 * s
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, 10 * s), Offset(cx, 18 * s), antPaint);
    canvas.drawCircle(Offset(cx, 9 * s), 3 * s, teal);

    // Head
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, 28 * s), width: 32 * s, height: 22 * s),
        Radius.circular(8 * s),
      ),
      body,
    );
    // Screen face
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, 27 * s), width: 22 * s, height: 14 * s),
        Radius.circular(4 * s),
      ),
      screen,
    );
    // Eyes (two dots on screen)
    canvas.drawCircle(Offset(cx - 5 * s, 26 * s), 3 * s, teal);
    canvas.drawCircle(Offset(cx + 5 * s, 26 * s), 3 * s, teal);
    final shine = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 4 * s, 25 * s), 1 * s, shine);
    canvas.drawCircle(Offset(cx + 6 * s, 25 * s), 1 * s, shine);
    // Mouth line
    final mouth = Paint()
      ..color = bodyL.color
      ..strokeWidth = 1.5 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(cx - 4 * s, 31 * s), Offset(cx + 4 * s, 31 * s), mouth);

    // Neck
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, 40 * s), width: 10 * s, height: 4 * s),
      bodyL,
    );

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, 50 * s), width: 30 * s, height: 20 * s),
        Radius.circular(6 * s),
      ),
      body,
    );
    // Chest light
    canvas.drawCircle(Offset(cx, 48 * s), 4 * s, teal);
    canvas.drawCircle(Offset(cx, 48 * s), 2 * s, screen);

    // Arms
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx - 20 * s, 50 * s), width: 7 * s, height: 14 * s),
        Radius.circular(4 * s),
      ),
      bodyL,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx + 20 * s, 50 * s), width: 7 * s, height: 14 * s),
        Radius.circular(4 * s),
      ),
      bodyL,
    );

    // Legs
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx - 8 * s, 63 * s), width: 8 * s, height: 8 * s),
        Radius.circular(3 * s),
      ),
      dark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx + 8 * s, 63 * s), width: 8 * s, height: 8 * s),
        Radius.circular(3 * s),
      ),
      dark,
    );
  }

  @override
  bool shouldRepaint(covariant ZapPainter old) => old.size != size;
}
