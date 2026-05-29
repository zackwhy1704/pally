import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/features/library/presentation/library_view_model.dart';
import 'package:pally/features/study_plan/presentation/study_plan_view_model.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/study_plan_item.dart';

class StudyPlanScreen extends ConsumerWidget {
  const StudyPlanScreen({super.key, this.avatarId = ''});

  final String avatarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(studyPlanViewModelProvider);
    final notifier = ref.read(studyPlanViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Study Plan', style: AppTextStyles.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: notifier.refresh,
          ),
        ],
      ),
      body: planAsync.when(
        loading: () => const PallyLoadingSpinner(),
        error: (e, _) => PallyErrorCard(
          message: PallyError.from(e).userMessage,
          onRetry: notifier.refresh,
        ),
        data: (items) {
          final today = DateTime.now();
          final todayItems = items
              .where((i) =>
                  i.scheduledDate != null &&
                  _isSameDay(i.scheduledDate!, today))
              .toList();
          final upcomingItems = items
              .where((i) =>
                  i.scheduledDate == null ||
                  i.scheduledDate!.isAfter(today) &&
                      !_isSameDay(i.scheduledDate!, today))
              .toList();

          return RefreshIndicator(
            color: AppColors.purple,
            onRefresh: notifier.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TutorSpeechBubble(),
                  const SizedBox(height: AppSpacing.lg),
                  if (todayItems.isNotEmpty) ...[
                    Text("Today's Tasks", style: AppTextStyles.title),
                    const SizedBox(height: AppSpacing.sm),
                    ...todayItems.map((item) => _TaskTile(
                          item: item,
                          onStart: () => _handleStart(context, item),
                          onMarkDone: () => notifier.markDone(item.id),
                        )),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (upcomingItems.isNotEmpty) ...[
                    Text('Coming Up', style: AppTextStyles.title),
                    const SizedBox(height: AppSpacing.sm),
                    ...upcomingItems.map((item) => _UpcomingTile(item: item)),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _TestCountdownCard(avatarId: avatarId),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleStart(BuildContext context, StudyPlanItem item) {
    final aid = item.avatarId.isNotEmpty ? item.avatarId : 'all';
    if (item.type == StudyPlanItemType.quiz) {
      context.go('/avatar/$aid/quiz');
    } else if (item.type == StudyPlanItemType.flashcard) {
      context.go('/avatar/$aid/flashcards');
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _TutorSpeechBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: const BoxDecoration(
        color: AppColors.purpleL,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.purple,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Here's your plan for today! 📅",
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Complete all tasks to keep your streak going and earn bonus stars!',
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

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.item,
    required this.onStart,
    required this.onMarkDone,
  });

  final StudyPlanItem item;
  final VoidCallback onStart;
  final VoidCallback onMarkDone;

  Color get _typeColor {
    switch (item.type) {
      case StudyPlanItemType.quiz:
        return AppColors.amber;
      case StudyPlanItemType.flashcard:
        return AppColors.teal;
      case StudyPlanItemType.reading:
        return AppColors.purple;
      case StudyPlanItemType.practice:
        return AppColors.coral;
    }
  }

  IconData get _typeIcon {
    switch (item.type) {
      case StudyPlanItemType.quiz:
        return Icons.bolt_rounded;
      case StudyPlanItemType.flashcard:
        return Icons.style_rounded;
      case StudyPlanItemType.reading:
        return Icons.menu_book_rounded;
      case StudyPlanItemType.practice:
        return Icons.fitness_center_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: item.isDone ? AppColors.greenL : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isDone
              ? AppColors.green.withValues(alpha: 0.4)
              : AppColors.outline,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_typeIcon, color: _typeColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              item.title,
              style: AppTextStyles.body.copyWith(
                decoration: item.isDone ? TextDecoration.lineThrough : null,
                color: item.isDone ? AppColors.text3 : AppColors.text1,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (item.isDone)
            const Icon(Icons.check_circle_rounded,
                color: AppColors.green, size: 24)
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onMarkDone,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.greenL,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.green.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'Done',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: onStart,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.purpleL,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.purple.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'Start',
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
      ),
    );
  }
}

class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({required this.item});

  final StudyPlanItem item;

  @override
  Widget build(BuildContext context) {
    final dateLabel = item.scheduledDate != null
        ? _formatDate(item.scheduledDate!)
        : 'Upcoming';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surf2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dateLabel,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.text2,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(item.title, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dayAfter = DateTime(now.year, now.month, now.day + 2);

    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    } else if (date.year == dayAfter.year &&
        date.month == dayAfter.month &&
        date.day == dayAfter.day) {
      return 'In 2 days';
    }
    return DateFormat('MMM d').format(date);
  }
}

class _TestCountdownCard extends ConsumerWidget {
  const _TestCountdownCard({required this.avatarId});

  final String avatarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarsAsync = ref.watch(libraryViewModelProvider);
    final Avatar? avatar = avatarsAsync.maybeWhen(
      data: (list) => list.where((a) => a.id == avatarId).firstOrNull,
      orElse: () => null,
    );
    final testDate = avatar?.testDate;

    if (testDate == null) {
      return _NoTestDateCard(avatarId: avatarId);
    }
    final daysLeft = testDate.difference(DateTime.now()).inDays;
    final subject = avatar?.subject ?? '';

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.text1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.isEmpty ? 'Upcoming Test' : '$subject Test',
                  style: AppTextStyles.body.copyWith(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  daysLeft <= 0
                      ? 'Today'
                      : daysLeft == 1
                          ? '1 day left'
                          : '$daysLeft days left',
                  style: AppTextStyles.title.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            constraints: const BoxConstraints(maxWidth: 100),
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              DateFormat('MMM d').format(testDate),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(color: AppColors.coral),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoTestDateCard extends StatelessWidget {
  const _NoTestDateCard({required this.avatarId});

  final String avatarId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surf2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_note_rounded,
              color: AppColors.text2, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Set a test date in Settings to see a countdown here.',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
            ),
          ),
        ],
      ),
    );
  }
}

