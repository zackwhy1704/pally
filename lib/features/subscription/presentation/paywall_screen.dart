import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// "P1" Paywall — the friction moment when a free user hits a server-side
/// gate. Briefly explains the feature they want, lists what premium
/// unlocks, and routes to the plan picker.
class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key, this.feature});

  /// Server-supplied feature code (CREATE_TUTOR, UPLOAD_DOC, CHAT_DAILY,
  /// PARENT_DASHBOARD, CURRICULUM, EXTRA_FREEZE). Drives the headline.
  final String? feature;

  String get _headline => switch (feature) {
        'CREATE_TUTOR' => 'Want more Mochis?',
        'UPLOAD_DOC' => 'Need more uploads?',
        'CHAT_DAILY' => 'Out of chats for today',
        'PARENT_DASHBOARD' => 'Parent dashboard is premium',
        'CURRICULUM' => 'Curriculum journey is premium',
        'EXTRA_FREEZE' => 'Stack more streak freezes',
        _ => 'Unlock Pally Premium',
      };

  String get _subhead => switch (feature) {
        'CREATE_TUTOR' =>
            'Free users get 1 Mochi. Sign up for premium for unlimited Mochis '
                'so each subject gets its own Mochi. Or, level up to level 5 '
                'to unlock your next Mochi slot!',
        'UPLOAD_DOC' =>
            'You can upload 3 documents per Mochi on free. Premium has no '
                'upload cap — keep filling that brain.',
        'CHAT_DAILY' =>
            'Free chat resets tomorrow. Premium chats are unlimited so the '
                'Mochi never sleeps.',
        'PARENT_DASHBOARD' =>
            'Parents track progress, set goals, and read weekly reports.',
        'CURRICULUM' =>
            'Plan ahead with a syllabus-aware journey across every topic.',
        'EXTRA_FREEZE' =>
            'Premium lets you stack up to 3 streak freezes so a missed day '
                'never costs your streak.',
        _ =>
            'Get everything Pally has to offer — unlimited Mochis, family '
                'sharing, premium analytics.',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.text2),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/progress');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              if (feature == 'CREATE_TUTOR')
                Image.asset('assets/images/mochi.png',
                    width: 110, height: 110, fit: BoxFit.contain)
              else
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.purple, AppColors.purpleC],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.35),
                          blurRadius: 24),
                    ],
                  ),
                  child: const Center(
                      child: Text('⭐', style: TextStyle(fontSize: 44))),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(_headline,
                  style: AppTextStyles.heading1, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(_subhead,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.text2),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.lg),
              const _PremiumPerks(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.push('/subscription/plans'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('See plans'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/progress');
                  }
                },
                child: const Text('Maybe later'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumPerks extends StatelessWidget {
  const _PremiumPerks();

  @override
  Widget build(BuildContext context) {
    const perks = [
      ('🧠', 'Unlimited Mochis + uploads'),
      ('💬', 'Unlimited daily chats'),
      ('👨‍👩‍👧', 'Family sharing — up to 4 kids'),
      ('📊', 'Parent dashboard + weekly reports'),
      ('🔥', '3 streak freezes (up from 1)'),
    ];
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: perks
            .map((p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(p.$1, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(p.$2, style: AppTextStyles.body)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
