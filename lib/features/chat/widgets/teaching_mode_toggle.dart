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
/// Guide Me (TEACHING) — Mochi never hands over the answer, leads
/// the student to figure it out. Builds long-term retention.
/// Just answer (DIRECT) = worked solution, framed as "for checking your work."
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

  @override
  Widget build(BuildContext context) {
    final isGuide = mode.isGuide;

    // Width must be explicit: this widget lives inside a Row in _ChatAppBar
    // (a non-Expanded child), so the Row passes unbounded width constraints.
    // FractionallySizedBox(widthFactor: 0.5) requires bounded parent width —
    // without a fixed width here, 0.5 × ∞ throws a BoxConstraints assertion
    // and crashes the entire AppBar every time the chat screen opens.
    return Container(
      width: 164,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surf2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Stack(
        children: [
          // Sliding selection indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: isGuide ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isGuide ? AppColors.purple : AppColors.amber,
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
          // Labels row
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
    );
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
