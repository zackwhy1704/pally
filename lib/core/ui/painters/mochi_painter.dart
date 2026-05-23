import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';

/// Mochi — beige dumpling bear, tiny bead eyes, chonky round body
class MochiPainter extends CustomPainter {
  const MochiPainter(this.size);
  final double size;

  @override
  void paint(Canvas canvas, Size sz) {
    final s = size / 60.0;
    final cx = sz.width / 2;

    final body = Paint()..color = const Color(0xFFE8D5B0);
    final belly = Paint()..color = const Color(0xFFF5ECD8);
    final ear = Paint()..color = const Color(0xFFD4B896);
    final eye = Paint()..color = AppColors.text1;
    final nose = Paint()..color = const Color(0xFFCB9A7A);
    final cheek = Paint()..color = AppColors.amber.withValues(alpha: 0.35);

    // Ears
    canvas.drawCircle(Offset(cx - 14 * s, 16 * s), 8 * s, ear);
    canvas.drawCircle(Offset(cx + 14 * s, 16 * s), 8 * s, ear);
    // Inner ears
    final innerEar = Paint()..color = const Color(0xFFFFB8B8);
    canvas.drawCircle(Offset(cx - 14 * s, 16 * s), 5 * s, innerEar);
    canvas.drawCircle(Offset(cx + 14 * s, 16 * s), 5 * s, innerEar);

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, 44 * s), width: 38 * s, height: 30 * s),
        Radius.circular(16 * s),
      ),
      body,
    );
    // Head
    canvas.drawCircle(Offset(cx, 30 * s), 20 * s, body);
    // Belly patch
    canvas.drawCircle(Offset(cx, 48 * s), 10 * s, belly);

    // Cheeks
    canvas.drawCircle(Offset(cx - 12 * s, 34 * s), 5 * s, cheek);
    canvas.drawCircle(Offset(cx + 12 * s, 34 * s), 5 * s, cheek);

    // Eyes
    canvas.drawCircle(Offset(cx - 7 * s, 27 * s), 3 * s, eye);
    canvas.drawCircle(Offset(cx + 7 * s, 27 * s), 3 * s, eye);
    // Eye shine
    final shine = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 6 * s, 26 * s), 1 * s, shine);
    canvas.drawCircle(Offset(cx + 8 * s, 26 * s), 1 * s, shine);

    // Nose
    final path = Path()
      ..moveTo(cx, 31 * s)
      ..lineTo(cx - 3 * s, 35 * s)
      ..lineTo(cx + 3 * s, 35 * s)
      ..close();
    canvas.drawPath(path, nose);
  }

  @override
  bool shouldRepaint(covariant MochiPainter old) => old.size != size;
}
