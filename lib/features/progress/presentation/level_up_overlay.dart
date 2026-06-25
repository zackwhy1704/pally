import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// Full-screen celebration overlay shown once when the user crosses a level
/// threshold. Caller is responsible for showing it exactly once per crossing
/// (typically by clearing the levelledUp flag after dismissal).
///
/// Self-dismisses after [autoDismiss] (default 4s) so quick level-ups
/// during a fast quiz session don't pile up on each other.
class LevelUpOverlay {
  LevelUpOverlay._();

  static const Duration autoDismiss = Duration(seconds: 4);

  static Future<void> show(BuildContext context, int newLevel) async {
    HapticFeedback.heavyImpact();
    Timer? closer;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Level Up',
      barrierColor: const Color(0xBB1F1733),
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, __, ___) {
        // Arm auto-dismiss on the first build only — transitionBuilder
        // runs every frame during the entry/exit animations.
        closer ??= Timer(autoDismiss, () {
          if (Navigator.of(ctx, rootNavigator: true).canPop()) {
            Navigator.of(ctx, rootNavigator: true).pop();
          }
        });
        return _CelebrationLayer(anim: anim, newLevel: newLevel);
      },
    );
    closer?.cancel();
  }
}

class _CelebrationLayer extends StatelessWidget {
  const _CelebrationLayer({required this.anim, required this.newLevel});
  final Animation<double> anim;
  final int newLevel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti behind the card — lightweight CustomPainter so we
        // don't drag in a dependency for a one-shot effect.
        Positioned.fill(child: _ConfettiBurst(progress: anim)),
        Center(
          child: Padding(
            // Horizontal margin so the card can't touch/exceed the edges on a
            // narrow (≤320 dp) screen.
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ScaleTransition(
            scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
            child: Material(
              color: Colors.transparent,
              child: Container(
                // Was a fixed width: 300 — caps the same but SHRINKS below it on
                // narrow screens instead of overflowing.
                constraints: const BoxConstraints(maxWidth: 300),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withValues(alpha: 0.45),
                      blurRadius: 48,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎉',
                        style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 8),
                    Text('LEVEL UP!',
                        style: AppTextStyles.heading1.copyWith(
                            color: AppColors.purple, fontSize: 28)),
                    const SizedBox(height: 12),
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.purple, AppColors.purpleC],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.gold, width: 3),
                      ),
                      child: Center(
                        child: Text('$newLevel',
                            style: AppTextStyles.heading1.copyWith(
                                fontSize: 40, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("You're getting smarter! 🎓",
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.text1),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text('Reached Level $newLevel — keep going!',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.text2),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Keep going!'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
        ),
      ],
    );
  }
}

/// A burst of falling colored dots driven by the dialog's entry animation.
/// Cheap — no Tickers beyond the parent's existing one, ~28 particles.
class _ConfettiBurst extends StatelessWidget {
  const _ConfettiBurst({required this.progress});
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (_, __) => CustomPaint(
        painter: _ConfettiPainter(t: progress.value),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.t});
  final double t; // 0 → 1

  // Deterministic seed so the same crossing always paints the same burst.
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
      // Stagger particle starts so they don't all leave at once.
      final delay = rng.nextDouble() * 0.3;
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
