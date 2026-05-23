import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';

/// Byte — teal coder robot, screen face shows </>, keyboard chest
class BytePainter extends CustomPainter {
  const BytePainter(this.size);
  final double size;

  @override
  void paint(Canvas canvas, Size sz) {
    final s = size / 60.0;
    final cx = sz.width / 2;

    final body = Paint()..color = AppColors.teal;
    final bodyD = Paint()..color = const Color(0xFF009E8B);
    final screen = Paint()..color = AppColors.tealL;
    final dark = Paint()..color = AppColors.text1;
    final purple = Paint()..color = AppColors.purple;

    // Antenna
    final antPaint = Paint()
      ..color = bodyD.color
      ..strokeWidth = 2 * s
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, 8 * s), Offset(cx, 16 * s), antPaint);
    canvas.drawCircle(Offset(cx, 7 * s), 3 * s, purple);

    // Head
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, 26 * s), width: 34 * s, height: 24 * s),
        Radius.circular(7 * s),
      ),
      body,
    );

    // Screen face
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, 25 * s), width: 24 * s, height: 16 * s),
        Radius.circular(4 * s),
      ),
      screen,
    );

    // </> text rendered as shapes
    // "<" bracket
    final ltPaint = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 2 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final ltPath = Path()
      ..moveTo(cx - 8 * s, 22 * s)
      ..lineTo(cx - 12 * s, 25 * s)
      ..lineTo(cx - 8 * s, 28 * s);
    canvas.drawPath(ltPath, ltPaint);

    // "/" slash
    final slashPaint = Paint()
      ..color = AppColors.coral
      ..strokeWidth = 2 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(cx - 1 * s, 28 * s), Offset(cx + 3 * s, 22 * s), slashPaint);

    // ">" bracket
    final gtPath = Path()
      ..moveTo(cx + 6 * s, 22 * s)
      ..lineTo(cx + 10 * s, 25 * s)
      ..lineTo(cx + 6 * s, 28 * s);
    canvas.drawPath(gtPath, ltPaint);

    // Neck
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, 39 * s), width: 10 * s, height: 4 * s),
      bodyD,
    );

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, 50 * s), width: 32 * s, height: 22 * s),
        Radius.circular(6 * s),
      ),
      body,
    );

    // Keyboard keys on chest
    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 4; col++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx - 9 * s + col * 6 * s, 46 * s + row * 7 * s),
              width: 4 * s,
              height: 4 * s,
            ),
            Radius.circular(1 * s),
          ),
          screen,
        );
      }
    }

    // Arms
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx - 21 * s, 49 * s), width: 7 * s, height: 14 * s),
        Radius.circular(4 * s),
      ),
      bodyD,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx + 21 * s, 49 * s), width: 7 * s, height: 14 * s),
        Radius.circular(4 * s),
      ),
      bodyD,
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
  bool shouldRepaint(covariant BytePainter old) => old.size != size;
}
