import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';

enum PallyButtonVariant { filled, outlined, ghost, destructive }

class PallyButton extends StatelessWidget {
  const PallyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PallyButtonVariant.filled,
    this.icon,
    this.loading = false,
    this.enabled = true,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PallyButtonVariant variant;
  final Widget? icon;
  final bool loading;
  final bool enabled;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveCallback = (enabled && !loading) ? onPressed : null;

    Widget child = loading
        ? const SizedBox(
            width: AppSizing.spinnerSm,
            height: AppSizing.spinnerSm,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );

    Widget button;
    switch (variant) {
      case PallyButtonVariant.filled:
        button = FilledButton(
          onPressed: effectiveCallback,
          child: child,
        );
      case PallyButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: effectiveCallback,
          child: child,
        );
      case PallyButtonVariant.ghost:
        button = TextButton(
          onPressed: effectiveCallback,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.purple,
            textStyle: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          child: child,
        );
      case PallyButtonVariant.destructive:
        button = FilledButton(
          onPressed: effectiveCallback,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.coral,
            foregroundColor: Colors.white,
          ),
          child: child,
        );
    }

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
