import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';

/// Lumis — golden star character (RARE), 5-pointed star body, sparkles
class LumisPainter extends CustomPainter {
  const LumisPainter(this.size);
  final double size;

  @override
  void paint(Canvas canvas, Size sz) {
    final s = size / 60.0;
    final cx = sz.width / 2;

    final gold = Paint()..color = AppColors.gold;
    final goldD = Paint()..color = const Color(0xFFE6BC00);
    final white = Paint()..color = Colors.white;
    final dark = Paint()..color = AppColors.text1;
    final cheek = Paint()..color = AppColors.gold.withValues(alpha: 0.4);

    // Draw 5-pointed star as body
    final starPath = _starPath(Offset(cx, 36 * s), 26 * s, 11 * s, 5);
    canvas.drawPath(starPath, gold);
    // Star outline/depth
    final starOutline = Paint()
      ..color = goldD.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s;
    canvas.drawPath(starPath, starOutline);

    // Inner glow circle
    canvas.drawCircle(Offset(cx, 34 * s), 16 * s, goldD);

    // Head (round, sits on top of star center)
    canvas.drawCircle(Offset(cx, 26 * s), 16 * s, gold);

    // Cheeks
    canvas.drawCircle(Offset(cx - 11 * s, 29 * s), 4 * s, cheek);
    canvas.drawCircle(Offset(cx + 11 * s, 29 * s), 4 * s, cheek);

    // Eyes
    canvas.drawCircle(Offset(cx - 6 * s, 23 * s), 3.5 * s, dark);
    canvas.drawCircle(Offset(cx + 6 * s, 23 * s), 3.5 * s, dark);
    canvas.drawCircle(Offset(cx - 5 * s, 22 * s), 1.2 * s, white);
    canvas.drawCircle(Offset(cx + 7 * s, 22 * s), 1.2 * s, white);

    // Smile
    final smile = Paint()
      ..color = AppColors.text1
      ..strokeWidth = 2 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final smilePath = Path();
    smilePath.moveTo(cx - 4 * s, 29 * s);
    smilePath.quadraticBezierTo(cx, 33 * s, cx + 4 * s, 29 * s);
    canvas.drawPath(smilePath, smile);

    // Sparkle top-left
    _drawSparkle(canvas, Offset(cx - 18 * s, 10 * s), 4 * s, white.color);
    // Sparkle top-right
    _drawSparkle(canvas, Offset(cx + 20 * s, 8 * s), 3 * s, white.color);
    // Sparkle right
    _drawSparkle(canvas, Offset(cx + 24 * s, 28 * s), 2.5 * s, white.color);
  }

  void _drawSparkle(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = r * 0.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(center.dx, center.dy - r),
        Offset(center.dx, center.dy + r), paint);
    canvas.drawLine(Offset(center.dx - r, center.dy),
        Offset(center.dx + r, center.dy), paint);
    canvas.drawLine(
      Offset(center.dx - r * 0.7, center.dy - r * 0.7),
      Offset(center.dx + r * 0.7, center.dy + r * 0.7),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + r * 0.7, center.dy - r * 0.7),
      Offset(center.dx - r * 0.7, center.dy + r * 0.7),
      paint,
    );
  }

  Path _starPath(Offset center, double outerR, double innerR, int points) {
    final path = Path();
    final step = 3.14159265358979 / points;
    for (int i = 0; i < points * 2; i++) {
      final angle = i * step - 3.14159265358979 / 2;
      final r = i.isEven ? outerR : innerR;
      final x = center.dx + r * _cos(angle);
      final y = center.dy + r * _sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  double _cos(double angle) {
    return _sin(angle + 3.14159265358979 / 2);
  }

  double _sin(double angle) {
    // Taylor series approximation — sufficient for painter precision
    double x = angle % (2 * 3.14159265358979);
    if (x > 3.14159265358979) x -= 2 * 3.14159265358979;
    if (x < -3.14159265358979) x += 2 * 3.14159265358979;
    final x2 = x * x;
    return x * (1 - x2 / 6 * (1 - x2 / 20 * (1 - x2 / 42)));
  }

  @override
  bool shouldRepaint(covariant LumisPainter old) => old.size != size;
}
