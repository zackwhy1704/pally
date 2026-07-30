import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Consent gate sheet — shown instead of a raw 403 error when a PENDING
/// account attempts a gated action.
///
/// The API client (which has no BuildContext and never will) passes only the
/// typed [reason] CODE from the backend; every user-facing string resolves
/// HERE at render time from AppLocalizations — the PR-G3 layering rule. The
/// reason→feature-title switch is a label-localizer-style resolver: one switch
/// on the canonical code, the ARB holds the per-locale strings.
class ConsentGateSheet extends StatelessWidget {
  const ConsentGateSheet({super.key, required this.reason, required this.onRemind});
  final String reason;

  /// Opens the working resend affordance. Replaces the old navigation to the
  /// never-registered `/consent/waiting` route, which dead-ended on the error
  /// screen — the exact failure this consent UX exists to kill.
  final VoidCallback onRemind;

  String _title(AppLocalizations l10n) => switch (reason) {
        'UPLOAD' => l10n.consentGateFeatureUpload,
        'CREATE_TUTOR' => l10n.consentGateFeatureCreateTutor(l10n.mascotName),
        'SHARE_NOTE' => l10n.consentGateFeatureShareNote,
        'PERSIST_CHAT' => l10n.consentGateFeaturePersistChat,
        'EARN_XP' => l10n.consentGateFeatureEarnXp,
        _ => l10n.consentGateFeatureGeneric,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: AppSizing.handleBarWidth,
                height: AppSizing.handleBarHeight,
                decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('⏳', style: TextStyle(fontSize: 40)),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.consentGateAlmostThere,
                style: AppTextStyles.heading1.copyWith(fontSize: 20)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.consentGateBody(_title(l10n)),
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRemind();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(l10n.consentGateRemind),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.consentPendingGotIt,
                  style: AppTextStyles.body.copyWith(color: AppColors.text2)),
            ),
          ],
        ),
      ),
    );
  }
}
