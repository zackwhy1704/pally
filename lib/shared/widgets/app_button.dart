import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// Variant of [AppButton].
enum AppButtonVariant { primary, secondary, text }

/// Single-source-of-truth button widget.
///
/// Enforces:
/// - 44×44 minimum tap target (WCAG 2.5.5).
/// - Design-token colours only — no hardcoded hex.
/// - Built-in `isLoading` spinner that disables taps.
/// - Optional haptic feedback on each press.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.haptic = true,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool enabled;
  final Widget? icon;
  final bool haptic;
  final bool fullWidth;

  bool get _interactive => enabled && !isLoading && onPressed != null;

  Color get _bgColor => switch (variant) {
        AppButtonVariant.primary => _interactive
            ? AppColors.purple
            : AppColors.outline,
        AppButtonVariant.secondary => AppColors.purpleL,
        AppButtonVariant.text => Colors.transparent,
      };

  Color get _fgColor => switch (variant) {
        AppButtonVariant.primary =>
            _interactive ? Colors.white : AppColors.text3,
        AppButtonVariant.secondary => AppColors.purple,
        AppButtonVariant.text => AppColors.purple,
      };

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            width: AppSizing.spinnerSm,
            height: AppSizing.spinnerSm,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _fgColor,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                      data: IconThemeData(color: _fgColor, size: AppSizing.icon18),
                      child: icon!),
                  const SizedBox(width: 6),
                  Text(label,
                      style: AppTextStyles.body.copyWith(
                          color: _fgColor, fontWeight: FontWeight.w700)),
                ],
              )
            : Text(label,
                style: AppTextStyles.body.copyWith(
                    color: _fgColor, fontWeight: FontWeight.w700));

    void handleTap() {
      if (!_interactive) return;
      if (haptic) HapticFeedback.lightImpact();
      onPressed!();
    }

    final button = ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: AppSizing.touchTarget,
        minHeight: AppSizing.touchTarget,
      ),
      child: Material(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _interactive ? handleTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Center(child: child),
          ),
        ),
      ),
    );

    return fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
