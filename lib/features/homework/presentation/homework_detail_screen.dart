import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/features/homework/presentation/homework_detail_view_model.dart';
import 'package:pally/shared/models/homework_submission.dart';

/// Student view of one homework submission. While the teacher reviews, shows a
/// friendly "in review" hint and NO feedback (the server withholds it). Once
/// released, shows the teacher's grade + feedback. Mirrors the assignment
/// answer-compare not-released → released UX.
class HomeworkDetailScreen extends ConsumerWidget {
  const HomeworkDetailScreen({
    super.key,
    required this.avatarId,
    required this.submissionId,
  });

  final String avatarId;
  final String submissionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync =
        ref.watch(homeworkDetailViewModelProvider(avatarId, submissionId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const BackButton(),
        title: detailAsync.whenOrNull(
              data: (d) => Text(d.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title),
            ) ??
            Text('Homework', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: detailAsync.when(
        loading: () => const PallyLoadingSpinner(),
        error: (e, _) => PallyErrorCard(
          message: PallyError.from(e).userMessage,
          onRetry: () => ref.invalidate(
              homeworkDetailViewModelProvider(avatarId, submissionId)),
        ),
        data: (s) => RefreshIndicator(
          color: AppColors.purple,
          onRefresh: () async => ref.invalidate(
              homeworkDetailViewModelProvider(avatarId, submissionId)),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
            children: [
              _StatusHint(submission: s),
              const SizedBox(height: AppSpacing.md),
              if (s.isReleased && s.hasFeedback) ...[
                _FeedbackCard(submission: s),
                const SizedBox(height: AppSpacing.md),
              ],
              _FilesCard(files: s.files),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusHint extends StatelessWidget {
  const _StatusHint({required this.submission});
  final HomeworkSubmission submission;

  @override
  Widget build(BuildContext context) {
    final (emoji, title, body, color, bg) = switch (submission.status) {
      'RELEASED' => (
          '✅',
          'Feedback ready',
          'Your teacher has reviewed your work — read their feedback below.',
          AppColors.green,
          AppColors.greenL,
        ),
      'RETURNED' => (
          '↩️',
          'Returned for another go',
          'Your teacher asked you to take another look and resubmit.',
          AppColors.coral,
          AppColors.coralL,
        ),
      _ => (
          '⏳',
          'In review',
          "Your teacher is reviewing your work. You'll see their feedback "
              'here once they share it.',
          AppColors.amberText,
          AppColors.amberL,
        ),
    };
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w800, color: color)),
                const SizedBox(height: 2),
                Text(body,
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

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.submission});
  final HomeworkSubmission submission;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              Text("Teacher's feedback",
                  style: AppTextStyles.label.copyWith(color: AppColors.text3)),
              const Spacer(),
              if (submission.hasGrade)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.purpleL,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    submission.teacherGrade!.trim(),
                    style: AppTextStyles.title.copyWith(
                        color: AppColors.purple, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            submission.teacherFeedback!.trim(),
            style: AppTextStyles.body.copyWith(color: AppColors.text1),
          ),
        ],
      ),
    );
  }
}

class _FilesCard extends StatelessWidget {
  const _FilesCard({required this.files});
  final List<HomeworkFile> files;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What you submitted',
              style: AppTextStyles.label.copyWith(color: AppColors.text3)),
          const SizedBox(height: AppSpacing.sm),
          ...files.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(
                      f.isPdf
                          ? Icons.picture_as_pdf_rounded
                          : Icons.image_rounded,
                      size: 18,
                      color: AppColors.text2,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        f.name,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.text1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
