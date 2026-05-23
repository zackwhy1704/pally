import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';

/// Finn — warm brown fox/bear with hat, white inner face
class FinnPainter extends CustomPainter {
  const FinnPainter(this.size);
  final double size;

  @override
  void paint(Canvas canvas, Size sz) {
    final s = size / 60.0;
    final cx = sz.width / 2;

    final brown = Paint()..color = const Color(0xFFB5713A);
    final light = Paint()..color = const Color(0xFFF5CFA0);
    final dark = Paint()..color = AppColors.text1;
    final hat = Paint()..color = const Color(0xFF8B4513);
    final hatB = Paint()..color = const Color(0xFF6B3410);
    final cheek = Paint()..color = AppColors.coral.withValues(alpha: 0.3);

    // Hat brim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, 12 * s), width: 36 * s, height: 5 * s),
        Radius.circular(2 * s),
      ),
      hatB,
    );
    // Hat top
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, 6 * s), width: 24 * s, height: 12 * s),
        Radius.circular(4 * s),
      ),
      hat,
    );

    // Ears
    canvas.drawCircle(Offset(cx - 14 * s, 20 * s), 8 * s, brown);
    canvas.drawCircle(Offset(cx + 14 * s, 20 * s), 8 * s, brown);
    canvas.drawCircle(Offset(cx - 14 * s, 20 * s), 5 * s, light);
    canvas.drawCircle(Offset(cx + 14 * s, 20 * s), 5 * s, light);

    // Head
    canvas.drawCircle(Offset(cx, 32 * s), 20 * s, brown);
    // Inner face
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, 34 * s), width: 26 * s, height: 22 * s),
      light,
    );

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, 52 * s), width: 32 * s, height: 24 * s),
        Radius.circular(12 * s),
      ),
      brown,
    );
    // Tummy
    canvas.drawCircle(Offset(cx, 54 * s), 9 * s, light);

    // Cheeks
    canvas.drawCircle(Offset(cx - 11 * s, 36 * s), 5 * s, cheek);
    canvas.drawCircle(Offset(cx + 11 * s, 36 * s), 5 * s, cheek);

    // Eyes
    canvas.drawCircle(Offset(cx - 7 * s, 29 * s), 3.5 * s, dark);
    canvas.drawCircle(Offset(cx + 7 * s, 29 * s), 3.5 * s, dark);
    final shine = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 6 * s, 28 * s), 1.2 * s, shine);
    canvas.drawCircle(Offset(cx + 8 * s, 28 * s), 1.2 * s, shine);

    // Nose
    canvas.drawCircle(Offset(cx, 34 * s), 2.5 * s, dark);
  }

  @override
  bool shouldRepaint(covariant FinnPainter old) => old.size != size;
}
