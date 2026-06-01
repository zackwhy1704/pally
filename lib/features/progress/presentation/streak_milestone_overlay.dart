import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// Streak-milestone celebration. Same shape as LevelUpOverlay so the two
/// feel like a family. Self-dismisses after 4s.
class StreakMilestoneOverlay {
  StreakMilestoneOverlay._();

  static const Duration autoDismiss = Duration(seconds: 4);

  static Future<void> show(BuildContext context, int milestone) async {
    HapticFeedback.heavyImpact();
    Timer? closer;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Streak Milestone',
      barrierColor: const Color(0xBB1F1733),
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, __, ___) {
        closer ??= Timer(autoDismiss, () {
          if (Navigator.of(ctx, rootNavigator: true).canPop()) {
            Navigator.of(ctx, rootNavigator: true).pop();
          }
        });
        return _Layer(anim: anim, milestone: milestone);
      },
    );
    closer?.cancel();
  }
}

class _Layer extends StatelessWidget {
  const _Layer({required this.anim, required this.milestone});
  final Animation<double> anim;
  final int milestone;

  String get _subtitle => switch (milestone) {
        3 => 'Three days in a row — habit forming!',
        7 => 'A whole week! Week Warrior unlocked 🏅',
        14 => 'Two weeks. You\'re on fire.',
        30 => 'Thirty days. Legendary 👑',
        60 => 'Sixty days — that\'s elite focus.',
        100 => 'Triple digits. Unreal 🚀',
        365 => 'A whole year. Take a bow.',
        _ => 'Keep that streak burning!',
      };

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _FlameBurst(progress: anim)),
        Center(
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: (MediaQuery.of(context).size.width * 0.85).clamp(0.0, 340.0),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coral.withValues(alpha: 0.45),
                      blurRadius: 48,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 8),
                    Text('$milestone-DAY STREAK!',
                        style: AppTextStyles.heading1.copyWith(
                            color: AppColors.coral, fontSize: 24)),
                    const SizedBox(height: 12),
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.coral, AppColors.amber],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 3),
                      ),
                      child: Center(
                        child: Text('$milestone',
                            style: AppTextStyles.heading1.copyWith(
                                fontSize: 40, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(_subtitle,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.text1),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Keep it lit!'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FlameBurst extends StatelessWidget {
  const _FlameBurst({required this.progress});
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (_, __) => CustomPaint(painter: _FlamePainter(t: progress.value)),
    );
  }
}

class _FlamePainter extends CustomPainter {
  _FlamePainter({required this.t});
  final double t;

  static const int _seed = 0xF1A3E;
  static const List<Color> _palette = [
    AppColors.coral,
    AppColors.amber,
    AppColors.gold,
    AppColors.pink,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(_seed);
    const count = 32;
    for (var i = 0; i < count; i++) {
      final col = _palette[i % _palette.length];
      final startX = rng.nextDouble() * size.width;
      final drift = (rng.nextDouble() - 0.5) * 90;
      final riseHeight = size.height * (0.4 + rng.nextDouble() * 0.6);
      final delay = rng.nextDouble() * 0.3;
      final localT = ((t - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      final x = startX + drift * localT;
      // Flames rise, so start near the bottom and go up.
      final y = size.height + 16 - riseHeight * localT;
      final radius = 3.5 + rng.nextDouble() * 3.5;
      final fade = (1.0 - localT).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = col.withValues(alpha: 0.9 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FlamePainter old) => old.t != t;
}
