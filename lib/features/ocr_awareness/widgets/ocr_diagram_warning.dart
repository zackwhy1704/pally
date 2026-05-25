import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/ocr_awareness/utils/confidence_utils.dart';

/// Injected into the chat message list after an OCR answer set.
/// Shows Card A (amber diagram warning) and/or Card B (purple symbol caveat).
class OcrDiagramWarning extends StatelessWidget {
  const OcrDiagramWarning({
    super.key,
    required this.detectedTypes,
    required this.onChipTap,
  });

  /// Types detected in the photo, e.g. ['diagram', 'equation']
  final List<String> detectedTypes;

  /// Called with pre-fill text when user taps a suggestion chip.
  final void Function(String prefill) onChipTap;

  bool get _hasDiagram => detectedTypes.any((t) =>
      t.toLowerCase() == 'diagram' ||
      t.toLowerCase() == 'graph' ||
      t.toLowerCase() == 'chart');

  bool get _hasSymbol => detectedTypes.any((t) =>
      t.toLowerCase() == 'formula' ||
      t.toLowerCase() == 'equation' ||
      t.toLowerCase() == 'symbol');

  @override
  Widget build(BuildContext context) {
    if (!_hasDiagram && !_hasSymbol) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasDiagram) _WarningCard(
            color: AppColors.amber,
            bgColor: AppColors.amberL,
            icon: '📊',
            title: 'Diagram detected',
            body: ConfidenceUtils.warningNote('diagram'),
            chips: const ['Describe the diagram', 'What does the graph show?'],
            onChipTap: onChipTap,
          ),
          if (_hasDiagram && _hasSymbol) const SizedBox(height: 8),
          if (_hasSymbol) _WarningCard(
            color: AppColors.purple,
            bgColor: AppColors.purpleL,
            icon: '∑',
            title: 'Maths symbols detected',
            body: ConfidenceUtils.warningNote('symbol'),
            chips: const ['Fix the equation', 'Retype the formula'],
            onChipTap: onChipTap,
          ),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.title,
    required this.body,
    required this.chips,
    required this.onChipTap,
  });

  final Color color;
  final Color bgColor;
  final String icon;
  final String title;
  final String body;
  final List<String> chips;
  final void Function(String) onChipTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: TextStyle(fontSize: 16, color: color,
                  fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Text(title,
                  style: AppTextStyles.label
                      .copyWith(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text(body,
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.text2, fontSize: 11)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: chips
                .map((c) => GestureDetector(
                      onTap: () => onChipTap(c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: color.withValues(alpha: 0.4)),
                        ),
                        child: Text(c,
                            style: AppTextStyles.caption
                                .copyWith(color: color, fontSize: 10)),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
