import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/features/ocr_awareness/utils/confidence_utils.dart';

class OcrConfidenceItem {
  const OcrConfidenceItem({
    required this.text,
    required this.confidence,
    this.detectedType = 'text',
  });

  final String text;
  final double confidence;
  final String detectedType;
}

class OcrConfidencePreview extends StatefulWidget {
  const OcrConfidencePreview({
    super.key,
    required this.items,
    required this.onFixManually,
    required this.onSendAnyway,
  });

  final List<OcrConfidenceItem> items;
  final VoidCallback onFixManually;
  final VoidCallback onSendAnyway;

  static bool shouldShow(List<OcrConfidenceItem> items) =>
      items.any((i) => i.confidence < 0.85);

  @override
  State<OcrConfidencePreview> createState() => _OcrConfidencePreviewState();
}

class _OcrConfidencePreviewState extends State<OcrConfidencePreview>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.items.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _animations = _controllers.asMap().entries.map((e) {
      return Tween<double>(begin: 0, end: widget.items[e.key].confidence)
          .animate(CurvedAnimation(parent: e.value, curve: Curves.easeOut));
    }).toList();

    // Staggered start: 100ms per item
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.amberL,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                      child: Text('🔍', style: TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reading confidence',
                          style: AppTextStyles.title.copyWith(fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('How well your tutor can read each question',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.outline),
            const SizedBox(height: AppSpacing.sm),

            // Items
            ...widget.items.asMap().entries.map((e) {
              final item = e.value;
              final anim = _animations[e.key];
              final color = ConfidenceUtils.colorFor(item.confidence);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Q${e.key + 1}: ${item.text}',
                            style: AppTextStyles.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedBuilder(
                          animation: anim,
                          builder: (_, __) => Text(
                            ConfidenceUtils.badgeText(anim.value),
                            style: AppTextStyles.label.copyWith(color: color),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedBuilder(
                        animation: anim,
                        builder: (_, __) => CustomPaint(
                          size: const Size(double.infinity, 8),
                          painter: _ConfidenceBarPainter(
                            value: anim.value,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: AppSpacing.sm),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onFixManually,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.purple,
                      side: const BorderSide(color: AppColors.purple),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Fix text manually',
                        style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: widget.onSendAnyway,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Send anyway',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceBarPainter extends CustomPainter {
  const _ConfidenceBarPainter({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = AppColors.outline
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final width = size.width * math.max(0, math.min(1, value));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, size.height), fgPaint);
  }

  @override
  bool shouldRepaint(_ConfidenceBarPainter old) =>
      old.value != value || old.color != color;
}
