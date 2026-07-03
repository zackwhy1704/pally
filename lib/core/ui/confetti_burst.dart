import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';

/// A burst of falling coloured dots driven by a parent animation (e.g. a
/// celebration dialog's entry). Cheap CustomPainter — no extra Tickers, ~28
/// particles — so a one-shot effect doesn't drag in a dependency. Shared by the
/// level-up and consent-approved celebrations so the visual language matches.
class ConfettiBurst extends StatelessWidget {
  const ConfettiBurst({super.key, required this.progress});
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (_, __) => CustomPaint(painter: _ConfettiPainter(t: progress.value)),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.t});
  final double t; // 0 → 1

  // Deterministic seed so the same celebration always paints the same burst.
  static const int _seed = 0xC0FFEE;
  static const List<Color> _palette = [
    AppColors.purple,
    AppColors.amber,
    AppColors.gold,
    AppColors.teal,
    AppColors.coral,
    AppColors.pink,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(_seed);
    const count = 28;
    for (var i = 0; i < count; i++) {
      final col = _palette[i % _palette.length];
      final startX = rng.nextDouble() * size.width;
      final drift = (rng.nextDouble() - 0.5) * 120;
      final fallHeight = size.height * (0.4 + rng.nextDouble() * 0.6);
      final delay = rng.nextDouble() * 0.3; // stagger starts
      final localT = ((t - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      final x = startX + drift * localT;
      final y = -16 + fallHeight * localT;
      final radius = 3.0 + rng.nextDouble() * 3.5;
      final fade = (1.0 - localT).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = col.withValues(alpha: 0.9 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
