import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';

const _kBannerKey = 'ocr_guide_banner_dismissed';

class OcrWhatCanReadScreen extends StatefulWidget {
  const OcrWhatCanReadScreen({super.key});

  @override
  State<OcrWhatCanReadScreen> createState() => _OcrWhatCanReadScreenState();
}

class _OcrWhatCanReadScreenState extends State<OcrWhatCanReadScreen>
    with TickerProviderStateMixin {
  bool _bannerDismissed = false;
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _loadBannerState();

    _controllers = List.generate(
      _kItems.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _animations = _controllers.asMap().entries.map((e) {
      return Tween<double>(begin: 0, end: _kItems[e.key].accuracy / 100.0)
          .animate(CurvedAnimation(parent: e.value, curve: Curves.easeOut));
    }).toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  Future<void> _loadBannerState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bannerDismissed = prefs.getBool(_kBannerKey) ?? false;
    });
  }

  Future<void> _dismissBanner() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBannerKey, true);
    setState(() => _bannerDismissed = true);
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text1),
          onPressed: () => context.pop(),
        ),
        title: Text('What can Pally read?',
            style: AppTextStyles.title.copyWith(fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
        children: [
          // Amber info banner
          if (!_bannerDismissed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.amberL,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.amber.withValues(alpha: 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡',
                        style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Accuracy varies by photo quality. Clear, well-lit photos give the best results.',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.text2),
                      ),
                    ),
                    GestureDetector(
                      onTap: _dismissBanner,
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.text3, size: 16),
                    ),
                  ],
                ),
              ),
            ),

          Text('Accuracy guide',
              style:
                  AppTextStyles.label.copyWith(color: AppColors.text2)),
          const SizedBox(height: AppSpacing.sm),

          ..._kItems.asMap().entries.map((e) {
            final item = e.value;
            final anim = _animations[e.key];
            final color = _colorFor(item.accuracy);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(item.emoji,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item.name,
                              style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700)),
                        ),
                        AnimatedBuilder(
                          animation: anim,
                          builder: (_, __) => Text(
                            '${(anim.value * 100).round()}%',
                            style: AppTextStyles.label.copyWith(
                                color: color,
                                fontWeight: FontWeight.w800,
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.note, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedBuilder(
                        animation: anim,
                        builder: (_, __) => LinearProgressIndicator(
                          value: anim.value,
                          backgroundColor: AppColors.outline,
                          valueColor: AlwaysStoppedAnimation(color),
                          minHeight: 7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _colorFor(int accuracy) {
    if (accuracy >= 85) return AppColors.green;
    if (accuracy >= 70) return AppColors.teal;
    if (accuracy >= 50) return AppColors.amber;
    return AppColors.coral;
  }
}

class _ReadabilityItem {
  const _ReadabilityItem(
      {required this.emoji,
      required this.name,
      required this.accuracy,
      required this.note});

  final String emoji;
  final String name;
  final int accuracy;
  final String note;
}

const _kItems = [
  _ReadabilityItem(
    emoji: '📝',
    name: 'Printed text',
    accuracy: 97,
    note: 'Clear printed questions — reads almost perfectly',
  ),
  _ReadabilityItem(
    emoji: '🔢',
    name: 'Numbers & simple maths',
    accuracy: 92,
    note: 'Digits and basic operators (+, -, ×, ÷) read well',
  ),
  _ReadabilityItem(
    emoji: '🅰️',
    name: 'Multiple choice labels',
    accuracy: 90,
    note: 'A. B. C. D. labels are reliably detected',
  ),
  _ReadabilityItem(
    emoji: '✏️',
    name: 'Neat handwriting',
    accuracy: 72,
    note: 'Clear block letters work; cursive is harder',
  ),
  _ReadabilityItem(
    emoji: '📐',
    name: 'Maths equations',
    accuracy: 65,
    note: 'Simple equations OK; complex fractions may need fixing',
  ),
  _ReadabilityItem(
    emoji: '📊',
    name: 'Diagrams & graphs',
    accuracy: 45,
    note: 'Labels may be read but visual content is not understood',
  ),
  _ReadabilityItem(
    emoji: '🧪',
    name: 'Chemical formulas',
    accuracy: 55,
    note: 'Subscripts and superscripts often need manual correction',
  ),
  _ReadabilityItem(
    emoji: '🔤',
    name: 'Cursive handwriting',
    accuracy: 40,
    note: 'Highly variable — type it manually for best results',
  ),
];
