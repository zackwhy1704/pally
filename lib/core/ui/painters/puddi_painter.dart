import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';

/// Puddi — pink owl with big round eyes, fluffy wings, heart nose
class PuddiPainter extends CustomPainter {
  const PuddiPainter(this.size);
  final double size;

  @override
  void paint(Canvas canvas, Size sz) {
    final s = size / 60.0;
    final cx = sz.width / 2;

    final body = Paint()..color = AppColors.pink;
    final bodyL = Paint()..color = const Color(0xFFFFB3D6);
    final white = Paint()..color = Colors.white;
    final dark = Paint()..color = AppColors.text1;
    final amber = Paint()..color = AppColors.amber;
    final cheek = Paint()..color = AppColors.pink.withValues(alpha: 0.3);

    // Ears / tufts
    canvas.drawCircle(Offset(cx - 12 * s, 13 * s), 8 * s, body);
    canvas.drawCircle(Offset(cx + 12 * s, 13 * s), 8 * s, body);
    canvas.drawCircle(Offset(cx - 12 * s, 13 * s), 4 * s, bodyL);
    canvas.drawCircle(Offset(cx + 12 * s, 13 * s), 4 * s, bodyL);

    // Body (oval, wider)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, 42 * s), width: 36 * s, height: 34 * s),
        Radius.circular(18 * s),
      ),
      body,
    );
    // Head
    canvas.drawCircle(Offset(cx, 26 * s), 18 * s, body);
    // Chest patch
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, 46 * s), width: 20 * s, height: 18 * s),
      bodyL,
    );

    // Wing left
    final wingL = Path()
      ..moveTo(cx - 18 * s, 38 * s)
      ..quadraticBezierTo(cx - 28 * s, 44 * s, cx - 20 * s, 54 * s)
      ..quadraticBezierTo(cx - 14 * s, 52 * s, cx - 16 * s, 40 * s)
      ..close();
    canvas.drawPath(wingL, bodyL);
    // Wing right
    final wingR = Path()
      ..moveTo(cx + 18 * s, 38 * s)
      ..quadraticBezierTo(cx + 28 * s, 44 * s, cx + 20 * s, 54 * s)
      ..quadraticBezierTo(cx + 14 * s, 52 * s, cx + 16 * s, 40 * s)
      ..close();
    canvas.drawPath(wingR, bodyL);

    // Eye rings
    canvas.drawCircle(Offset(cx - 7 * s, 24 * s), 8 * s, white);
    canvas.drawCircle(Offset(cx + 7 * s, 24 * s), 8 * s, white);
    // Pupils
    canvas.drawCircle(Offset(cx - 7 * s, 24 * s), 5 * s, dark);
    canvas.drawCircle(Offset(cx + 7 * s, 24 * s), 5 * s, dark);
    // Shine
    canvas.drawCircle(Offset(cx - 6 * s, 22 * s), 1.8 * s, white);
    canvas.drawCircle(Offset(cx + 8 * s, 22 * s), 1.8 * s, white);

    // Cheeks
    canvas.drawCircle(Offset(cx - 14 * s, 29 * s), 4 * s, cheek);
    canvas.drawCircle(Offset(cx + 14 * s, 29 * s), 4 * s, cheek);

    // Beak (small triangle)
    final beak = Path()
      ..moveTo(cx, 30 * s)
      ..lineTo(cx - 3 * s, 34 * s)
      ..lineTo(cx + 3 * s, 34 * s)
      ..close();
    canvas.drawPath(beak, amber);
  }

  @override
  bool shouldRepaint(covariant PuddiPainter old) => old.size != size;
}
