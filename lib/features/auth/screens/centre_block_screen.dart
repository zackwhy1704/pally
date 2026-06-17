import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';

class CentreBlockScreen extends StatelessWidget {
  const CentreBlockScreen({super.key});

  static const _webLoginUrl = 'https://apalchi.com/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
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
                'This is a Centre account',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'The Apalchi app is for students only. '
                'Centre teachers and owners manage their classes at apalchi.com.',
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
                  'Log in at apalchi.com',
                  style: AppTextStyles.body.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.go('/auth/signin'),
                child: Text(
                  'Back to Sign In',
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
