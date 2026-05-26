import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/features/progress/presentation/progress_view_model.dart';
import 'package:pally/shared/models/progress_summary.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(progressViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('My Progress', style: AppTextStyles.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.text2),
            onPressed: () => const SettingsRoute().push(context),
          ),
        ],
      ),
      body: progressAsync.when(
        loading: () => const PallyLoadingSpinner(),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.read(progressViewModelProvider.notifier).refresh(),
        ),
        data: (progress) => RefreshIndicator(
          color: AppColors.purple,
          onRefresh: () =>
              ref.read(progressViewModelProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LevelCard(progress: progress),
                const SizedBox(height: AppSpacing.md),
                _StatsRow(progress: progress),
                const SizedBox(height: AppSpacing.md),
                _ActivityChart(
                  tabController: _tabController,
                  weekMinutes: progress.weekMinutes,
                ),
                const SizedBox(height: AppSpacing.md),
                if (progress.weakTopics.isNotEmpty)
                  _WeakTopicsCard(
                    weakTopics: progress.weakTopics,
                    onPractice: () => context.push('/avatar/all/quiz'),
                  ),
                const SizedBox(height: AppSpacing.md),
                const _ErrorPatternsCard(),
                const SizedBox(height: AppSpacing.md),
                if (progress.badges.isNotEmpty)
                  _BadgesCard(badges: progress.badges),
                const SizedBox(height: AppSpacing.md),
                _NavButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.progress});

  final ProgressSummary progress;

  @override
  Widget build(BuildContext context) {
    final xpProgress =
        progress.xpToNextLevel > 0 ? progress.xp / progress.xpToNextLevel : 1.0;

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
          // Level circle
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), width: 3),
            ),
            child: Center(
              child: Text(
                '${progress.level}',
                style: AppTextStyles.heading1.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${progress.level}',
                  style: AppTextStyles.title.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${progress.xp} / ${progress.xpToNextLevel} XP',
                  style:
                      AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: xpProgress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.progress});

  final ProgressSummary progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            value: '${progress.streakDays}',
            label: 'Day Streak',
            color: AppColors.coral,
            bgColor: AppColors.coralL,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.star_rounded,
            value: '${progress.xp}',
            label: 'Total XP',
            color: AppColors.amber,
            bgColor: AppColors.amberL,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.psychology_rounded,
            value: '${progress.badges.length}',
            label: 'Badges',
            color: AppColors.purple,
            bgColor: AppColors.purpleL,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Text(value,
              style: AppTextStyles.title.copyWith(color: color, fontSize: 18)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({
    required this.tabController,
    required this.weekMinutes,
  });

  final TabController tabController;
  final List<int> weekMinutes;

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxMinutes =
        weekMinutes.isEmpty ? 1 : weekMinutes.reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Activity', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xs),
                TabBar(
                  controller: tabController,
                  isScrollable: false,
                  labelStyle: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: AppTextStyles.label,
                  indicatorColor: AppColors.purple,
                  labelColor: AppColors.purple,
                  unselectedLabelColor: AppColors.text3,
                  tabs: const [
                    Tab(text: 'Week'),
                    Tab(text: 'Month'),
                    Tab(text: 'All Time'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outline),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                days.length,
                (i) {
                  final minutes = i < weekMinutes.length ? weekMinutes[i] : 0;
                  final heightFraction =
                      maxMinutes > 0 ? minutes / maxMinutes : 0.0;
                  final isToday = i == DateTime.now().weekday - 1;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$minutes',
                        style: AppTextStyles.caption.copyWith(
                          color: isToday ? AppColors.purple : AppColors.text3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        width: 28,
                        height: (80 * heightFraction).clamp(4.0, 80.0),
                        decoration: BoxDecoration(
                          color: isToday ? AppColors.purple : AppColors.purpleL,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        days[i],
                        style: AppTextStyles.caption.copyWith(
                          color: isToday ? AppColors.purple : AppColors.text3,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                bottom: AppSpacing.sm, left: AppSpacing.md),
            child: Text('minutes per day', style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }
}

class _WeakTopicsCard extends StatelessWidget {
  const _WeakTopicsCard({
    required this.weakTopics,
    required this.onPractice,
  });

  final List<WeakTopic> weakTopics;
  final VoidCallback onPractice;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Needs Work', style: AppTextStyles.title),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.coralL,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${weakTopics.length} topics',
                  style: AppTextStyles.caption.copyWith(color: AppColors.coral),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...weakTopics.map((t) => _TopicBar(topic: t)),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPractice,
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: const Text('Practice Weak Topics'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicBar extends StatelessWidget {
  const _TopicBar({required this.topic});

  final WeakTopic topic;

  @override
  Widget build(BuildContext context) {
    final pct = (topic.mastery * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(topic.topic, style: AppTextStyles.bodySmall),
              Text('$pct%',
                  style: AppTextStyles.label.copyWith(color: AppColors.amber)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: topic.mastery.clamp(0.0, 1.0),
              backgroundColor: AppColors.outline,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.amber),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgesCard extends StatelessWidget {
  const _BadgesCard({required this.badges});

  final List<String> badges;

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
          Text('Badges', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: badges.map((badge) => _BadgeItem(emoji: badge)).toList(),
          ),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  const _BadgeItem({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.goldL,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class _NavButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => const ShopRoute().push(context),
            icon: const Icon(Icons.storefront_rounded, size: 18),
            label: const Text('Character Shop'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.purple,
              side: const BorderSide(color: AppColors.purple),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => const ParentRoute().push(context),
            icon: const Icon(Icons.lock_outline_rounded, size: 18),
            label: const Text('Parent Mode'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.teal,
              side: const BorderSide(color: AppColors.teal),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// ── P8: Error Patterns ────────────────────────────────────────────────────────

class _ErrorPattern {
  const _ErrorPattern(this.topic, this.errorCount, this.description);
  final String topic;
  final int errorCount;
  final String description;
}

class _ErrorPatternsCard extends StatelessWidget {
  const _ErrorPatternsCard();

  static const _patterns = [
    _ErrorPattern(
        'Fractions', 7, 'Often confuses numerator and denominator in division'),
    _ErrorPattern(
        'Photosynthesis', 4, 'Mixes up reactants and products in equation'),
    _ErrorPattern('Past Tense', 3, 'Irregular verbs — "runned" vs "ran"'),
  ];

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
          Row(
            children: [
              const Text('🔍', style: TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.xs),
              Text('Error Patterns', style: AppTextStyles.title),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.coralL,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_patterns.length} patterns',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.coral),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Recurring mistakes across quizzes and chats',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._patterns.map((p) => _ErrorPatternRow(pattern: p)),
        ],
      ),
    );
  }
}

class _ErrorPatternRow extends StatelessWidget {
  const _ErrorPatternRow({required this.pattern});
  final _ErrorPattern pattern;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.coralL,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${pattern.errorCount}',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.coral,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pattern.topic,
                  style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  pattern.description,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Screen error state ────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 60, color: AppColors.coral),
          const SizedBox(height: AppSpacing.md),
          Text('Could not load progress', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
