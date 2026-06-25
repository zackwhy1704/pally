import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/auth/screens/self_consent_view_model.dart';

/// C5 — 13–17 self-consent, consolidated into ONE informed agreement.
///
/// Still a real consent gate: the four plain-language disclosures stay VISIBLE
/// inline (not behind a "read terms" link), the "I'm 13 or older" age
/// affirmation stays (it's what distinguishes 13–17 self-consent from <13
/// parental consent), and tapping Agree still records the consent artifact via
/// `POST /api/v1/consent/self`. We only dropped the "30-second read" framing and
/// collapsed four full cards into one compact list — not the consent itself.
class SelfConsentScreen extends ConsumerStatefulWidget {
  const SelfConsentScreen({super.key});

  @override
  ConsumerState<SelfConsentScreen> createState() => _SelfConsentScreenState();
}

class _SelfConsentScreenState extends ConsumerState<SelfConsentScreen> {
  bool _agreed = false;

  // Plain-language disclosures, one concise line each. Kept inline + visible:
  // notes ownership · chat/quiz memory + parent visibility · never sold/trained
  // (Anthropic AI) · delete-anytime.
  static const _disclosures = [
    ('📝', 'Your notes & flashcards stay yours — delete them anytime.'),
    ('💬', 'Mochi remembers your chats & quizzes to get smarter — a linked parent can see them to keep you safe.'),
    ('🚫', "Never sold, never used to train AI. We use Anthropic's AI; your chats don't train AI models."),
    ('🗑️', 'Delete everything, anytime, in Settings → Delete account.'),
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
              Text('One quick agreement 🤝', style: AppTextStyles.heading1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "Here's how Mochi uses your stuff. Agree to start learning.",
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
              ),
              const SizedBox(height: AppSpacing.lg),

              // All four disclosures consolidated into one compact card.
              Container(
                padding: AppSpacing.card,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < _disclosures.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_disclosures[i].$1,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _disclosures[i].$2,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.text1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Age affirmation — load-bearing: distinguishes 13–17 self-consent.
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
                          color: _agreed ? AppColors.purple : AppColors.outline,
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
