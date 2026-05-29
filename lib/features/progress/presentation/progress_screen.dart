import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/features/library/presentation/library_view_model.dart';
import 'package:pally/features/progress/presentation/daily_goal_provider.dart';
import 'package:pally/features/progress/presentation/daily_goal_ring.dart';
import 'package:pally/features/progress/presentation/progress_view_model.dart';
import 'package:pally/features/progress/presentation/streak_card.dart';
import 'package:pally/features/progress/presentation/streak_milestone_controller.dart';
import 'package:pally/features/progress/presentation/streak_status_provider.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/progress_summary.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(progressViewModelProvider);

    // Fire the milestone overlay once per newly-celebrated milestone. The
    // controller persists "seen" in SharedPreferences so revisiting the
    // tab doesn't re-celebrate the same one.
    ref.listen(streakStatusVmProvider, (_, next) {
      next.whenData((s) {
        StreakMilestoneController.maybeCelebrate(context,
            milestonesReached: s.milestonesReached);
      });
    });

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
          onRefresh: () async {
            ref.invalidate(streakStatusVmProvider);
            ref.invalidate(dailyGoalVmProvider);
            await ref.read(progressViewModelProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LevelCard(progress: progress),
                const SizedBox(height: AppSpacing.md),
                const DailyGoalRing(),
                const SizedBox(height: AppSpacing.md),
                const StreakCard(),
                const SizedBox(height: AppSpacing.md),
                const _BrainMapCard(),
                const SizedBox(height: AppSpacing.md),
                _StatsRow(progress: progress),
                const SizedBox(height: AppSpacing.md),
                _WeekMinutesStat(weekMinutes: progress.weekMinutes),
                const SizedBox(height: AppSpacing.md),
                if (progress.weakTopics.isNotEmpty)
                  _WeakTopicsCard(
                    weakTopics: progress.weakTopics,
                    onPractice: () => context.push('/avatar/all/quiz'),
                  ),
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
    // Show progress WITHIN the current level (numerator/denominator come
    // straight from the backend so we never re-derive the curve and drift).
    // Previously this rendered total XP / "remaining to next level" — a
    // nonsense ratio that always read 1.0 once you had any XP at all.
    final isMaxLevel = progress.level >= progress.maxLevel;
    final xpProgress = isMaxLevel
        ? 1.0
        : (progress.xpSpanForLevel > 0
            ? progress.xpIntoLevel / progress.xpSpanForLevel
            : 0.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => const LevelRoadmapRoute().push(context),
        child: Ink(
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
                    style: AppTextStyles.heading1
                        .copyWith(color: Colors.white, fontSize: 28),
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
                      style:
                          AppTextStyles.title.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isMaxLevel
                          ? 'MAX LEVEL ⭐'
                          : '${progress.xpIntoLevel} / ${progress.xpSpanForLevel} XP',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: xpProgress.clamp(0.0, 1.0),
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    if (!isMaxLevel) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${progress.xpToNextLevel} XP to Level ${progress.level + 1}',
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.white60),
                      ),
                    ],
                    const SizedBox(height: 6),
                    _NextUnlockLine(
                      isMaxLevel: isMaxLevel,
                      level: progress.nextUnlockLevel,
                      label: progress.nextUnlockLabel,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white60, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextUnlockLine extends StatelessWidget {
  const _NextUnlockLine({
    required this.isMaxLevel,
    required this.level,
    required this.label,
  });

  final bool isMaxLevel;
  final int? level;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final text = isMaxLevel
        ? '⭐ Max level reached — legendary!'
        : (level != null && label != null
            ? '🎁 Next unlock at L$level: $label'
            : '');
    if (text.isEmpty) return const SizedBox.shrink();
    return Text(
      text,
      style: AppTextStyles.caption.copyWith(color: Colors.white),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.progress});

  final ProgressSummary progress;

  @override
  Widget build(BuildContext context) {
    // The streak stat moved to its own StreakCard; this row keeps the
    // secondary numbers (total XP + badge count).
    return Row(
      children: [
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

/// Tiny secondary stat — "you studied X min this week". The bar chart
/// got demoted to make room for the daily goal ring; parents who want
/// detail can still read the headline.
class _WeekMinutesStat extends StatelessWidget {
  const _WeekMinutesStat({required this.weekMinutes});
  final List<int> weekMinutes;

  @override
  Widget build(BuildContext context) {
    final total = weekMinutes.fold<int>(0, (a, b) => a + b);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surf2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined,
              color: AppColors.text2, size: 18),
          const SizedBox(width: 6),
          Text('$total min studied this week',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.text2)),
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

/// Gradient entry card to the Brain Map. Hidden when the user has no
/// avatars yet (nothing to map). With one avatar, tap goes straight in;
/// with several, a bottom-sheet picker lets the user choose which tutor.
class _BrainMapCard extends ConsumerWidget {
  const _BrainMapCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarsAsync = ref.watch(libraryViewModelProvider);
    final avatars = avatarsAsync.maybeWhen(
      data: (list) => list,
      orElse: () => const <Avatar>[],
    );
    if (avatars.isEmpty) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7042ED), Color(0xFF8F66FA)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (avatars.length == 1) {
              BrainMapRoute(avatarId: avatars.first.id).push(context);
            } else {
              _pickAvatar(context, avatars);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 4),
            child: Row(
              children: [
                const Text('🧠', style: TextStyle(fontSize: 28)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Brain Map',
                          style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                      Text(
                        avatars.length == 1
                            ? 'See ${avatars.first.name}\'s knowledge as a visual map'
                            : 'See your tutors\' knowledge as a visual map',
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickAvatar(BuildContext context, List<Avatar> avatars) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose tutor', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              for (final a in avatars)
                ListTile(
                  leading: CharacterWidget(
                      character: a.character, size: 36),
                  title: Text(a.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text(a.subject,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.text2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.pop(context);
                    BrainMapRoute(avatarId: a.id).push(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
