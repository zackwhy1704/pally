import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';

enum TeachingMode { teaching, direct }

extension TeachingModeX on TeachingMode {
  bool get isGuide => this == TeachingMode.teaching;
  String get label => isGuide ? 'Guide Me' : 'Just answer';
  String get emoji => isGuide ? '🧭' : '💡';
  String get apiValue => isGuide ? 'TEACHING' : 'DIRECT';
}

/// Segmented pill toggle: 🧭 Guide Me / 💡 Just answer.
///
/// Sizing is fully adaptive — no hardcoded width:
///   • If the parent provides bounded constraints (Expanded / Flexible /
///     ConstrainedBox), the toggle fills that space exactly.
///   • If the parent passes unbounded width (a plain Row), the toggle
///     self-sizes to 42 % of the logical screen width via MediaQuery,
///     so it scales proportionally on any device from compact phone to
///     tablet without a single hardcoded dp value.
///
/// The sliding indicator is computed from the actual available width
/// (availableWidth / 2), replacing the old FractionallySizedBox which
/// required a bounded parent and crashed with an assertion when the
/// parent Row passed infinite width.
class TeachingModeToggle extends StatelessWidget {
  const TeachingModeToggle({
    super.key,
    required this.mode,
    required this.onToggle,
    this.enabled = true,
  });

  final TeachingMode mode;
  final VoidCallback onToggle;
  final bool enabled;

  // Height matches Material segmented-control spec (design token, not a
  // layout hack — equivalent to specifying Button height).
  static const double _height = 40;

  @override
  Widget build(BuildContext context) {
    final isGuide = mode.isGuide;

    return LayoutBuilder(builder: (context, constraints) {
      // Honour parent-provided bounded width (Expanded, Flexible, etc.).
      // Fall back to 42 % of logical screen width when the parent Row
      // passes infinite width — percentage-based so it adapts to every
      // screen size, exactly like ConstraintLayout percent constraints.
      final screenWidth = MediaQuery.of(context).size.width;
      final toggleWidth = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : screenWidth * 0.42;

      // Half-width for the sliding selector — computed arithmetically
      // from the actual available space instead of FractionallySizedBox,
      // which required a bounded parent and threw a BoxConstraints
      // assertion on unbounded Row children.
      final selectorWidth = toggleWidth / 2;

      return SizedBox(
        width: toggleWidth,
        height: _height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surf2,
            borderRadius: BorderRadius.circular(_height / 2),
            border: Border.all(color: AppColors.outline),
          ),
          child: Stack(
            children: [
              // Sliding selection indicator
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment:
                    isGuide ? Alignment.centerLeft : Alignment.centerRight,
                child: SizedBox(
                  width: selectorWidth,
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isGuide ? AppColors.purple : AppColors.amber,
                      borderRadius:
                          BorderRadius.circular(_height / 2 - 3),
                    ),
                  ),
                ),
              ),
              // Labels — two equal segments, each Expanded
              Row(
                children: [
                  _Segment(
                    emoji: '🧭',
                    label: 'Guide Me',
                    selected: isGuide,
                    onTap: enabled && !isGuide ? onToggle : null,
                  ),
                  _Segment(
                    emoji: '💡',
                    label: 'Just answer',
                    selected: !isGuide,
                    onTap: enabled && isGuide ? onToggle : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: selected ? Colors.white : AppColors.text2,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
