import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/features/progress/presentation/achievements_provider.dart';
import 'package:pally/shared/models/achievement.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(achievementsProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Achievements', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: async.when(
        loading: () => const PallyLoadingSpinner(),
        error: (e, _) => PallyErrorCard(
          message: PallyError.from(e).userMessage,
          onRetry: () => ref.invalidate(achievementsProvider),
        ),
        data: (list) => RefreshIndicator(
          color: AppColors.purple,
          onRefresh: () async => ref.invalidate(achievementsProvider),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: _buildSections(list),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSections(AchievementList list) {
    final widgets = <Widget>[];
    widgets.add(_Header(list: list));
    widgets.add(const SizedBox(height: AppSpacing.md));

    // Recently-earned shelf — top of the screen as a positive anchor.
    final earned = list.achievements.where((a) => a.earned).toList()
      ..sort((a, b) => (b.earnedAt ?? '').compareTo(a.earnedAt ?? ''));
    if (earned.isNotEmpty) {
      widgets.add(Text('Recently earned', style: AppTextStyles.title));
      widgets.add(const SizedBox(height: AppSpacing.sm));
      // Height scales with the user's text-size setting so the tile's fixed +
      // Expanded content never overflows the shelf at large accessibility scale.
      widgets.add(Builder(builder: (context) {
        final scale =
            MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.6);
        return SizedBox(
          height: 132 * scale,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: earned.length.clamp(0, 6),
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, i) => SizedBox(
              width: 120,
              child: _AchievementTile(a: earned[i]),
            ),
          ),
        );
      }));
      widgets.add(const SizedBox(height: AppSpacing.md));
    }

    const order = ['STREAK', 'MASTERY', 'CURIOSITY', 'MILESTONE'];
    for (final cat in order) {
      final inCat =
          list.achievements.where((a) => a.category == cat).toList();
      if (inCat.isEmpty) continue;
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Text(_categoryLabel(cat), style: AppTextStyles.title),
      ));
      widgets.add(const SizedBox(height: AppSpacing.sm));
      widgets.add(GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: inCat.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.88,
        ),
        itemBuilder: (_, i) => _AchievementTile(a: inCat[i]),
      ));
    }
    return widgets;
  }

  String _categoryLabel(String c) => switch (c) {
        'STREAK' => 'Streak',
        'MASTERY' => 'Mastery',
        'CURIOSITY' => 'Curiosity',
        'MILESTONE' => 'Milestones',
        _ => c,
      };
}

class _Header extends StatelessWidget {
  const _Header({required this.list});
  final AchievementList list;

  @override
  Widget build(BuildContext context) {
    final pct = list.totalCount == 0
        ? 0
        : ((list.earnedCount / list.totalCount) * 100).round();
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.amber],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🏅', style: TextStyle(fontSize: 40)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${list.earnedCount} / ${list.totalCount} earned',
                  style: AppTextStyles.title.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text('$pct% of all achievements',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.a});
  final Achievement a;

  Color get _rarityColor => switch (a.rarity) {
        'LEGENDARY' => AppColors.gold,
        'EPIC' => AppColors.purple,
        'RARE' => AppColors.teal,
        _ => AppColors.text3,
      };

  IconData get _icon => switch (a.category) {
        'STREAK' => Icons.local_fire_department_rounded,
        'MASTERY' => Icons.workspace_premium_rounded,
        'CURIOSITY' => Icons.psychology_alt_rounded,
        'MILESTONE' => Icons.flag_rounded,
        _ => Icons.star_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final progress = a.target == 0 ? 0.0 : (a.progress / a.target).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: a.earned ? AppColors.surface : AppColors.surf2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: a.earned
              ? _rarityColor.withValues(alpha: 0.6)
              : AppColors.outline,
          width: a.earned ? 1.5 : 1,
        ),
        boxShadow: a.earned && a.rarity == 'LEGENDARY'
            ? [
                BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: 16),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (a.earned ? _rarityColor : AppColors.text3)
                      .withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon,
                    color: a.earned ? _rarityColor : AppColors.text3,
                    size: 18),
              ),
              const Spacer(),
              if (a.rarity != 'COMMON')
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _rarityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    a.rarity.toLowerCase(),
                    style: AppTextStyles.caption
                        .copyWith(color: _rarityColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            a.name,
            style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: a.earned ? AppColors.text1 : AppColors.text2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Text(
              a.description,
              style: AppTextStyles.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.outline,
              valueColor: AlwaysStoppedAnimation<Color>(
                  a.earned ? AppColors.green : _rarityColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            a.earned ? 'Earned' : '${a.progress} / ${a.target}',
            style: AppTextStyles.caption.copyWith(
                color: a.earned ? AppColors.green : AppColors.text2),
          ),
        ],
      ),
    );
  }
}
