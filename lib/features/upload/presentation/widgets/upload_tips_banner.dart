import 'package:flutter/material.dart';
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
  // audited limits — no fake claims (e.g. no invented page cap).
  static const _sections = <(String, List<(String, String)>)>[
    ('Before you upload', [
      ('📦', 'Files must be under 25 MB.'),
      ('📚', 'Big files (a whole book) can be slow or time out — upload a '
          'chapter or topic at a time.'),
      ('📄', "PDFs need selectable text. A scanned, image-only PDF can't be "
          'read — photograph the pages instead.'),
    ]),
    ('Mochi reads these well', [
      ('✅', 'Typed or printed text, clean PDFs, and screenshots.'),
      ('✅', 'Neat handwriting — clear, reasonably large, dark ink.'),
    ]),
    ('Type these instead — hard to read', [
      ('✍️', 'Cursive or messy handwriting.'),
      ('🔦', 'Glare, shadows, or a photo of a screen — shoot the page directly.'),
      ('🔍', 'Tiny text (footnotes, shrunk photocopies) — zoom in.'),
      ('🌗', 'Faint pencil or low-contrast pages — go over it in pen.'),
      ('✂️', 'Cropped edges — capture the whole page, flat and filling the frame.'),
      ('📐', 'Cluttered multi-column layouts — one clean column per photo.'),
    ]),
    ('One quick check', [
      ('👀', 'After a photo or handwriting, glance at what Mochi read — if '
          'something looks off, retake or type it.'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.lightbulb_outline_rounded,
                  color: AppColors.amber, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Tip: clear, typed or printed pages read best.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.text1),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? 'Hide' : 'What reads best?',
                  style: AppTextStyles.label.copyWith(color: AppColors.purple),
                ),
              ),
            ],
          ),
          if (_expanded)
            for (final section in _sections) _section(section.$1, section.$2),
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
