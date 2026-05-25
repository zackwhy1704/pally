import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';

class OcrQualityIssue {
  const OcrQualityIssue({
    required this.label,
    required this.severity,
  });

  final String label;
  final QualityIssueSeverity severity;
}

enum QualityIssueSeverity { high, medium, low }

class OcrQualityWarning extends StatefulWidget {
  const OcrQualityWarning({
    super.key,
    required this.qualityScore,
    required this.issues,
    required this.previewImagePath,
    required this.onRetake,
    required this.onSendAnyway,
  });

  /// 0.0–1.0 quality score. Widget is shown when < 0.40.
  final double qualityScore;
  final List<OcrQualityIssue> issues;
  final String previewImagePath;
  final VoidCallback onRetake;
  final VoidCallback onSendAnyway;

  @override
  State<OcrQualityWarning> createState() => _OcrQualityWarningState();
}

class _OcrQualityWarningState extends State<OcrQualityWarning>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  late final AnimationController _barController;
  late final Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(_shakeController);

    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _barAnimation = Tween<double>(begin: 0, end: widget.qualityScore)
        .animate(CurvedAnimation(parent: _barController, curve: Curves.easeOut));

    _shakeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _barController.forward();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _barController.dispose();
    super.dispose();
  }

  Color get _scoreColor {
    if (widget.qualityScore >= 0.6) return AppColors.amber;
    if (widget.qualityScore >= 0.4) return AppColors.coral;
    return const Color(0xFFEF5350);
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
                    color: AppColors.coralL,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                      child: Text('⚠️', style: TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Photo quality is low',
                          style: AppTextStyles.title.copyWith(fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('Your tutor may misread some questions',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Photo preview with shake
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (_, child) => Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Image.asset(
                    widget.previewImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surf2,
                      child: const Center(
                          child: Text('📷',
                              style: TextStyle(fontSize: 40))),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Quality score bar
            Row(
              children: [
                Text('Quality score',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.text2)),
                const Spacer(),
                AnimatedBuilder(
                  animation: _barAnimation,
                  builder: (_, __) => Text(
                    '${(_barAnimation.value * 100).round()}%',
                    style: AppTextStyles.label.copyWith(
                        color: _scoreColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AnimatedBuilder(
                animation: _barAnimation,
                builder: (_, __) => LinearProgressIndicator(
                  value: _barAnimation.value,
                  backgroundColor: AppColors.outline,
                  valueColor: AlwaysStoppedAnimation(_scoreColor),
                  minHeight: 8,
                ),
              ),
            ),

            if (widget.issues.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Issues detected', style: AppTextStyles.label),
              const SizedBox(height: 8),
              ...widget.issues.map((issue) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _severityColor(issue.severity),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(issue.label,
                              style: AppTextStyles.bodySmall),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _severityColor(issue.severity)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            issue.severity.name.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: _severityColor(issue.severity),
                              fontWeight: FontWeight.w700,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            const SizedBox(height: AppSpacing.md),

            // Retake (primary)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.onRetake,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Retake photo 📸',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ),
            ),

            const SizedBox(height: 10),

            // Send anyway (secondary — low prominence)
            Center(
              child: GestureDetector(
                onTap: widget.onSendAnyway,
                child: Text(
                  'Send anyway',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.text3,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _severityColor(QualityIssueSeverity severity) => switch (severity) {
        QualityIssueSeverity.high => AppColors.coral,
        QualityIssueSeverity.medium => AppColors.amber,
        QualityIssueSeverity.low => AppColors.teal,
      };
}
