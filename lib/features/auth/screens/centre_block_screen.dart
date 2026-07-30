import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/adaptive_center.dart';

class CentreBlockScreen extends StatelessWidget {
  const CentreBlockScreen({super.key});

  static const _webLoginUrl = 'https://apalchi.com/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: AdaptiveCenter(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                const Text('🏫', style: TextStyle(fontSize: 64),
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppLocalizations.of(context).centreBlockTitle,
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppLocalizations.of(context).centreBlockBody,
                  style: AppTextStyles.body.copyWith(color: AppColors.text2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: () => launchUrl(
                    Uri.parse(_webLoginUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    AppLocalizations.of(context).centreBlockLoginWeb,
                    style: AppTextStyles.body.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => context.go('/auth/signin'),
                  child: Text(
                    AppLocalizations.of(context).centreBlockBackToSignIn,
                    style: AppTextStyles.body.copyWith(color: AppColors.text2),
                  ),
                ),
              ],
            ),
          ),
        ),
        );
  }
}
