import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/features/parent/presentation/assign_revision_sheet.dart';
import 'package:pally/features/parent/presentation/award_stars_sheet.dart';
import 'package:pally/features/parent/presentation/child_dashboard_view_model.dart';
import 'package:pally/features/parent/presentation/weekly_goal_sheet.dart';

/// Drills down into a single child's progress from the parent home screen.
class ChildDetailScreen extends ConsumerWidget {
  const ChildDetailScreen({super.key, required this.childId});
  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(childDashboardProvider(childId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text(
          dashAsync.valueOrNull?.childName ?? 'Child',
          style: AppTextStyles.title,
        ),
        centerTitle: true,
      ),
      body: dashAsync.when(
        loading: () => const PallyLoadingSpinner(),
        error: (e, _) => _ErrorView(
          error: 'Could not load data.',
          onRetry: () => ref.invalidate(childDashboardProvider(childId)),
        ),
        data: (dash) => RefreshIndicator(
          color: AppColors.purple,
          onRefresh: () =>
              ref.refresh(childDashboardProvider(childId).future),
          child: _buildContent(context, dash),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ChildDashboard dash) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _StatsRow(
          sessions: dash.sessionsThisWeek,
          minutes: dash.minutesThisWeek,
          xp: dash.xpThisWeek,
          streak: dash.streakDays,
        ),
        const SizedBox(height: AppSpacing.md),

        if (dash.subjects.isNotEmpty) ...[
          _SectionCard(
            title: 'Subject mastery',
            child: Column(
              children: dash.subjects.map((s) {
                final name = (s['subject'] as String?) ?? '';
                final mastery = ((s['mastery'] as num?) ?? 0).toDouble();
                return _MasteryBar(label: name, value: mastery);
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        if (dash.weakAreas.isNotEmpty) ...[
          _SectionCard(
            title: 'Weak concepts',
            child: Column(
              children: dash.weakAreas.take(5).map((w) {
                final topic = (w['topic'] as String?) ?? '';
                final mastery = ((w['mastery'] as num?) ?? 0).toDouble();
                final pct = (mastery * 100).round();
                final color = pct >= 70
                    ? AppColors.green
                    : pct >= 40
                        ? AppColors.amber
                        : AppColors.coral;
                return _MasteryBar(label: topic, value: mastery, color: color);
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        _SectionCard(
          title: 'Module progress',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${dash.modulesCompleted} / ${dash.modulesTotal} completed',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: dash.modulesTotal > 0
                      ? (dash.modulesCompleted / dash.modulesTotal)
                          .clamp(0.0, 1.0)
                      : 0,
                  backgroundColor: AppColors.outline,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.purple),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        Text('Actions', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.sm),
        _ActionButton(
          icon: Icons.assignment_rounded,
          label: 'Assign Revision',
          color: AppColors.purple,
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AssignRevisionSheet(
              childId: childId,
              weakAreas: dash.weakAreas
                  .map((w) => (w['topic'] as String?) ?? '')
                  .where((t) => t.isNotEmpty)
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ActionButton(
          icon: Icons.star_rounded,
          label: 'Award Stars',
          color: AppColors.amber,
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AwardStarsSheet(childId: childId),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ActionButton(
          icon: Icons.flag_rounded,
          label: 'Set Weekly Goal',
          color: AppColors.teal,
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => WeeklyGoalSheet(childId: childId),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.sessions,
    required this.minutes,
    required this.xp,
    required this.streak,
  });

  final int sessions;
  final int minutes;
  final int xp;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(label: 'Sessions', value: '$sessions', color: AppColors.purple),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(label: 'Minutes', value: '$minutes', color: AppColors.teal),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(label: 'XP', value: '$xp', color: AppColors.amber),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(label: 'Streak', value: '$streak', color: AppColors.coral),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.title.copyWith(color: color, fontSize: 16)),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _MasteryBar extends StatelessWidget {
  const _MasteryBar({
    required this.label,
    required this.value,
    this.color = AppColors.purple,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(label,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Text('$pct%',
                  style: AppTextStyles.label.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: AppColors.outline,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(label,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600)),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.text3),
            const SizedBox(height: AppSpacing.md),
            Text(error,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.text2)),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
