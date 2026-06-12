import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/consent/data/consent_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Privacy page opened by the "Read more" link.
const _kPrivacyUrl = 'https://apalchi.com/privacy';

/// AI data-transfer disclosure gate.
///
/// Shown before the first upload/chat (and on a 403 `AI_CONSENT_REQUIRED`
/// from the backend). Explains, in plain Year-7-friendly language, that
/// uploaded notes are processed by overseas AI providers.
///
/// Two variants:
///  - **Standard** (default): a 13+ user can self-consent. Shows the
///    "I agree" / "Not now" buttons and records consent on agree. Returns
///    (via [Navigator.pop]) `true` when agreed, `false` when backed out.
///  - **Informational** ([informationOnly] = true): for an under-13 account,
///    the child sees the same plain-language disclosure as information only,
///    with a single "OK" dismiss and NO "I agree" — because a child can't
///    consent for themselves (the parent records consent in the parent app).
///    Always pops `false` (no consent recorded).
class AiDisclosureScreen extends ConsumerStatefulWidget {
  const AiDisclosureScreen({super.key, this.informationOnly = false});

  /// When true, render the under-13 informational variant: no "I agree"
  /// button, just an "OK" dismiss. Consent is never recorded from here.
  final bool informationOnly;

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

  void _dismissInfo() {
    appLog.d('[Consent] AI disclosure dismissed (informational)');
    Navigator.of(context).pop(false);
  }

  Future<void> _readMore() async {
    final uri = Uri.parse(_kPrivacyUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e, st) {
      appLog.e('[Consent] Could not open privacy page',
          error: e, stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.informationOnly;
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
                    Text('A quick note about AI', style: AppTextStyles.heading1),
                    const SizedBox(height: AppSpacing.sm),
                    // Year-7 reading level: short sentences, no legal jargon.
                    Text(
                      'Apalchi uses AI helpers to turn your notes into lessons. '
                      'Your notes are sent to two AI companies — Anthropic '
                      '(Claude) and Google (Gemini) — whose computers are '
                      'outside Singapore. They only use your notes to make '
                      'your study material.',
                      style:
                          AppTextStyles.body.copyWith(color: AppColors.text2),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      info
                          ? 'A grown-up looks after this choice for you.'
                          : 'OK to continue?',
                      style: AppTextStyles.body.copyWith(
                          color: AppColors.text1,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _ProviderCard(
                      emoji: '🧠',
                      name: 'Anthropic (Claude)',
                      detail:
                          'Makes your explanations, quizzes and chat replies.',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _ProviderCard(
                      emoji: '✨',
                      name: 'Google (Gemini)',
                      detail: 'Helps read and understand your notes.',
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
                              'These companies are outside Singapore. We only '
                              'send what we need to make your study material.',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.purple),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _readMore,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Read more',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
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
              child: info ? _buildInfoActions() : _buildConsentActions(),
            ),
          ],
        ),
      ),
    );
  }

  /// Under-13 informational variant — single "OK" dismiss, no consent.
  Widget _buildInfoActions() {
    return SizedBox(
      height: AppSizing.buttonHeight,
      child: FilledButton(
        onPressed: _dismissInfo,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.purple,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('OK'),
      ),
    );
  }

  /// 13+ self-consent variant — "I agree" records consent, "Not now" backs out.
  Widget _buildConsentActions() {
    return Column(
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
                : const Text('I agree'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: AppSizing.buttonHeightSm,
          child: TextButton(
            onPressed: _loading ? null : _notNow,
            child: Text('Not now',
                style:
                    AppTextStyles.body.copyWith(color: AppColors.text2)),
          ),
        ),
      ],
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
