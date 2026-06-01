import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';

const _kSeenKey = 'seen_mode_education_v1';

/// GM1 — "Two ways to learn 🎓" — shown once before the first chat.
/// Explains Guide Me vs Just Answer in the student's language.
class ModeEducationOverlay {
  static Future<void> maybeShow(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kSeenKey) ?? false) return;
    await prefs.setBool(_kSeenKey, true);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EducationSheet(),
    );
  }

  /// Re-openable from Settings without marking seen again.
  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EducationSheet(),
    );
  }
}

class _EducationSheet extends StatelessWidget {
  const _EducationSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Two ways to learn 🎓',
              style: TextStyle(
                fontFamily: 'Nunito', fontSize: 22, fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'You can switch any time with the toggle above the chat.',
              style: TextStyle(
                fontFamily: 'Nunito', fontSize: 13,
                color: Colors.white.withValues(alpha: 0.75),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Guide Me card
            Container(
              padding: AppSpacing.card,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🧭', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      const Text('Guide Me',
                          style: TextStyle(
                            fontFamily: 'Nunito', fontSize: 17,
                            fontWeight: FontWeight.w800, color: Colors.white,
                          )),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('RECOMMENDED',
                            style: TextStyle(
                              fontFamily: 'Nunito', fontSize: 9,
                              fontWeight: FontWeight.w800, color: Colors.white,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Mochi asks you guiding questions — you figure it out yourself. '
                    'What you discover, you remember.',
                    style: TextStyle(
                      fontFamily: 'Nunito', fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Just Answer card
            Container(
              padding: AppSpacing.card,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('💡', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 8),
                      Text('Just answer',
                          style: TextStyle(
                            fontFamily: 'Nunito', fontSize: 17,
                            fontWeight: FontWeight.w800, color: Colors.white,
                          )),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Mochi gives you the worked solution directly. '
                    'Great for checking your work — but you\'ll remember less.',
                    style: TextStyle(
                      fontFamily: 'Nunito', fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Default: Guide Me',
              style: TextStyle(
                fontFamily: 'Nunito', fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Got it — let\'s learn!',
                  style: TextStyle(
                    fontFamily: 'Nunito', fontWeight: FontWeight.w800,
                    fontSize: 16,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
