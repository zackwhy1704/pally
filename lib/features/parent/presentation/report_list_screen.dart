import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/features/parent/presentation/weekly_report_view_model.dart';

class ReportListScreen extends ConsumerWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(weeklyReportListViewModelProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Weekly Reports', style: AppTextStyles.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref
                .read(weeklyReportListViewModelProvider.notifier)
                .refresh(),
          ),
        ],
      ),
      body: reportsAsync.when(
        loading: () => const PallyLoadingSpinner(),
        error: (e, _) => _EmptyState(
          message: e.toString().replaceAll('Exception:', '').trim(),
          onRetry: () => ref
              .read(weeklyReportListViewModelProvider.notifier)
              .refresh(),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return _EmptyState(
              message: 'No reports yet — they generate after a week of activity.',
              onRetry: () => ref
                  .read(weeklyReportListViewModelProvider.notifier)
                  .refresh(),
            );
          }
          return RefreshIndicator(
            color: AppColors.purple,
            onRefresh: () => ref
                .read(weeklyReportListViewModelProvider.notifier)
                .refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: reports.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) => _ReportTile(report: reports[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report});

  final WeeklyReportSummary report;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d');
    final range = '${fmt.format(report.startDate)} – '
        '${fmt.format(report.endDate)}';
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            ParentReportDetailRoute(weekId: report.weekId).push(context),
        child: Container(
          padding: AppSpacing.card,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.purpleL,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_view_week_rounded,
                    color: AppColors.purple, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.weekId,
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.text3)),
                    Text(range,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      '${report.sessions} session${report.sessions == 1 ? '' : 's'} · '
                      '${report.minutes} min · +${report.xpEarned} XP',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.text2),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.text2),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assessment_outlined,
                size: 56, color: AppColors.text3),
            const SizedBox(height: AppSpacing.md),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.text2)),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
