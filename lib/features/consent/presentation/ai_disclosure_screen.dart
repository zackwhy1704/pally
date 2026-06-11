import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/consent/data/consent_service.dart';

/// AI data-transfer disclosure gate.
///
/// Shown before the first upload/chat (and on a 403 `AI_CONSENT_REQUIRED`
/// from the backend). Explains in plain language that uploaded content is
/// processed by overseas AI providers, and records consent on Agree.
///
/// Returns (via [Navigator.pop]) `true` when the user agreed and consent was
/// recorded, `false` when they backed out.
class AiDisclosureScreen extends ConsumerStatefulWidget {
  const AiDisclosureScreen({super.key});

  @override
  ConsumerState<AiDisclosureScreen> createState() => _AiDisclosureScreenState();
}

class _AiDisclosureScreenState extends ConsumerState<AiDisclosureScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _agree() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(consentServiceProvider).grantAiConsent();
      appLog.i('[Consent] AI disclosure accepted');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e, st) {
      appLog.e('[Consent] Failed to record AI consent',
          error: e, stackTrace: st);
      if (mounted) {
        setState(() {
          _loading = false;
          _error = PallyError.from(e).userMessage;
        });
      }
    }
  }

  void _notNow() {
    appLog.d('[Consent] AI disclosure declined');
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    const Center(
                      child: Text('🤖', style: TextStyle(fontSize: 48)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('A quick heads-up about AI',
                        style: AppTextStyles.heading1),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Apalchi uses AI to turn your notes into lessons. To do '
                      'this, your uploaded content is processed by Anthropic '
                      '(Claude) and Google (Gemini) — AI providers located '
                      'overseas. Your data is sent to them solely to generate '
                      'your study material. Tap Agree to continue.',
                      style: AppTextStyles.body.copyWith(color: AppColors.text2),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _ProviderCard(
                      emoji: '🧠',
                      name: 'Anthropic (Claude)',
                      detail:
                          'Generates explanations, quizzes and chat replies.',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _ProviderCard(
                      emoji: '✨',
                      name: 'Google (Gemini)',
                      detail: 'Helps read and understand your uploaded notes.',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.purpleL,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.public_rounded,
                              size: 14, color: AppColors.purple),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'These providers are located overseas. We only '
                              'send what we need to make your study material.',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.purple),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _error!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.coral),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: AppSizing.buttonHeight,
                    child: FilledButton(
                      onPressed: _loading ? null : _agree,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: AppSizing.checkboxSize,
                              height: AppSizing.checkboxSize,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Agree'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: AppSizing.buttonHeightSm,
                    child: TextButton(
                      onPressed: _loading ? null : _notNow,
                      child: Text('Not now',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.text2)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.emoji,
    required this.name,
    required this.detail,
  });

  final String emoji;
  final String name;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(name,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(detail,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.text2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
