import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';

const _kSeenKey = 'trial_welcome_seen_v1';

/// PR1 — shown once after a new account's first launch.
class TrialWelcomeScreen {
  static Future<void> maybeShow(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kSeenKey) ?? false) return;
    await prefs.setBool(_kSeenKey, true);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TrialWelcomeSheet(),
    );
  }
}

class _TrialWelcomeSheet extends StatelessWidget {
  const _TrialWelcomeSheet();

  static const _perks = [
    ('🐾', 'Unlimited Mochis', 'One Mochi for every subject you study'),
    ('💬', 'Unlimited chat', 'Ask anything, any time — no daily limit'),
    ('📚', 'Full flashcards & quizzes', 'Every feature, zero restrictions'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Handle
          Container(
            width: 44, height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Image.asset('assets/images/mochi.png', width: 90, height: 90),
          const SizedBox(height: AppSpacing.md),
          const Text('🎁 Premium is on us\nfor 7 days!',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.25,
              ),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            'No card needed. We\'ll remind you before it ends.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ..._perks.map((p) {
            final (emoji, title, sub) = p;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          Text(sub,
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.7))),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 20),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Start exploring! 🚀',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/subscription/plans');
            },
            child: Text('Subscribe now from S\$14.90/mo',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13)),
          ),
          ],
        ),
      ),
    );
  }
}
