import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/shared/widgets/app_button.dart';

/// The single consistent error surface across the app.
///
/// Shows an icon + message and, when [onRetry] is provided, an
/// [AppButton] "Try again" that routes through the standard haptic/style.
/// Screens must never roll their own error UI — always delegate here.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.action,
  });

  final String message;
  final VoidCallback? onRetry;

  /// Optional widget shown below the message in place of the retry button.
  /// Use this for slot-locked errors or other cases where "Try again" is
  /// not the right recovery path. When [action] is supplied, the default
  /// retry button is hidden.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.text3),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ] else if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Try again',
                onPressed: onRetry,
                variant: AppButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
