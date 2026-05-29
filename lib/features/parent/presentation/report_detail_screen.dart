import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/parent/presentation/weekly_report_view_model.dart';
import 'package:share_plus/share_plus.dart';

class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({super.key, required this.weekId});

  final String weekId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync =
        ref.watch(weeklyReportDetailViewModelProvider(weekId));
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Weekly Report', style: AppTextStyles.title),
        centerTitle: true,
        actions: [
          reportAsync.maybeWhen(
            data: (r) => IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () => _share(context, ref, r),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: reportAsync.when(
        loading: () => const PallyLoadingSpinner(),
        error: (e, _) => PallyErrorCard(
          message: PallyError.from(e).userMessage,
          onRetry: () =>
              ref.invalidate(weeklyReportDetailViewModelProvider(weekId)),
        ),
        data: (r) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderCard(report: r),
              const SizedBox(height: AppSpacing.md),
              _StatsRow(report: r),
              const SizedBox(height: AppSpacing.md),
              _DailyChart(minutes: r.dailyMinutes, startDate: r.startDate),
              if (r.subjects.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _SubjectsCard(subjects: r.subjects),
              ],
              if (r.weakAreas.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _WeakAreasCard(items: r.weakAreas),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _share(
      BuildContext context, WidgetRef ref, WeeklyReportDetail r) async {
    // Prefer the backend-generated share text (richer + includes
    // streak/badges). Fall back to a local string if the call fails so
    // the share sheet still opens.
    String text;
    String subject = 'Pally Weekly Report';
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get<Map<String, dynamic>>(
        '/api/v1/parent/reports/${r.weekId}/share-text',
      );
      final data = (res.data?['data'] is Map
              ? res.data!['data']
              : res.data) as Map<String, dynamic>;
      text = (data['text'] as String?) ?? '';
      subject = (data['subject'] as String?) ?? subject;
    } catch (e) {
      appLog.w('[Report] share-text failed: $e — using local fallback');
      final fmt = DateFormat('MMM d');
      final sb = StringBuffer()
        ..writeln('Pally weekly report (${fmt.format(r.startDate)} – '
            '${fmt.format(r.endDate)})')
        ..writeln()
        ..writeln('• ${r.sessions} session${r.sessions == 1 ? '' : 's'}')
        ..writeln('• ${r.minutes} min studied')
        ..writeln('• +${r.xpEarned} XP earned')
        ..writeln()
        ..writeln(r.narrative);
      text = sb.toString();
    }
    if (text.isEmpty) return;
    await Share.share(text, subject: subject);
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.report});
  final WeeklyReportDetail report;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d');
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.purpleL,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${fmt.format(report.startDate)} – ${fmt.format(report.endDate)}',
            style: AppTextStyles.label.copyWith(color: AppColors.purple),
          ),
          const SizedBox(height: 4),
          Text(report.headline, style: AppTextStyles.heading1),
          const SizedBox(height: AppSpacing.sm),
          Text(report.narrative,
              style: AppTextStyles.body.copyWith(color: AppColors.text2)),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.report});
  final WeeklyReportDetail report;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _StatTile(
                label: 'Sessions',
                value: '${report.sessions}',
                icon: Icons.event_available_rounded,
                color: AppColors.purple)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
            child: _StatTile(
                label: 'Minutes',
                value: '${report.minutes}',
                icon: Icons.timer_rounded,
                color: AppColors.teal)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
            child: _StatTile(
                label: 'XP',
                value: '+${report.xpEarned}',
                icon: Icons.star_rounded,
                color: AppColors.amber)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.heading1
                  .copyWith(color: AppColors.text1, fontSize: 22)),
          Text(label,
              style: AppTextStyles.caption.copyWith(color: AppColors.text2)),
        ],
      ),
    );
  }
}

class _DailyChart extends StatelessWidget {
  const _DailyChart({required this.minutes, required this.startDate});

  final List<int> minutes;
  final DateTime startDate;

  @override
  Widget build(BuildContext context) {
    final maxMin = minutes.isEmpty
        ? 1
        : minutes.reduce((a, b) => a > b ? a : b).clamp(1, 99999);
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily minutes', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 96,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(minutes.length, (i) {
                final v = minutes[i];
                final frac = maxMin > 0 ? v / maxMin : 0.0;
                final day = startDate.add(Duration(days: i));
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('$v',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.text3)),
                      const SizedBox(height: 2),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 70 * frac + 4,
                        decoration: BoxDecoration(
                          color: AppColors.purple,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(DateFormat('E').format(day).substring(0, 1),
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.text2)),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectsCard extends StatelessWidget {
  const _SubjectsCard({required this.subjects});
  final List<SubjectMastery> subjects;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subject mastery', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          for (final s in subjects) ...[
            Row(
              children: [
                Expanded(
                  child: Text(s.subject,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body),
                ),
                const SizedBox(width: 8),
                Text('${(s.mastery * 100).round()}%',
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: s.mastery.clamp(0.0, 1.0),
                backgroundColor: AppColors.outline,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.purple),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _WeakAreasCard extends StatelessWidget {
  const _WeakAreasCard({required this.items});
  final List<WeakArea> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.coralL,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.coral, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.coral, size: 20),
              SizedBox(width: 8),
              Text('Needs attention',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.coral)),
            ],
          ),
          const SizedBox(height: 8),
          for (final w in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('· ${w.topic}',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall),
                  ),
                  Text('${(w.mastery * 100).round()}%',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.coral)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
