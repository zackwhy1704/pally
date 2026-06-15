import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/auth/screens/self_consent_view_model.dart';

/// C5 — "Before you start" (13–17 self-consent)
/// Child-readable disclosure cards + single checkbox. Withdrawal as easy
/// as giving consent (one-tap delete in Settings).
class SelfConsentScreen extends ConsumerStatefulWidget {
  const SelfConsentScreen({super.key});

  @override
  ConsumerState<SelfConsentScreen> createState() => _SelfConsentScreenState();
}

class _SelfConsentScreenState extends ConsumerState<SelfConsentScreen> {
  bool _agreed = false;

  static const _disclosures = [
    ('📝', 'Your notes stay yours',
        'We keep notes and flashcards you upload to power your Mochi. You can delete them anytime.'),
    ('💬', 'We remember chats & quizzes',
        'Your conversations and quiz results help Mochi get smarter. A linked parent can see these to keep you safe.'),
    ('🚫', 'Never sold, never trained on',
        "Your data is never sold. We use Anthropic's AI — your chats aren't used to train AI models."),
    ('🗑️', 'Delete everything, anytime',
        'You can delete all your data in Settings → Delete account. No questions asked.'),
  ];

  Future<void> _agree() async {
    await ref.read(selfConsentViewModelProvider.notifier).submitConsent();
    if (mounted) context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(selfConsentViewModelProvider).isLoading;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text('Before you start 📋',
                  style: AppTextStyles.heading1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Quick read — 30 seconds, we promise.',
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
              ),
              const SizedBox(height: AppSpacing.lg),

              ..._disclosures.map((d) {
                final (emoji, title, body) = d;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Container(
                    padding: AppSpacing.card,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: AppTextStyles.body
                                      .copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(body,
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.text2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: AppSpacing.md),

              // Agreement checkbox
              GestureDetector(
                onTap: () => setState(() => _agreed = !_agreed),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: AppSizing.checkboxSize,
                      height: AppSizing.checkboxSize,
                      decoration: BoxDecoration(
                        color: _agreed ? AppColors.purple : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color:
                              _agreed ? AppColors.purple : AppColors.outline,
                          width: 2,
                        ),
                      ),
                      child: _agreed
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14)
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        "I'm 13 or older and I agree to the above",
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                height: AppSizing.buttonHeight,
                child: FilledButton(
                  onPressed: (_agreed && !isLoading) ? _agree : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: AppSizing.checkboxSize,
                          height: AppSizing.checkboxSize,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Agree & start learning →'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
