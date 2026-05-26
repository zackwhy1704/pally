import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/features/photo_question/models/ocr_confidence_result.dart';
import 'package:pally/features/photo_question/screens/photo_review_screen.dart';

class OcrConfidencePreviewScreen extends StatefulWidget {
  const OcrConfidencePreviewScreen({
    super.key,
    required this.result,
    required this.avatarId,
    required this.detectedTexts,
  });

  final OcrConfidenceResult result;
  final String avatarId;
  final List<String> detectedTexts;

  @override
  State<OcrConfidencePreviewScreen> createState() =>
      _OcrConfidencePreviewScreenState();
}

class _OcrConfidencePreviewScreenState
    extends State<OcrConfidencePreviewScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _barControllers;
  late final List<Animation<double>> _barAnimations;

  @override
  void initState() {
    super.initState();
    _barControllers = List.generate(
      widget.result.items.length,
      (_) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500)),
    );
    _barAnimations = _barControllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeOutCubic);
    }).toList();

    // Stagger the bar animations
    for (int i = 0; i < _barControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) _barControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _barControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Color _colorFor(double conf) {
    if (conf >= 0.85) return AppColors.green;
    if (conf >= 0.50) return AppColors.amber;
    return AppColors.coral;
  }

  String _badgeLabel(double conf) {
    if (conf >= 0.85) return 'Great! ✓';
    if (conf >= 0.50) return 'OK-ish';
    return 'Tricky ⚠️';
  }

  void _sendAnyway() {
    context.pop(); // pop confidence preview
    // Caller (PhotoPreviewScreen) will handle sending
  }

  void _fixManually() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PhotoReviewScreen(
          photoFile: widget.result.photoFile,
          detectedTexts: widget.detectedTexts,
          avatarId: widget.avatarId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final overall = result.overallConfidence;
    final items = result.items;

    // Counts per band for segmented bar
    final highCount = items.where((i) => i.confidence >= 0.85).length;
    final midCount =
        items.where((i) => i.confidence >= 0.50 && i.confidence < 0.85).length;
    final lowCount = items.where((i) => i.confidence < 0.50).length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 58,
              color: Colors.black.withValues(alpha: 0.6),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      "Zap's Reading Report",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Nunito'),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Thumbnail + overall score card
                  _ThumbnailCard(
                      photoFile: result.photoFile,
                      overallConfidence: overall),

                  const SizedBox(height: AppSpacing.md),

                  // Section title
                  const Text(
                    "Here's what Zap found in your photo:",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Nunito'),
                  ),

                  const SizedBox(height: 12),

                  // Segmented bar
                  if (items.isNotEmpty)
                    _SegmentedBar(
                      high: highCount,
                      mid: midCount,
                      low: lowCount,
                      total: items.length,
                    ),

                  const SizedBox(height: 8),

                  // Legend
                  const Row(
                    children: [
                      _LegendDot(
                          color: AppColors.green, label: 'High (>85%)'),
                      SizedBox(width: 12),
                      _LegendDot(
                          color: AppColors.amber, label: 'Tricky (50–85%)'),
                      SizedBox(width: 12),
                      _LegendDot(
                          color: AppColors.coral, label: 'Risky (<50%)'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Per question:',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Nunito'),
                  ),

                  const SizedBox(height: 8),

                  // Per-item cards
                  ...items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    final color = _colorFor(item.confidence);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ItemCard(
                        item: item,
                        color: color,
                        badgeLabel: _badgeLabel(item.confidence),
                        barAnimation: _barAnimations[i],
                      ),
                    );
                  }),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),

            // Bottom buttons
            _BottomButtons(
              onFixManually: _fixManually,
              onSendAnyway: _sendAnyway,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Thumbnail + score card ────────────────────────────────────────────────────

class _ThumbnailCard extends StatelessWidget {
  const _ThumbnailCard({
    required this.photoFile,
    required this.overallConfidence,
  });

  final dynamic photoFile;
  final double overallConfidence;

  @override
  Widget build(BuildContext context) {
    final pct = (overallConfidence * 100).round();
    final color = overallConfidence >= 0.85
        ? AppColors.green
        : overallConfidence >= 0.50
            ? AppColors.amber
            : AppColors.coral;

    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Photo (55%)
          Expanded(
            flex: 55,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.file(
                photoFile,
                fit: BoxFit.cover,
                height: 180,
              ),
            ),
          ),
          // Score display (45%)
          Expanded(
            flex: 45,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: color.withValues(alpha: 0.4), width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$pct%',
                          style: TextStyle(
                              color: color,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Nunito'),
                        ),
                        Text(
                          'overall',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 9,
                              fontFamily: 'Nunito'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'confidence',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 9,
                        fontFamily: 'Nunito'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Segmented confidence bar ──────────────────────────────────────────────────

class _SegmentedBar extends StatelessWidget {
  const _SegmentedBar({
    required this.high,
    required this.mid,
    required this.low,
    required this.total,
  });

  final int high;
  final int mid;
  final int low;
  final int total;

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        final segments = [
          (w * high / total, AppColors.green),
          (w * mid / total, AppColors.amber),
          (w * low / total, AppColors.coral),
        ].where((s) => s.$1 > 0).toList();

        return ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Row(
            children: segments.map((s) {
              return Container(width: s.$1, height: 10, color: s.$2);
            }).toList(),
          ),
        );
      },
    );
  }
}

// ── Legend dot ────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 8,
              fontFamily: 'Nunito'),
        ),
      ],
    );
  }
}

// ── Per-item card ─────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.color,
    required this.badgeLabel,
    required this.barAnimation,
  });

  final OcrItemResult item;
  final Color color;
  final String badgeLabel;
  final Animation<double> barAnimation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Q circle
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    item.questionLabel,
                    style: TextStyle(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Nunito'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Type + pct
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.detectedType,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Nunito'),
                  ),
                  Text(
                    '${(item.confidence * 100).round()}%',
                    style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Nunito'),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Animated progress bar
              Expanded(
                child: AnimatedBuilder(
                  animation: barAnimation,
                  builder: (_, __) {
                    return Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: item.confidence * barAnimation.value,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(11),
                  border:
                      Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                      color: color,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito'),
                ),
              ),
            ],
          ),
          if (item.warningNote != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 34),
              child: Text(
                item.warningNote!,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 8,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Nunito'),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Bottom buttons ────────────────────────────────────────────────────────────

class _BottomButtons extends StatelessWidget {
  const _BottomButtons({
    required this.onFixManually,
    required this.onSendAnyway,
  });

  final VoidCallback onFixManually;
  final VoidCallback onSendAnyway;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        border:
            Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onFixManually,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                '✏️  Fix text manually',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: onSendAnyway,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.25)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Send anyway (Zap will do its best)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '💡 Better quality photos = more accurate answers',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 9,
                fontFamily: 'Nunito'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
