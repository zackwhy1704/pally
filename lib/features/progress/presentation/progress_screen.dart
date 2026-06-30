import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/widgets/loading/pally_skeleton.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/ui/adaptive_content_width.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/features/library/presentation/library_view_model.dart';
import 'package:pally/features/invite/presentation/milestone_invite_nudge.dart';
import 'package:pally/features/progress/presentation/achievements_provider.dart';
import 'package:pally/features/progress/presentation/coverage_provider.dart';
import 'package:pally/features/progress/presentation/daily_goal_provider.dart';
import 'package:pally/features/progress/presentation/daily_goal_ring.dart';
import 'package:pally/features/progress/presentation/mastery_card.dart';
import 'package:pally/features/progress/presentation/progress_view_model.dart';
import 'package:pally/features/progress/presentation/streak_card.dart';
import 'package:pally/features/progress/presentation/streak_milestone_controller.dart';
import 'package:pally/features/progress/presentation/streak_status_provider.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';
import 'package:pally/features/subscription/trial_status_provider.dart';
import 'package:pally/shared/models/achievement.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/entitlement.dart';
import 'package:pally/shared/models/mochi_character.dart';
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
      body: AdaptiveContentWidth(
        child: progressAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(children: [
            PallyBlockSkeleton(height: 100),
            SizedBox(height: AppSpacing.sm),
            PallyBlockSkeleton(height: 80),
            SizedBox(height: AppSpacing.sm),
            PallyAvatarListSkeleton(count: 2),
          ]),
        ),
        error: (e, _) => PallyErrorCard(
          message: PallyError.from(e).userMessage,
          onRetry: () => ref.read(progressViewModelProvider.notifier).refresh(),
        ),
        data: (progress) => RefreshIndicator(
          color: AppColors.purple,
          onRefresh: () async {
            ref.invalidate(streakStatusVmProvider);
            ref.invalidate(dailyGoalVmProvider);
            ref.invalidate(coverageProvider);
            ref.invalidate(achievementsProvider);
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
                MilestoneInviteNudge(streakDays: progress.streakDays),
                const StreakCard(),
                const SizedBox(height: AppSpacing.md),
                const MasteryCard(),
                const SizedBox(height: AppSpacing.md),
                _StatsRow(progress: progress),
                const SizedBox(height: AppSpacing.md),
                _WeekMinutesStat(weekMinutes: progress.weekMinutes),
                const SizedBox(height: AppSpacing.md),
                if (progress.weakTopics.isNotEmpty)
                  _WeakTopicsCard(
                    weakTopics: progress.weakTopics,
                    onPractice: () => _launchQuiz(context, ref),
                  ),
                const _AchievementsPreview(),
                const SizedBox(height: AppSpacing.md),
                const _JoinCodeRow(),
                const SizedBox(height: AppSpacing.sm),
                const _InviteFriendsRow(),
                const SizedBox(height: AppSpacing.md),
                const _GoPremiumBanner(),
                const SizedBox(height: AppSpacing.md),
                _NavButtons(),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _LevelCard extends ConsumerWidget {
  const _LevelCard({required this.progress});

  final ProgressSummary progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMaxLevel = progress.level >= progress.maxLevel;
    final xpProgress = isMaxLevel
        ? 1.0
        : (progress.xpSpanForLevel > 0
            ? progress.xpIntoLevel / progress.xpSpanForLevel
            : 0.0);

    // Entitlement state — explicitly handle loading and error so the badge
    // never silently lies about premium status.
    final entitlementAsync = ref.watch(entitlementVmProvider);

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
              _MochiStatusPill(entitlementAsync: entitlementAsync),
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

/// Mochi avatar pill with a status badge placed ABOVE the circle (no overlap).
/// Always shows the base Mochi (base.png) — the user's default character.
class _MochiStatusPill extends StatelessWidget {
  const _MochiStatusPill({required this.entitlementAsync});

  final AsyncValue<Entitlement> entitlementAsync;

  @override
  Widget build(BuildContext context) {
    // Always use the base Mochi character for the profile pill.
    const char = MochiCharacter.mochi;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status badge sits entirely ABOVE the avatar — no overlap.
        _StatusBadge(entitlementAsync: entitlementAsync),
        const SizedBox(height: 4),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: char.bgColor.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 2.5,
            ),
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(char.assetPath, fit: BoxFit.contain),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends ConsumerWidget {
  const _StatusBadge({required this.entitlementAsync});
  final AsyncValue<Entitlement> entitlementAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use trialStatusProvider for the precise tier string (FREE/PRO/MAX/FAMILY/CENTRE).
    // Falls back to entitlement isPremium if trialStatus hasn't loaded yet.
    final tierAsync = ref.watch(trialStatusProvider);
    final tier = tierAsync.whenOrNull(data: (t) => t.subscriptionTier);

    if (entitlementAsync.isLoading && tier == null) {
      return _badge(
        label: '···',
        textColor: Colors.white.withValues(alpha: 0.5),
        bgDecoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
      );
    }

    final resolvedTier = tier ?? (entitlementAsync.valueOrNull?.isPremium == true ? 'PRO' : 'FREE');
    return _badgeForTier(resolvedTier);
  }

  Widget _badgeForTier(String tier) {
    return switch (tier) {
      'PRO' => _badge(
          label: 'PRO',
          textColor: Colors.white,
          bgDecoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7042ED), Color(0xFF9B6DFF)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7042ED).withValues(alpha: 0.5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      'MAX' => _badge(
          label: 'MAX',
          textColor: Colors.white,
          bgDecoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      'FAMILY' => _badge(
          label: 'FAMILY',
          textColor: Colors.white,
          bgDecoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00BBA4), Color(0xFF00D4BB)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BBA4).withValues(alpha: 0.5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      'CENTRE' => _badge(
          label: 'CENTRE',
          textColor: Colors.white,
          bgDecoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6BAE), Color(0xFFFF9CC9)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6BAE).withValues(alpha: 0.5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      _ => _badge(
          label: 'FREE',
          textColor: Colors.white.withValues(alpha: 0.7),
          bgDecoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
        ),
    };
  }

  Widget _badge({
    required String label,
    required Color textColor,
    required BoxDecoration bgDecoration,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: bgDecoration,
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
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
              Expanded(
                child: Text(topic.topic,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: AppSpacing.sm),
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

/// 3 closest-to-earning achievements + "See all". Replaces the old
/// emoji-only _BadgesCard.
class _AchievementsPreview extends ConsumerWidget {
  const _AchievementsPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(achievementsProvider);
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) {
        // Pick the 3 unearned achievements closest to completion (highest
        // progress ratio) — Duolingo-style "you're nearly there".
        final unearned = list.achievements.where((a) => !a.earned).toList()
          ..sort((a, b) {
            final aR = a.target == 0 ? 0 : a.progress / a.target;
            final bR = b.target == 0 ? 0 : b.progress / b.target;
            return bR.compareTo(aR);
          });
        final preview = unearned.take(3).toList();
        // If everything is earned, surface the newest earned ones instead.
        final fallback = list.achievements.where((a) => a.earned).toList()
          ..sort((a, b) => (b.earnedAt ?? '').compareTo(a.earnedAt ?? ''));
        final tiles =
            preview.isEmpty ? fallback.take(3).toList() : preview;
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
                  Text('Achievements', style: AppTextStyles.title),
                  TextButton(
                    onPressed: () =>
                        const AchievementsRoute().push(context),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.purple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${list.earnedCount}/${list.totalCount}',
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.purple)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 12, color: AppColors.purple),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (tiles.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Complete actions to earn your first achievement.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.text2),
                  ),
                )
              else
                Column(
                  children: tiles.map((a) => _AchievementPreviewRow(a: a)).toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AchievementPreviewRow extends StatelessWidget {
  const _AchievementPreviewRow({required this.a});
  final Achievement a;

  @override
  Widget build(BuildContext context) {
    final pct =
        a.target == 0 ? 0.0 : (a.progress / a.target).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.purpleL,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: AppColors.purple, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.name,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.outline,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        a.earned ? AppColors.green : AppColors.purple),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('${a.progress}/${a.target}',
              style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/// Nav buttons row. 13+-only app — no Parent Mode. Character Shop only.
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
      ],
    );
  }
}

/// Routes to the daily quiz for the correct Mochi.
/// Single avatar → goes straight in.
/// Multiple avatars → shows a bottom-sheet picker.
/// Never uses the literal string "all" as an avatarId — the backend has no
/// such route and would return an empty quiz.
void _launchQuiz(BuildContext context, WidgetRef ref) {
  final avatars = ref.read(libraryViewModelProvider).maybeWhen(
        data: (list) => list,
        orElse: () => const <Avatar>[],
      );
  if (avatars.isEmpty) return;
  if (avatars.length == 1) {
    QuizRoute(avatarId: avatars.first.id).push(context);
    return;
  }
  _pickAvatarForQuiz(context, avatars);
}

void _pickAvatarForQuiz(BuildContext context, List<Avatar> avatars) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) => SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetCtx).height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Which Mochi to quiz?', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              for (final a in avatars)
                ListTile(
                  leading: CharacterWidget.forAvatar(a, 36),
                  title: Text(a.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(a.subject,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.text2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.pop(context);
                    QuizRoute(avatarId: a.id).push(context);
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );
}


/// "⭐ Go Premium" banner above _NavButtons. Hidden when premium so the
/// Me tab stays clean for paying users.
class _GoPremiumBanner extends ConsumerWidget {
  const _GoPremiumBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ent = ref.watch(entitlementVmProvider).valueOrNull;
    if (ent == null || ent.isPremium) return const SizedBox.shrink();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => const PaywallRoute().push(context),
        child: Ink(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.purple, AppColors.purpleC],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 22)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Go Premium',
                        style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800)),
                    Text(
                      'Unlimited Mochis, chat & family sharing — 7-day free trial',
                      style: AppTextStyles.caption
                          .copyWith(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white70, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

/// Family connection row — adapts to the account's position in the
/// family graph so users only see actions that make sense for them:
///
/// • SOLO / CHILD without parent → two options: generate a code for a
///   parent to claim, OR enter a child's code (if this is the parent's
///   own account and they have a child's device).
/// • CHILD with parent linked → shows "Connected to [name]" confirmation.
/// • PARENT → row is hidden (they use Parent Mode button in _NavButtons).
/// Inbound Join handle on the Me tab — discoverable, not a nav slot.
class _JoinCodeRow extends StatelessWidget {
  const _JoinCodeRow();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => const JoinRoute().push(context),
        child: Ink(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              const Text('🎟️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Join a class or group',
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700)),
                    Text('Enter or scan a code someone gave you',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteFriendsRow extends StatelessWidget {
  const _InviteFriendsRow();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => const InviteRoute().push(context),
        child: Ink(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              const Text('🎁', style: TextStyle(fontSize: 22)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invite friends',
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700)),
                    Text('Earn bonus stars when they take their first quiz',
                        style: AppTextStyles.caption),
                  ],
                ),
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
