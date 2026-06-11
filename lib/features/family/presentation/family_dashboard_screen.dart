import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/features/family/family_service.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';
import 'package:pally/shared/models/entitlement.dart';

/// P5 — parent's view of the family. Lists linked children, subscription
/// status, and quick links into reports + referral + parent PIN.
class FamilyDashboardScreen extends ConsumerStatefulWidget {
  const FamilyDashboardScreen({super.key});

  @override
  ConsumerState<FamilyDashboardScreen> createState() =>
      _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState
    extends ConsumerState<FamilyDashboardScreen> {
  Future<Map<String, dynamic>>? _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(familyServiceProvider).family();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ref.read(familyServiceProvider).family();
    });
    ref.invalidate(entitlementVmProvider);
  }

  @override
  Widget build(BuildContext context) {
    final ent = ref.watch(entitlementVmProvider).valueOrNull;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Family', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const PallyLoadingSpinner();
          final data = snap.data!;
          final children =
              (data['children'] as List?) ?? const [];
          return RefreshIndicator(
            color: AppColors.purple,
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _SubBanner(ent: ent),
                const SizedBox(height: AppSpacing.md),
                Text('Linked children',
                    style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.sm),
                if (children.isEmpty)
                  _EmptyChildren(onAdd: () => context.push('/family/claim'))
                else
                  ...children.map((c) => _ChildTile(
                        data: Map<String, dynamic>.from(c as Map),
                      )),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => context.push('/family/claim'),
                  icon: const Icon(Icons.person_add_alt_rounded, size: 18),
                  label: const Text('Add another child'),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Quick actions', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.sm),
                _QuickLink(
                  icon: Icons.assessment_rounded,
                  label: 'Weekly reports',
                  onTap: () => context.push('/parent/reports'),
                ),
                _QuickLink(
                  icon: Icons.lock_outline_rounded,
                  label: 'Parent PIN',
                  onTap: () => context.push('/parent'),
                ),
                _QuickLink(
                  icon: Icons.card_giftcard_rounded,
                  label: 'Referral code',
                  onTap: () => context.push('/referral'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SubBanner extends StatelessWidget {
  const _SubBanner({required this.ent});
  final Entitlement? ent;

  @override
  Widget build(BuildContext context) {
    final isPremium = ent?.isPremium == true;
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium
              ? const [AppColors.purple, AppColors.purpleC]
              : const [AppColors.amber, AppColors.coral],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(isPremium ? '⭐' : '🚀',
              style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isPremium
                  ? 'Family plan active — all premium features unlocked.'
                  : 'On free — upgrade to share unlimited Mochis with up to 4 kids.',
              style: AppTextStyles.body
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          if (!isPremium)
            FilledButton(
              onPressed: () => context.push('/subscription/plans'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.coral,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
              ),
              child: const Text('Upgrade'),
            ),
        ],
      ),
    );
  }
}

class _ChildTile extends StatelessWidget {
  const _ChildTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = (data['childName'] as String?)?.isNotEmpty == true
        ? data['childName'] as String
        : (data['displayName'] as String? ?? 'Child');
    final level = (data['level'] as num?)?.toInt() ?? 1;
    final streak = (data['streakDays'] as num?)?.toInt() ?? 0;
    final minutes = (data['minutesThisWeek'] as num?)?.toInt() ?? 0;
    final modules = (data['modulesCompleted'] as num?)?.toInt() ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.purpleL,
            radius: 22,
            child: Text(
              name.characters.first.toUpperCase(),
              style: AppTextStyles.title.copyWith(color: AppColors.purple),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                    'Lv.$level · $streak days · $minutes min · $modules done',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.text3),
        ],
      ),
    );
  }
}

class _EmptyChildren extends StatelessWidget {
  const _EmptyChildren({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surf2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Text('No children linked yet',
              style: AppTextStyles.body
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
              'Ask your child to open Apalchi → Me → "Link a grown-up" and share their code.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_alt_rounded, size: 16),
            label: const Text('Enter a code'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.purple,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.purple),
        title: Text(label),
        trailing:
            const Icon(Icons.chevron_right_rounded, color: AppColors.text3),
        onTap: onTap,
      ),
    );
  }
}
