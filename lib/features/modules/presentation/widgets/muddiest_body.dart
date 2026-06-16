import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/shared/models/learning_module.dart';

// ── MUDDIEST POINT (post-PROVE, pre-COMPLETE) ───────────────────────────────

/// One-tap "which part was hardest?" survey shown after PROVE. Tapping a
/// concept chip records the muddiest point and proceeds; "Skip" proceeds
/// without recording. No free text by design.
class MuddiestBody extends StatelessWidget {
  const MuddiestBody({
    super.key,
    required this.concepts,
    required this.onPick,
    required this.onSkip,
  });

  final List<ConceptMastery> concepts;
  final void Function(String conceptId) onPick;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    // De-duplicate + drop empty names so chips stay clean.
    final seen = <String>{};
    final labels = <String>[];
    for (final c in concepts) {
      final name = c.concept.trim();
      if (name.isEmpty || !seen.add(name)) continue;
      labels.add(name);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: MediaQuery.of(context).size.shortestSide * 0.28,
            height: MediaQuery.of(context).size.shortestSide * 0.28,
            decoration: const BoxDecoration(
              color: AppColors.purpleL,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.psychology_alt_rounded,
                  size: 44, color: AppColors.purple),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Which part was hardest?',
              style: AppTextStyles.heading1, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap the one that felt the muddiest. This helps your tutor know '
            'what to review next.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              for (final label in labels)
                MuddiestChip(label: label, onTap: () => onPick(label)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          TextButton(
            onPressed: onSkip,
            child: Text('Skip',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.text2,
                  fontWeight: FontWeight.w700,
                )),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }
}

class MuddiestChip extends StatelessWidget {
  const MuddiestChip({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.purpleC),
          ),
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(
              color: AppColors.purple,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
