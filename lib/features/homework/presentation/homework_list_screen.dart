import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/features/homework/presentation/homework_list_view_model.dart';
import 'package:pally/shared/models/homework_submission.dart';

/// Student's homework hub for a centre class: a list of their own submissions
/// (with status) and a button to submit new work. Centre-only — the entry
/// point (an AppBar action on the class module list) is gated to centre
/// classes, and the route redirects a personal Mochi away.
class HomeworkListScreen extends ConsumerWidget {
  const HomeworkListScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(homeworkListViewModelProvider(avatarId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const BackButton(),
        title: Text('Homework', style: AppTextStyles.title),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Submit homework'),
        onPressed: () => HomeworkSubmitRoute(avatarId: avatarId)
            .push(context)
            .then((_) => ref
                .read(homeworkListViewModelProvider(avatarId).notifier)
                .refresh()),
      ),
      body: listAsync.when(
        loading: () => const PallyLoadingSpinner(),
        error: (e, _) => PallyErrorCard(
          message: PallyError.from(e).userMessage,
          onRetry: () =>
              ref.invalidate(homeworkListViewModelProvider(avatarId)),
        ),
        data: (submissions) => submissions.isEmpty
            ? const _EmptyBody()
            : RefreshIndicator(
                color: AppColors.purple,
                onRefresh: () async =>
                    ref.invalidate(homeworkListViewModelProvider(avatarId)),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md,
                      AppSpacing.md, AppSpacing.md, AppSpacing.xxl + AppSpacing.xl),
                  itemCount: submissions.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => _SubmissionCard(
                    avatarId: avatarId,
                    submission: submissions[i],
                  ),
                ),
              ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Scrollable so pull-to-refresh works and it never overflows at large
      // text scale.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.xxl),
        const Icon(Icons.assignment_outlined,
            size: 56, color: AppColors.purpleC),
        const SizedBox(height: AppSpacing.md),
        Text('No homework yet',
            style: AppTextStyles.title, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Submit a photo or PDF of your work and your teacher will send '
          'back feedback here.',
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({required this.avatarId, required this.submission});
  final String avatarId;
  final HomeworkSubmission submission;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HomeworkDetailRoute(
        avatarId: avatarId,
        submissionId: submission.id,
      ).push(context),
      child: Container(
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: submission.isReleased
                ? AppColors.green.withValues(alpha: 0.4)
                : AppColors.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    submission.title,
                    style: AppTextStyles.title.copyWith(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                HomeworkStatusBadge(status: submission.status),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                if (submission.subject != null &&
                    submission.subject!.trim().isNotEmpty) ...[
                  Flexible(
                    child: Text(
                      submission.subject!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.text2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                const Icon(Icons.attach_file_rounded,
                    size: 14, color: AppColors.text3),
                const SizedBox(width: 2),
                Text(
                  '${submission.files.length}',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.text3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Status pill shared by the homework list and detail screens.
class HomeworkStatusBadge extends StatelessWidget {
  const HomeworkStatusBadge({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      'RELEASED' => ('Feedback ready', AppColors.green, AppColors.greenL),
      'RETURNED' => ('Please redo', AppColors.coral, AppColors.coralL),
      _ => ('In review', AppColors.amberText, AppColors.amberL),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption
            .copyWith(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}
