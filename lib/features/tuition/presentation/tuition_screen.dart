import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/services/feature_flags.dart';

/// Tuition marketplace — admin-only tab.
///
/// Only visible in the navigation bar when the user's flag `is_admin` is true
/// (set server-side from the user's `role` column). Regular users never see
/// this tab; even if they deep-link to `/tuition` they land on the
/// access-denied view.
///
/// This is a placeholder for the full tuition marketplace. The chat channel
/// between tutors and students will live here, gated behind the same admin flag.
class TuitionScreen extends ConsumerWidget {
  const TuitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = isFlagEnabled(ref, FeatureFlags.isAdmin);

    if (!isAdmin) {
      return const _AccessDeniedView();
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.purple,
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Tuition',
                style: AppTextStyles.title.copyWith(color: Colors.white),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.purple, AppColors.purpleC],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.coralL,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.admin_panel_settings_rounded,
                            size: 14, color: AppColors.coral),
                        const SizedBox(width: 4),
                        Text('Admin view',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.coral,
                                    fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Marketplace section header
                  Text('Tuition Marketplace',
                      style: AppTextStyles.heading1),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Connect students with verified tutors. Coming soon.',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.text2),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Placeholder action cards
                  _TuitionActionCard(
                    icon: Icons.chat_outlined,
                    title: 'Tutor Chat',
                    subtitle:
                        'Direct messaging between tutors and students',
                    badge: 'Admin only',
                    onTap: () {
                      // TODO: navigate to admin chat channel
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TuitionActionCard(
                    icon: Icons.person_search_outlined,
                    title: 'Tutor Directory',
                    subtitle: 'Browse and manage tutor profiles',
                    onTap: () {
                      // TODO: tutor directory
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TuitionActionCard(
                    icon: Icons.event_note_outlined,
                    title: 'Sessions',
                    subtitle: 'Upcoming booked tuition sessions',
                    onTap: () {
                      // TODO: sessions management
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TuitionActionCard(
                    icon: Icons.bar_chart_rounded,
                    title: 'Analytics',
                    subtitle: 'Platform-wide tuition statistics',
                    onTap: () {
                      // TODO: analytics
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Coming soon notice
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.purpleL,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.construction_rounded,
                            color: AppColors.purple, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Full marketplace features are under development. '
                            'This tab is visible only to admin accounts.',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.purple),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TuitionActionCard extends StatelessWidget {
  const _TuitionActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.purpleL,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.purple, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700)),
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.coralL,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(badge!,
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.coral)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.text2)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessDeniedView extends StatelessWidget {
  const _AccessDeniedView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded,
                  size: 64, color: AppColors.text3),
              const SizedBox(height: AppSpacing.md),
              Text('Tuition Marketplace',
                  style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This area is restricted to platform administrators.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.text2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
