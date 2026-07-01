import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// Neutral, informational onboarding footer — Privacy · Terms · Support open the
/// public apalchi.com pages in the system browser. These are the same
/// informational links Settings already opens on iOS; deliberately NO
/// plans/pricing here (App Store anti-steering).
class OnboardingLegalFooter extends StatelessWidget {
  const OnboardingLegalFooter({super.key});

  static const _links = <(String, String)>[
    ('Privacy', 'https://apalchi.com/privacy'),
    ('Terms', 'https://apalchi.com/terms'),
    ('Support', 'https://apalchi.com/support'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _links.length; i++) ...[
            if (i > 0)
              Text(' · ',
                  style: AppTextStyles.caption.copyWith(color: AppColors.text3)),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(_links[i].$2),
                  mode: LaunchMode.externalApplication),
              child: Text(_links[i].$1,
                  style: AppTextStyles.caption.copyWith(color: AppColors.text2)),
            ),
          ],
        ],
      ),
    );
  }
}
