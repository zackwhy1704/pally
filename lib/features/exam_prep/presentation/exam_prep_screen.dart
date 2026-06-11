import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/exam_prep/presentation/exam_prep_view_model.dart';
import 'package:pally/shared/models/exam_prep.dart';

class ExamPrepScreen extends ConsumerWidget {
  const ExamPrepScreen({super.key, required this.avatarId});
  final String avatarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examPrepAsync = ref.watch(examPrepViewModelProvider(avatarId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Exam Prep', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: examPrepAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.purple),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.coral),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Could not load exam prep data.',
                  style: AppTextStyles.body.copyWith(color: AppColors.text2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () => ref
                      .read(examPrepViewModelProvider(avatarId).notifier)
                      .refresh(),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.purple),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (examPrep) => _ExamPrepBody(
          avatarId: avatarId,
          examPrep: examPrep,
        ),
      ),
    );
  }
}

class _ExamPrepBody extends ConsumerWidget {
  const _ExamPrepBody({
    required this.avatarId,
    required this.examPrep,
  });

  final String avatarId;
  final ExamPrep examPrep;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final concepts = List<ExamConceptMastery>.from(examPrep.concepts);
    // Sort weakest-first
    concepts.sort((a, b) => a.mastery.compareTo(b.mastery));

    return RefreshIndicator(
      color: AppColors.purple,
      onRefresh: () =>
          ref.read(examPrepViewModelProvider(avatarId).notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Test date countdown card
          if (examPrep.testDate != null && examPrep.daysRemaining != null)
            _CountdownCard(
              testDate: examPrep.testDate!,
              daysRemaining: examPrep.daysRemaining!,
            ),

          // Daily target recommendation
          if (concepts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _DailyTargetBanner(dailyTarget: examPrep.dailyTarget),
          ],

          // Concept mastery list
          if (concepts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'CONCEPT MASTERY',
              style: AppTextStyles.label.copyWith(
                letterSpacing: 1.2,
                color: AppColors.text2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...concepts.map(
              (concept) => _ConceptMasteryCard(
                concept: concept,
                avatarId: avatarId,
              ),
            ),
          ],

          // Empty state
          if (concepts.isEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.school_rounded,
                      size: 48, color: AppColors.text3),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No exam prep data yet',
                    style: AppTextStyles.title,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Complete some modules first to see your concept mastery.',
                    style:
                        AppTextStyles.body.copyWith(color: AppColors.text2),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],

          SizedBox(
              height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({
    required this.testDate,
    required this.daysRemaining,
  });

  final String testDate;
  final int daysRemaining;

  @override
  Widget build(BuildContext context) {
    final isUrgent = daysRemaining <= 7;
    final color = isUrgent ? AppColors.coral : AppColors.purple;
    final bgColor = isUrgent ? AppColors.coralL : AppColors.purpleL;

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizing.avatarLg,
            height: AppSizing.avatarLg,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$daysRemaining',
                style: AppTextStyles.heading1.copyWith(
                  color: color,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'days until exam',
                  style: AppTextStyles.body.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  testDate,
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyTargetBanner extends StatelessWidget {
  const _DailyTargetBanner({required this.dailyTarget});
  final int dailyTarget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.tealL,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates_rounded,
              size: 20, color: AppColors.teal),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Study $dailyTarget module${dailyTarget == 1 ? '' : 's'}/day '
              'to finish by exam',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConceptMasteryCard extends ConsumerWidget {
  const _ConceptMasteryCard({
    required this.concept,
    required this.avatarId,
  });

  final ExamConceptMastery concept;
  final String avatarId;

  Color get _masteryColor {
    final pct = concept.mastery * 100;
    if (pct >= 70) return AppColors.green;
    if (pct >= 40) return AppColors.amber;
    return AppColors.coral;
  }

  String get _masteryIcon {
    final pct = concept.mastery * 100;
    if (pct >= 70) return '✓';
    if (pct >= 40) return '⚠';
    return '🔴';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pct = (concept.mastery * 100).round();
    final color = _masteryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    concept.concept,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$_masteryIcon $pct%',
                  style: AppTextStyles.label.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: concept.mastery.clamp(0.0, 1.0),
                minHeight: AppSizing.progressBarHeight,
                backgroundColor: AppColors.outline,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            if (concept.moduleTitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      concept.moduleTitle!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.text2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (concept.moduleId != null && concept.mastery < 0.7)
                    GestureDetector(
                      onTap: () async {
                        final ok = await ref
                            .read(examPrepViewModelProvider(avatarId).notifier)
                            .startRevision(concept.moduleId!);
                        if (ok && context.mounted) {
                          ModulePlayerRoute(
                            avatarId: avatarId,
                            moduleId: concept.moduleId!,
                          ).push(context);
                        } else if (!ok && context.mounted) {
                          PallyToast.error(context,
                              'Could not start revision. Try again.');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.purpleL,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Re-do',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
