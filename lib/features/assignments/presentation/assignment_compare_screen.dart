import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/features/assignments/presentation/assignment_detail_view_model.dart';
import 'package:pally/shared/models/assignment_detail.dart';

/// A2 — completed assignment answer-compare view.
///
/// When `answersReleased == true`, shows a stacked per-question compare: the
/// student's own answer, the model answer, and per-concept evaluation. When
/// answers are not yet released, shows a friendly "not released yet" hint and
/// NO model answer (the server omits it anyway).
class AssignmentCompareScreen extends ConsumerWidget {
  const AssignmentCompareScreen({
    super.key,
    required this.avatarId,
    required this.assignmentId,
  });

  final String avatarId;
  final String assignmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      assignmentDetailViewModelProvider(avatarId, assignmentId),
    );
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const BackButton(),
        title: detailAsync.whenOrNull(
              data: (d) => Text(d.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title),
            ) ??
            Text('Assignment', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: detailAsync.when(
        loading: () => const PallyLoadingSpinner(),
        error: (e, _) => PallyErrorCard(
          message: PallyError.from(e).userMessage,
          onRetry: () => ref.invalidate(
              assignmentDetailViewModelProvider(avatarId, assignmentId)),
        ),
        data: (detail) => RefreshIndicator(
          color: AppColors.purple,
          onRefresh: () async => ref.invalidate(
              assignmentDetailViewModelProvider(avatarId, assignmentId)),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
            children: [
              if (detail.personalized) ...[
                const _PickedForYouChip(),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (!detail.answersReleased)
                const _NotReleasedHint()
              else
                const _ReleasedHint(),
              const SizedBox(height: AppSpacing.md),
              if (detail.questions.isEmpty)
                _EmptyCompare(released: detail.answersReleased)
              else
                ...detail.questions.map((q) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _QuestionCompareCard(
                        question: q,
                        released: detail.answersReleased,
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Personalized affordance ──────────────────────────────────────────────────

class _PickedForYouChip extends StatelessWidget {
  const _PickedForYouChip();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.purpleL,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨', style: TextStyle(fontSize: 12)),
            const SizedBox(width: AppSpacing.xs),
            Text('Picked for you',
                style: AppTextStyles.label.copyWith(color: AppColors.purple)),
          ],
        ),
      ),
    );
  }
}

// ── Hint banners ─────────────────────────────────────────────────────────────

class _NotReleasedHint extends StatelessWidget {
  const _NotReleasedHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.amberL,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⏳', style: TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Answers not released yet',
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  "Your teacher hasn't shared the model answers. "
                  "You'll be able to compare here once they do.",
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.text2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReleasedHint extends StatelessWidget {
  const _ReleasedHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.tealL,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✅', style: TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Compare your answers with the model answers below.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.teal, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Per-question compare card ────────────────────────────────────────────────

class _QuestionCompareCard extends StatelessWidget {
  const _QuestionCompareCard({required this.question, required this.released});
  final AssignmentQuestion question;
  final bool released;

  @override
  Widget build(BuildContext context) {
    final mine = question.studentAnswer?.trim() ?? '';
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number + prompt
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.purpleL,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Q${question.index + 1}',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.purple,
                        fontWeight: FontWeight.w800)),
              ),
              if (question.prompt.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(question.prompt,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Student's own answer
          _AnswerBlock(
            label: 'Your answer',
            color: AppColors.purple,
            background: AppColors.purpleL,
            text: mine.isEmpty ? 'No answer recorded' : mine,
            muted: mine.isEmpty,
          ),

          // Model answer — only when the server actually sent it.
          if (released && question.hasModelAnswer) ...[
            const SizedBox(height: AppSpacing.sm),
            _AnswerBlock(
              label: 'Model answer',
              color: AppColors.green,
              background: AppColors.greenL,
              text: question.modelAnswer!.trim(),
              muted: false,
            ),
          ],

          // Per-concept evaluation
          if (question.concepts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Evaluation',
                style: AppTextStyles.label.copyWith(color: AppColors.text3)),
            const SizedBox(height: AppSpacing.xs),
            ...question.concepts.map((c) => _ConceptRow(eval: c)),
          ],
        ],
      ),
    );
  }
}

class _AnswerBlock extends StatelessWidget {
  const _AnswerBlock({
    required this.label,
    required this.color,
    required this.background,
    required this.text,
    required this.muted,
  });
  final String label;
  final Color color;
  final Color background;
  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                  color: color, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 2),
          Text(text,
              style: AppTextStyles.body.copyWith(
                color: muted ? AppColors.text3 : AppColors.text1,
                fontStyle: muted ? FontStyle.italic : FontStyle.normal,
              )),
        ],
      ),
    );
  }
}

class _ConceptRow extends StatelessWidget {
  const _ConceptRow({required this.eval});
  final ConceptEval eval;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (eval.passed) {
      true => (Icons.check_circle_rounded, AppColors.green),
      false => (Icons.cancel_rounded, AppColors.coral),
      null => (Icons.remove_circle_outline_rounded, AppColors.text3),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eval.concept.isNotEmpty)
                  Text(eval.concept,
                      style: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w700)),
                if (eval.feedback.isNotEmpty)
                  Text(eval.feedback,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.text2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCompare extends StatelessWidget {
  const _EmptyCompare({required this.released});
  final bool released;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Text(released ? '📝' : '⏳', style: const TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            released
                ? 'No answers to compare yet'
                : 'Come back after answers are released',
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
