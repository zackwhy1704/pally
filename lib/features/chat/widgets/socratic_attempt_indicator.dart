import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// Shows how many Socratic attempts have been made (pip indicators).
/// After [maxAttempts] attempts an escape hatch becomes available.
class SocraticAttemptIndicator extends StatelessWidget {
  const SocraticAttemptIndicator({
    super.key,
    required this.attempts,
    this.maxAttempts = 3,
  });

  final int attempts;
  final int maxAttempts;

  @override
  Widget build(BuildContext context) {
    if (attempts == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hints: ',
            style: AppTextStyles.caption.copyWith(color: AppColors.text3),
          ),
          ...List.generate(maxAttempts, (i) {
            final filled = i < attempts;
            final isLast = i == maxAttempts - 1;
            return Padding(
              padding: const EdgeInsets.only(right: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: filled
                      ? (isLast ? AppColors.coral : AppColors.purple)
                      : AppColors.outline,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          if (attempts >= maxAttempts) ...[
            const SizedBox(width: 6),
            Text(
              '— answer ready',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.coral,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
