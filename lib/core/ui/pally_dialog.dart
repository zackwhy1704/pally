import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';

/// Standard Pally dialog wrapper.
///
/// Always applies:
/// - `insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24)`
///   (Flutter's `Dialog` default is 40px per side which causes overflow on
///    narrow phones — see CLAUDE.md Rule 10)
/// - Rounded corners (28px)
/// - Internal padding (20px)
///
/// Use this instead of raw `Dialog()` to prevent overflow. For dialogs with
/// title + content + actions, prefer `AlertDialog` (uses `OverflowBar`).
class PallyDialog extends StatelessWidget {
  const PallyDialog({
    super.key,
    required this.child,
    this.insetPadding =
        const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    this.borderRadius = 28,
    this.contentPadding = const EdgeInsets.all(20),
    this.backgroundColor = AppColors.surface,
  });

  final Widget child;
  final EdgeInsets insetPadding;
  final double borderRadius;
  final EdgeInsets contentPadding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      insetPadding: insetPadding,
      child: Padding(
        padding: contentPadding,
        child: child,
      ),
    );
  }

  /// Builds a Row of 2 buttons that stacks vertically on narrow screens.
  /// [primary] is the right/bottom button (filled), [secondary] is left/top
  /// (outlined).
  static Widget buttonRow({
    required Widget primary,
    required Widget secondary,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 280) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              secondary,
              const SizedBox(height: AppSpacing.sm),
              primary,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: secondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: primary),
          ],
        );
      },
    );
  }
}
