import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';

class PallyErrorCard extends StatelessWidget {
  const PallyErrorCard({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizing.iconContainer,
              height: AppSizing.iconContainer,
              decoration: const BoxDecoration(
                color: AppColors.coralL,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.coral,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Something went wrong', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retryLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
