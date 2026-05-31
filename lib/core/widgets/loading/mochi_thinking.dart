import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/widgets/loading/mochi_tips.dart';

/// Pattern C — Mochi + animated dots + rotating tip for AI waits (2–6s).
/// Shows one tip immediately; rotates to a second after 4s so longer waits
/// stay interesting without forcing the user to read a wall of text.
class MochiThinking extends StatefulWidget {
  const MochiThinking({
    super.key,
    this.label = 'Mochi is thinking…',
  });

  /// Short label above the dots (e.g. "Solving your question…").
  final String label;

  @override
  State<MochiThinking> createState() => _MochiThinkingState();
}

class _MochiThinkingState extends State<MochiThinking>
    with TickerProviderStateMixin {
  late final AnimationController _dotCtrl;
  late final AnimationController _tipFade;
  late String _tip;
  Timer? _rotateTimer;

  @override
  void initState() {
    super.initState();
    _tip = randomMochiTip();

    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _tipFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );

    // Rotate to a second tip after 4s
    _rotateTimer = Timer(const Duration(seconds: 4), _rotateTip);
  }

  void _rotateTip() {
    if (!mounted) return;
    _tipFade.reverse().then((_) {
      if (!mounted) return;
      setState(() => _tip = nextMochiTip(_tip));
      _tipFade.forward();
    });
  }

  @override
  void dispose() {
    _dotCtrl.dispose();
    _tipFade.dispose();
    _rotateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/mochi.png', width: 80, height: 80),
          const SizedBox(height: AppSpacing.md),
          Text(widget.label,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          _AnimatedDots(controller: _dotCtrl),
          const SizedBox(height: AppSpacing.md),
          FadeTransition(
            opacity: _tipFade,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.purpleL,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _tip,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.purple),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDots extends StatelessWidget {
  const _AnimatedDots({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final raw = (controller.value - delay).remainder(1.0);
            final t = raw < 0 ? raw + 1.0 : raw;
            final scale = 0.6 + 0.4 * Curves.easeInOut.transform(
              t < 0.5 ? t * 2 : (1 - t) * 2,
            );
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.purple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
