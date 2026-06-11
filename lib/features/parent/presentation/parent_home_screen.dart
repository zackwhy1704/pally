import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/features/parent/presentation/parent_home_view_model.dart';

/// Parent home screen — the landing page for parent accounts.
/// Shows linked children with progress summaries.
class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parentHomeViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text(
          'Hello, ${state.parentName ?? 'Parent'}',
          style: AppTextStyles.title,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.text2),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: state.isLoading
          ? const PallyLoadingSpinner()
          : RefreshIndicator(
              color: AppColors.purple,
              onRefresh: () =>
                  ref.read(parentHomeViewModelProvider.notifier).refresh(),
              child: state.children.isEmpty
                  ? _EmptyState()
                  : ListView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: [
                        for (final child in state.children) ...[
                          _ChildProgressCard(child: child),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        _BottomActions(),
                      ],
                    ),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Container(
          width: AppSizing.iconContainer,
          height: AppSizing.iconContainer,
          decoration: const BoxDecoration(
            color: AppColors.purpleL,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.people_outline_rounded,
              color: AppColors.purple, size: 32),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Link your first child to see their progress',
          style: AppTextStyles.title,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Ask your child to open Apalchi, go to Me tab, '
          'and tap "Link a grown-up" to get a code.',
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: FilledButton.icon(
            onPressed: () => context.push('/family/claim'),
            icon: const Icon(Icons.person_add_alt_rounded, size: 18),
            label: const Text('Link a child'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.purple,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChildProgressCard extends StatelessWidget {
  const _ChildProgressCard({required this.child});
  final ParentChildSummary child;

  Color get _statusColor => switch (child.statusChip) {
        'on_track' => AppColors.green,
        'behind' => AppColors.amber,
        'needs_attention' => AppColors.coral,
        _ => AppColors.text3,
      };

  String get _statusLabel => switch (child.statusChip) {
        'on_track' => 'On track',
        'behind' => 'Behind',
        'needs_attention' => 'Needs attention',
        _ => 'Unknown',
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/parent/child/${child.childId}'),
        child: Container(
          padding: AppSpacing.card,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.purpleL,
                    radius: 22,
                    child: Text(
                      child.name.isNotEmpty
                          ? child.name.characters.first.toUpperCase()
                          : '?',
                      style: AppTextStyles.title
                          .copyWith(color: AppColors.purple),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(child.name,
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(
                          '${child.subject} | Lv.${child.level}',
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.text3),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1, color: AppColors.outline),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.local_fire_department_rounded,
                      label: '${child.streakDays} days',
                      color: AppColors.coral,
                    ),
                  ),
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.timer_outlined,
                      label: '${child.minutesThisWeek} min',
                      color: AppColors.teal,
                    ),
                  ),
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.check_circle_outline_rounded,
                      label: '${child.modulesCompleted} done',
                      color: AppColors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: _statusColor, size: 8),
                    const SizedBox(width: AppSpacing.xs),
                    Text(_statusLabel,
                        style: AppTextStyles.label
                            .copyWith(color: _statusColor)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(label,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push('/family/claim'),
            icon: const Icon(Icons.person_add_alt_rounded, size: 16),
            label: const Text('Link a child'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.purple,
              side: const BorderSide(color: AppColors.outline),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: share app link
            },
            icon: const Icon(Icons.share_rounded, size: 16),
            label: const Text('Share app'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.text2,
              side: const BorderSide(color: AppColors.outline),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
