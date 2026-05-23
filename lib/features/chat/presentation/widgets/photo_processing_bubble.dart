import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/shared/models/photo_question.dart';

class PhotoProcessingBubble extends StatefulWidget {
  const PhotoProcessingBubble({
    super.key,
    required this.questions,
  });

  final List<PhotoQuestion> questions;

  @override
  State<PhotoProcessingBubble> createState() => _PhotoProcessingBubbleState();
}

class _PhotoProcessingBubbleState extends State<PhotoProcessingBubble>
    with TickerProviderStateMixin {
  late final List<AnimationController> _dotControllers;

  static const List<Color> _progressColors = [
    AppColors.teal,
    AppColors.green,
    AppColors.purple,
    AppColors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _dotControllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + i * 150),
      )..repeat(reverse: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(
            left: AppSpacing.md, right: 60, bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: AppColors.purpleL,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hold on, I\'m reading your homework… 🔍',
              style:
                  AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            // Per-question progress bars
            ...widget.questions.asMap().entries.map((entry) {
              final i = entry.key;
              final q = entry.value;
              final color = _progressColors[i % _progressColors.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(
                        q.rawText,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(fontSize: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: i < 2 ? 1.0 : 0.6),
                        duration: Duration(milliseconds: 600 + i * 200),
                        builder: (ctx, val, _) => LinearProgressIndicator(
                          value: val,
                          backgroundColor: AppColors.outline,
                          color: color,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                          color: color, strokeWidth: 1.5),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),

            // Typing dots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => AnimatedBuilder(
                  animation: _dotControllers[i],
                  builder: (ctx, _) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(
                          alpha: 0.2 + _dotControllers[i].value * 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _dotControllers) {
      c.dispose();
    }
    super.dispose();
  }
}
