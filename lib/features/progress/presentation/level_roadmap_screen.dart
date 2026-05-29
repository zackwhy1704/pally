import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/features/progress/presentation/level_roadmap_provider.dart';
import 'package:pally/shared/models/level_roadmap.dart';

class LevelRoadmapScreen extends ConsumerWidget {
  const LevelRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(levelRoadmapProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Level rewards', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: async.when(
        loading: () => const PallyLoadingSpinner(),
        error: (_, __) => Center(
          child: Text('Could not load roadmap', style: AppTextStyles.body),
        ),
        data: (roadmap) => RefreshIndicator(
          color: AppColors.purple,
          onRefresh: () async => ref.invalidate(levelRoadmapProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: roadmap.rewards.length + 1,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              if (i == 0) return _Header(roadmap: roadmap);
              return _RewardRow(
                reward: roadmap.rewards[i - 1],
                isCurrent:
                    roadmap.rewards[i - 1].level == roadmap.currentLevel + 1
                        ? false
                        : _isNext(roadmap, i - 1),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Highlight the first unearned reward as the "current target".
  bool _isNext(LevelRoadmap roadmap, int idx) {
    if (roadmap.rewards[idx].unlocked) return false;
    for (var j = 0; j < idx; j++) {
      if (!roadmap.rewards[j].unlocked) return false;
    }
    return true;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.roadmap});
  final LevelRoadmap roadmap;

  @override
  Widget build(BuildContext context) {
    final earned = roadmap.rewards.where((r) => r.unlocked).length;
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.purple, AppColors.purpleC],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), width: 3),
            ),
            child: Center(
              child: Text(
                '${roadmap.currentLevel}',
                style: AppTextStyles.heading1
                    .copyWith(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Level ${roadmap.currentLevel} of ${roadmap.maxLevel}',
                    style:
                        AppTextStyles.title.copyWith(color: Colors.white)),
                const SizedBox(height: 2),
                Text(
                  '$earned of ${roadmap.rewards.length} rewards unlocked',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.reward, required this.isCurrent});
  final LevelReward reward;
  final bool isCurrent;

  IconData get _icon => switch (reward.kind) {
        'FUNCTIONAL' => Icons.bolt_rounded,
        'BADGE' => Icons.workspace_premium_rounded,
        'MYSTERY' => Icons.card_giftcard_rounded,
        _ => Icons.palette_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final color = reward.unlocked
        ? AppColors.gold
        : isCurrent
            ? AppColors.amber
            : AppColors.text3;
    final bg = reward.unlocked
        ? AppColors.goldL
        : isCurrent
            ? AppColors.amberL
            : AppColors.surf2;
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: isCurrent
            ? Border.all(color: AppColors.amber, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Level ${reward.level}',
                    style: AppTextStyles.label.copyWith(color: color)),
                const SizedBox(height: 2),
                Text(reward.label,
                    style: AppTextStyles.body.copyWith(
                        color: reward.unlocked
                            ? AppColors.text1
                            : AppColors.text2,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Text(
            reward.unlocked
                ? 'Earned'
                : (isCurrent ? 'Next' : 'Locked'),
            style: AppTextStyles.label.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
