import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/adaptive_layout.dart';

/// Which mascot treatment to render.
enum MochiVariant {
  /// Neutral empty state ("nothing here yet").
  empty,

  /// Celebration — flanked by inward-facing 🎉 party-poppers.
  success,

  /// Apologetic/neutral Mochi. Never party marks (a celebrating mascot on a
  /// failure reads absurd). Uses the transparent asset so it composes on any
  /// surface colour.
  error,
}

/// One shared mascot placeholder for empty / success / error surfaces.
///
/// Replaces the old grey Material-icon placeholders with the Mochi mascot,
/// mirroring the shipped house pattern in [EmptyHomeState]: an
/// `Adaptive.width`-sized `Image.asset` centred with the copy below it.
///
/// Renders a `mainAxisSize.min` column and does NOT wrap itself in a `Center`
/// — callers keep their existing `Center` / `AdaptiveCenter` + padding wrapper,
/// so converting a surface is a one-widget swap that preserves its layout.
///
/// ```dart
/// const MochiPlaceholder(
///   variant: MochiVariant.empty,
///   title: 'No Mochis yet',
///   subtitle: 'Create a Mochi from the Home tab to see it here.',
/// )
/// ```
class MochiPlaceholder extends StatelessWidget {
  const MochiPlaceholder({
    super.key,
    this.variant = MochiVariant.empty,
    this.title,
    this.subtitle,
    this.action,
    this.titleStyle,
    this.subtitleColor,
  });

  final MochiVariant variant;

  /// Optional heading. When null (e.g. Surface #1, which already has its own
  /// heading below), only the mascot renders.
  final String? title;
  final String? subtitle;

  /// Optional CTA rendered below the copy (e.g. a `NoNotesCta`).
  final Widget? action;

  /// Overrides for surfaces with non-default text colours (e.g. white on a
  /// dark background).
  final TextStyle? titleStyle;
  final Color? subtitleColor;

  // Opaque mascot for empty/success on light surfaces — the exact asset the
  // shipped EmptyHomeState house pattern uses, so rendering matches. The
  // transparent base is reserved for the error variant, which may land on
  // varied surfaces.
  static const String _mochiAsset = 'assets/images/mochi.png';
  static const String _mochiNeutralAsset =
      'assets/images/mochi_base_transparent.png';

  @override
  Widget build(BuildContext context) {
    final size = Adaptive.width(context, 0.34, max: 140);
    final asset =
        variant == MochiVariant.error ? _mochiNeutralAsset : _mochiAsset;

    final mochi = Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    Widget mascot = mochi;
    if (variant == MochiVariant.success) {
      final popper = size * 0.28;
      // Decorative poppers do NOT scale with accessibility text size — they
      // stay proportional to the mascot so they never blow out the row width.
      final popperStyle = TextStyle(fontSize: popper);
      mascot = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mirror the left popper so it faces inward toward Mochi.
          Transform.scale(
            scaleX: -1,
            child: Text('🎉',
                style: popperStyle, textScaler: TextScaler.noScaling),
          ),
          const SizedBox(width: AppSpacing.xs),
          mochi,
          const SizedBox(width: AppSpacing.xs),
          Text('🎉', style: popperStyle, textScaler: TextScaler.noScaling),
        ],
      );
    }

    // Subtle one-shot scale-in entrance — implicit animation, no packages.
    mascot = TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: mascot,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mascot,
        if (title != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            title!,
            style: titleStyle ?? AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
        ],
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle!,
            style: AppTextStyles.body
                .copyWith(color: subtitleColor ?? AppColors.text2),
            textAlign: TextAlign.center,
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: AppSpacing.md),
          action!,
        ],
      ],
    );
  }
}
