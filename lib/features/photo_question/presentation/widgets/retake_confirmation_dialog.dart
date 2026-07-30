import 'package:flutter/material.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';

enum RetakeChoice { keepPhoto, retake, gallery }

class RetakeConfirmationDialog extends StatelessWidget {
  const RetakeConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),

            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.amberL,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('📷', style: TextStyle(fontSize: 26)),
              ),
            ),

            SizedBox(height: 16),

            Text(
              l.photoRetakeConfirm,
              style: AppTextStyles.title,
            ),
            SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l.photoRetakeBody,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 20),

            // Divider
            Divider(color: AppColors.outline, height: 1),

            // Keep Photo
            _DialogOption(
              label: l.photoKeepPhoto,
              emoji: '✅',
              description: 'Continue with the current scan',
              color: AppColors.teal,
              onTap: () => Navigator.of(context).pop(RetakeChoice.keepPhoto),
            ),

            Divider(color: AppColors.outline, height: 1),

            // Retake
            _DialogOption(
              label: l.photoRetake,
              emoji: '📸',
              description: 'Take a new photo with your camera',
              color: AppColors.purple,
              onTap: () => Navigator.of(context).pop(RetakeChoice.retake),
            ),

            Divider(color: AppColors.outline, height: 1),

            // Gallery
            _DialogOption(
              label: l.photoChooseGallery,
              emoji: '🖼️',
              description: 'Pick an existing photo',
              color: AppColors.amber,
              onTap: () => Navigator.of(context).pop(RetakeChoice.gallery),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DialogOption extends StatelessWidget {
  const _DialogOption({
    required this.label,
    required this.emoji,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.text3,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.text3,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
