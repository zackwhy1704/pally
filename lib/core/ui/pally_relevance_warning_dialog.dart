import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/pally_button.dart';
import 'package:pally/core/ui/pally_dialog.dart';

class PallyRelevanceWarningDialog extends StatelessWidget {
  const PallyRelevanceWarningDialog({
    super.key,
    required this.subject,
    this.reason,
    required this.onGoBack,
    required this.onAddAnyway,
  });

  final String subject;
  final String? reason;
  final VoidCallback onGoBack;
  final VoidCallback onAddAnyway;

  static Future<bool?> show({
    required BuildContext context,
    required String subject,
    String? reason,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: const Color(0x7A1F1733),
      builder: (_) => PallyRelevanceWarningDialog(
        subject: subject,
        reason: reason,
        onGoBack: () => Navigator.of(context).pop(false),
        onAddAnyway: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PallyDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.amberL,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.amber,
              size: 44,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Hmm, this might not fit!',
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            reason ??
                'This file doesn\'t seem to match "$subject". '
                    'Your tutor works best with notes from that subject.',
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          PallyDialog.buttonRow(
            secondary: PallyButton(
              label: 'Go Back',
              onPressed: onGoBack,
              variant: PallyButtonVariant.outlined,
              fullWidth: true,
            ),
            primary: PallyButton(
              label: 'Add Anyway',
              onPressed: onAddAnyway,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
