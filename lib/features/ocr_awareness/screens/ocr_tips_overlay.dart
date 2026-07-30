import 'package:flutter/material.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';

const _kPrefKey = 'ocr_tips_shown_count';

class OcrTipsOverlay extends StatefulWidget {
  const OcrTipsOverlay({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  State<OcrTipsOverlay> createState() => _OcrTipsOverlayState();
}

class _OcrTipsOverlayState extends State<OcrTipsOverlay> {
  @override
  void initState() {
    super.initState();
    _incrementCount();
  }

  Future<void> _incrementCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_kPrefKey) ?? 0;
    await prefs.setInt(_kPrefKey, count + 1);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.0,
      maxChildSize: 0.65,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
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
                    color: AppColors.tealL,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                      child: Text('📷', style: TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.ocrPhotoTips,
                          style: AppTextStyles.title.copyWith(fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(l.ocrBestResults,
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.text3, size: 20),
                  onPressed: widget.onDismiss,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.outline),
            const SizedBox(height: AppSpacing.md),

            // Tips
            ..._tips(l).map((tip) => _TipRow(
                  icon: tip.icon,
                  title: tip.title,
                  subtitle: tip.subtitle,
                )),

            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.outline),
            const SizedBox(height: AppSpacing.sm),

            Text(l.ocrWhatReadsWell, style: AppTextStyles.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _readableContent(l)
                  .map((label) => _Chip(label: label, color: AppColors.teal))
                  .toList(),
            ),

            const SizedBox(height: AppSpacing.md),
            Text(l.ocrMightNeedFix, style: AppTextStyles.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _trickyContent(l)
                  .map((label) => _Chip(label: label, color: AppColors.amber))
                  .toList(),
            ),

            const SizedBox(height: AppSpacing.lg),

            FilledButton(
              onPressed: widget.onDismiss,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(l.ocrGotItTakePhoto,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow(
      {required this.icon, required this.title, required this.subtitle});

  final String icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.greenL,
              shape: BoxShape.circle,
            ),
            child: const Center(
                child: Text('✓',
                    style: TextStyle(
                        color: AppColors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(title,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: AppTextStyles.label.copyWith(color: color, fontSize: 10)),
    );
  }
}

class _TipData {
  const _TipData(this.icon, this.title, this.subtitle);
  final String icon;
  final String title;
  final String subtitle;
}

List<_TipData> _tips(AppLocalizations l) => [
      _TipData('💻', l.ocrTipDigitalTitle, l.ocrTipDigitalBody),
      _TipData('☀️', l.ocrTipLightingTitle, l.ocrTipLightingBody),
      _TipData('📐', l.ocrTipFlatTitle, l.ocrTipFlatBody),
      _TipData('🔍', l.ocrTipFillFrameTitle, l.ocrTipFillFrameBody),
      _TipData('📄', l.ocrTipOneTopicTitle, l.ocrTipOneTopicBody),
      _TipData('🔢', l.ocrTipMathTitle, l.ocrTipMathBody),
    ];

List<String> _readableContent(AppLocalizations l) => [
      l.ocrReadablePrinted,
      l.ocrReadableTyped,
      l.ocrReadableNumbers,
      l.ocrReadableMcq,
      l.ocrReadableFillBlank,
      l.ocrReadableShortParagraphs,
    ];

List<String> _trickyContent(AppLocalizations l) => [
      l.ocrTrickyHandwriting,
      l.ocrTrickyDiagrams,
      l.ocrTrickyGraphs,
      l.ocrTrickyMathSymbols,
      l.ocrTrickyChemFormulas,
      l.ocrTrickyTables,
    ];
