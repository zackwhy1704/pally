import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// Blocking "please update" screen shown when the running app version is below the
/// backend's minimum supported version (CA-16). A dead end — back is disabled and
/// the only action is to update.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  // The web get-the-app page redirects to the correct App Store / Play Store link.
  static final Uri _storeUrl = Uri.parse('https://apalchi.com/get-the-app');

  Future<void> _openStore() async {
    if (await canLaunchUrl(_storeUrl)) {
      await launchUrl(_storeUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/mochi.png', width: 120, height: 120),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Time to update!',
                      style: AppTextStyles.heading1, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'A newer version of Apalchi is ready with important improvements. '
                    'Please update to keep learning.',
                    style: AppTextStyles.body.copyWith(color: AppColors.text2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _openStore,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Update now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
