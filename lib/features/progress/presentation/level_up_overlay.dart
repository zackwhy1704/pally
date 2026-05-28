import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// Full-screen celebration overlay shown once when the user crosses a level
/// threshold. Caller is responsible for showing it exactly once per crossing
/// (typically by clearing the levelledUp flag after dismissal).
class LevelUpOverlay {
  LevelUpOverlay._();

  static Future<void> show(BuildContext context, int newLevel) async {
    HapticFeedback.heavyImpact();
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Level Up',
      barrierColor: const Color(0xBB1F1733),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, __, ___) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withValues(alpha: 0.4),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text('LEVEL UP!',
                        style: AppTextStyles.heading1.copyWith(
                            color: AppColors.purple, fontSize: 28)),
                    const SizedBox(height: 12),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.purpleL,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.purple, width: 3),
                      ),
                      child: Center(
                        child: Text('$newLevel',
                            style: AppTextStyles.heading1.copyWith(
                                fontSize: 36, color: AppColors.purple)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('You reached Level $newLevel!',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.text2),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text('Keep learning to unlock more!',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.text3),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Awesome!'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
