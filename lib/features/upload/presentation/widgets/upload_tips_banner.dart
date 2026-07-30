import 'package:flutter/material.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// Pre-upload guidance, grounded in the REAL pipeline limits (25MB cap, compile
/// timeout on huge docs, scanned-PDF failure) and the vision-OCR failure modes
/// (Claude Haiku vision, not Tesseract — good at neat handwriting, weak on
/// cursive/glare/tiny/faint). Collapsible so it never dominates the screen.
class UploadTipsBanner extends StatefulWidget {
  const UploadTipsBanner({super.key});

  @override
  State<UploadTipsBanner> createState() => _UploadTipsBannerState();
}

class _UploadTipsBannerState extends State<UploadTipsBanner> {
  bool _expanded = false;

  // (emoji, tip) grouped by section. Content is conservative + accurate to the
  // audited limits — no fake claims (e.g. no invented page cap). Pure static UI
  // copy (no backend id), so built directly from AppLocalizations at render —
  // no id-keyed resolver needed, unlike the subject/character/module lists.
  List<(String, List<(String, String)>)> _sections(AppLocalizations l) => [
        (l.uploadTipSectionBefore, [
          ('📦', l.uploadTipMaxSize),
          ('📚', l.uploadTipBigFiles),
          ('📄', l.uploadTipPdfText),
        ]),
        (l.uploadTipSectionReadsWell(l.mascotName), [
          ('✅', l.uploadTipTypedText),
          ('✅', l.uploadTipNeatHandwriting),
        ]),
        (l.uploadTipSectionHardToRead, [
          ('✍️', l.uploadTipCursive),
          ('🔦', l.uploadTipGlare),
          ('🔍', l.uploadTipTinyText),
          ('🌗', l.uploadTipFaint),
          ('✂️', l.uploadTipCropped),
          ('📐', l.uploadTipCluttered),
        ]),
        (l.uploadTipSectionCheck, [
          ('👀', l.uploadTipGlanceCheck(l.mascotName)),
        ]),
      ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.amberL,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  color: AppColors.amber, size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l.uploadTipBanner,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.text1),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? l.uploadTipHide : l.uploadTipWhatReadsBest,
                  style: AppTextStyles.label.copyWith(color: AppColors.purple),
                ),
              ),
            ],
          ),
          if (_expanded)
            for (final section in _sections(l)) _section(section.$1, section.$2),
        ],
      ),
    );
  }

  Widget _section(String title, List<(String, String)> tips) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.label.copyWith(color: AppColors.text2)),
          const SizedBox(height: AppSpacing.xs),
          for (final t in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.$1, style: AppTextStyles.bodySmall),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(t.$2,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.text1)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
