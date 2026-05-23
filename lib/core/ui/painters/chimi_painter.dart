import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';

/// Chimi — warm red/orange bear with scarf, round ears
class ChimiPainter extends CustomPainter {
  const ChimiPainter(this.size);
  final double size;

  @override
  void paint(Canvas canvas, Size sz) {
    final s = size / 60.0;
    final cx = sz.width / 2;

    final body = Paint()..color = const Color(0xFFE84040);
    final bodyL = Paint()..color = const Color(0xFFF5A0A0);
    final scarf = Paint()..color = const Color(0xFFFF8C00);
    final scarfD = Paint()..color = const Color(0xFFD06800);
    final dark = Paint()..color = AppColors.text1;
    final cheek = Paint()..color = AppColors.coral.withValues(alpha: 0.35);

    // Ears
    canvas.drawCircle(Offset(cx - 14 * s, 19 * s), 9 * s, body);
    canvas.drawCircle(Offset(cx + 14 * s, 19 * s), 9 * s, body);
    canvas.drawCircle(Offset(cx - 14 * s, 19 * s), 5 * s, bodyL);
    canvas.drawCircle(Offset(cx + 14 * s, 19 * s), 5 * s, bodyL);

    // Head
    canvas.drawCircle(Offset(cx, 31 * s), 19 * s, body);
    // Inner face
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, 33 * s), width: 24 * s, height: 20 * s),
      bodyL,
    );

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, 52 * s), width: 30 * s, height: 22 * s),
        Radius.circular(12 * s),
      ),
      body,
    );

    // Scarf
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, 43 * s), width: 34 * s, height: 7 * s),
        Radius.circular(3 * s),
      ),
      scarf,
    );
    // Scarf stripe
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, 44 * s), width: 34 * s, height: 2 * s),
        Radius.circular(1 * s),
      ),
      scarfD,
    );
    // Scarf tail
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx + 12 * s, 48 * s), width: 6 * s, height: 10 * s),
        Radius.circular(3 * s),
      ),
      scarf,
    );

    // Cheeks
    canvas.drawCircle(Offset(cx - 11 * s, 34 * s), 5 * s, cheek);
    canvas.drawCircle(Offset(cx + 11 * s, 34 * s), 5 * s, cheek);

    // Eyes
    canvas.drawCircle(Offset(cx - 7 * s, 27 * s), 3.5 * s, dark);
    canvas.drawCircle(Offset(cx + 7 * s, 27 * s), 3.5 * s, dark);
    final shine = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 6 * s, 26 * s), 1.2 * s, shine);
    canvas.drawCircle(Offset(cx + 8 * s, 26 * s), 1.2 * s, shine);

    // Nose
    canvas.drawCircle(Offset(cx, 33 * s), 2.5 * s, dark);
  }

  @override
  bool shouldRepaint(covariant ChimiPainter old) => old.size != size;
}
