import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/confetti_burst.dart';

/// Full-screen celebration overlay shown once when the user crosses a level
/// threshold. Caller is responsible for showing it exactly once per crossing
/// (typically by clearing the levelledUp flag after dismissal).
///
/// Self-dismisses after [autoDismiss] (default 4s) so quick level-ups
/// during a fast quiz session don't pile up on each other.
class LevelUpOverlay {
  LevelUpOverlay._();

  static const Duration autoDismiss = Duration(seconds: 4);

  static Future<void> show(
    BuildContext context,
    int newLevel, {
    String? rewardLabel,
  }) async {
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
        return _CelebrationLayer(
          anim: anim, newLevel: newLevel, rewardLabel: rewardLabel);
      },
    );
    closer?.cancel();
  }
}

class _CelebrationLayer extends StatelessWidget {
  const _CelebrationLayer({
    required this.anim,
    required this.newLevel,
    this.rewardLabel,
  });
  final Animation<double> anim;
  final int newLevel;

  /// Already locale-resolved server-side (e.g. "New Mochi colour" /
  /// "全新小伴配色") — rendered verbatim, same as nextUnlockLabel on the
  /// progress screen and reward.label on the level-roadmap screen. Null
  /// when this crossing has no reward tier.
  final String? rewardLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Stack(
      children: [
        // Confetti behind the card — lightweight CustomPainter so we
        // don't drag in a dependency for a one-shot effect.
        Positioned.fill(child: ConfettiBurst(progress: anim)),
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
                    Text(l.levelUpTitle,
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
                    Text(l.levelUpSmarter,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.text1),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text(l.levelUpReached(newLevel),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.text2),
                        textAlign: TextAlign.center),
                    if (rewardLabel != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.goldL,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🎁', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                rewardLabel!,
                                style: AppTextStyles.label
                                    .copyWith(color: AppColors.amber),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                      child: Text(l.levelUpKeepGoing),
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

