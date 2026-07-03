import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/confetti_burst.dart';

/// One-shot celebration shown the moment a child's parental consent is approved
/// — fired from the home shell on the awaiting→approved transition, so it looks
/// identical whether the unlock arrived via push or a resume/launch reconcile.
/// Matches the LevelUpOverlay visual language (showGeneralDialog + confetti).
class ConsentApprovedOverlay {
  ConsentApprovedOverlay._();

  static Future<void> show(BuildContext context) async {
    HapticFeedback.heavyImpact();
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Approved',
      barrierColor: const Color(0xBB1F1733),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, __, ___) => _CelebrationLayer(anim: anim),
    );
  }
}

class _CelebrationLayer extends StatelessWidget {
  const _CelebrationLayer({required this.anim});
  final Animation<double> anim;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: ConfettiBurst(progress: anim)),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
              child: FadeTransition(
                opacity: anim,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.40),
                          blurRadius: 48,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Mochi is the hero — a little sparkle arc above it.
                        const Text('✨', style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Image.asset(
                          'assets/images/base.png',
                          width: 132,
                          height: 132,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "You're all set! 🎉",
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.text1,
                            fontSize: 22,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your grown-up said yes — your account is ready. '
                          "Let's start learning with Mochi!",
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.text2),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => Navigator.of(context,
                                    rootNavigator: true)
                                .pop(),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.purple,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text("Let's go!",
                                style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
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
