import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/features/progress/presentation/progress_view_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarsAsync = ref.watch(homeViewModelProvider);
    final progressAsync = ref.watch(progressViewModelProvider);

    ref.listen<AsyncValue<List<Avatar>>>(homeViewModelProvider, (_, next) {
      if (next is AsyncError) {
        PallyToast.error(context, 'Could not load tutors. Pull down to retry.');
      }
    });

    final level = progressAsync.valueOrNull?.level ?? 0;
    final xp = progressAsync.valueOrNull?.xp ?? 0;
    final xpToNext = progressAsync.valueOrNull?.xpToNextLevel ?? 100;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _HomeHeader(
              onNewTutor: () => const CreateTutorRoute().go(context),
              level: level,
              xp: xp,
              xpToNext: xpToNext,
            ),
            const _NudgeCardsRow(),
            Expanded(
              child: avatarsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.purple),
                ),
                error: (e, _) => _EmptyState(
                  onCreateTutor: () => const CreateTutorRoute().go(context),
                ),
                data: (avatars) => _AvatarGrid(avatars: avatars),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.onNewTutor,
    required this.level,
    required this.xp,
    required this.xpToNext,
  });

  final VoidCallback onNewTutor;
  final int level;
  final int xp;
  final int xpToNext;

  @override
  Widget build(BuildContext context) {
    final xpFraction = xpToNext > 0 ? (xp / xpToNext).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: const BoxDecoration(color: AppColors.purpleL),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            right: 24,
            child: _StarShape(
                size: 28, color: AppColors.purple.withValues(alpha: 0.15)),
          ),
          Positioned(
            top: 60,
            right: 70,
            child: _StarShape(
                size: 16, color: AppColors.purple.withValues(alpha: 0.1)),
          ),
          Positioned(
            bottom: 20,
            left: 180,
            child: _StarShape(
                size: 20, color: AppColors.purple.withValues(alpha: 0.12)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('👋 Hey, there!', style: AppTextStyles.heading1),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Which tutor do you want to chat with today?',
                  style: AppTextStyles.body.copyWith(color: AppColors.text2),
                ),

                // Level + XP bar
                if (level > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.amber.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          '⭐ Level $level',
                          style: AppTextStyles.label.copyWith(
                              color: AppColors.amber,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$xp / $xpToNext XP',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.text2),
                            ),
                            const SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: xpFraction,
                                minHeight: 6,
                                backgroundColor: AppColors.outline,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.amber),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MY TUTORS',
                      style: AppTextStyles.label.copyWith(
                        letterSpacing: 1.2,
                        color: AppColors.text2,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onNewTutor,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('New'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.purple,
                        textStyle: AppTextStyles.label
                            .copyWith(fontWeight: FontWeight.w700),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarShape extends StatelessWidget {
  const _StarShape({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.star_rounded, size: size, color: color);
  }
}

class _AvatarGrid extends ConsumerWidget {
  const _AvatarGrid({required this.avatars});
  final List<Avatar> avatars;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (avatars.isEmpty) {
      return _EmptyState(
        onCreateTutor: () => const CreateTutorRoute().go(context),
      );
    }

    return RefreshIndicator(
      color: AppColors.purple,
      onRefresh: () => ref.read(homeViewModelProvider.notifier).refresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 178 / 160,
        ),
        itemCount: avatars.length,
        itemBuilder: (context, index) {
          return _AvatarCard(avatar: avatars[index]);
        },
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({required this.avatar});
  final Avatar avatar;

  Color get _bgColor => avatar.character.bgColor;

  Color get _primaryColor => avatar.character.primaryColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ChatRoute(avatarId: avatar.id).push(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              children: [
                // Character area
                Expanded(
                  child: Container(
                    color: _bgColor,
                    width: double.infinity,
                    child: Center(
                      child: CharacterWidget(
                        character: avatar.character,
                        size: 80,
                      ),
                    ),
                  ),
                ),
                // Info area
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          avatar.subject,
                          style: AppTextStyles.caption.copyWith(
                            color: _primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        avatar.name,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.text1,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Active / knowledge badge
            if (avatar.hasKnowledge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateTutor});
  final VoidCallback onCreateTutor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.smart_toy_outlined,
              size: 80,
              color: AppColors.text3,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No tutors yet!',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create your first AI tutor to start getting help with your homework.',
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onCreateTutor,
              icon: const Icon(Icons.add),
              label: const Text('Create Tutor'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── P9: Nudge cards ───────────────────────────────────────────────────────────

class _NudgeCardsRow extends StatefulWidget {
  const _NudgeCardsRow();

  @override
  State<_NudgeCardsRow> createState() => _NudgeCardsRowState();
}

class _NudgeCardsRowState extends State<_NudgeCardsRow> {
  final List<_NudgeData> _nudges = [
    const _NudgeData(
      emoji: '⚡',
      message: 'You have 5 flashcards due today!',
      color: AppColors.amber,
      bgColor: AppColors.amberL,
    ),
    const _NudgeData(
      emoji: '🔥',
      message: 'Keep your 3-day streak going!',
      color: AppColors.coral,
      bgColor: AppColors.coralL,
    ),
    const _NudgeData(
      emoji: '📚',
      message: 'Your tutor learned 3 new topics.',
      color: AppColors.teal,
      bgColor: AppColors.tealL,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_nudges.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        itemCount: _nudges.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) => _NudgeCard(
          data: _nudges[i],
          onDismiss: () => setState(() => _nudges.removeAt(i)),
        ),
      ),
    );
  }
}

class _NudgeData {
  const _NudgeData({
    required this.emoji,
    required this.message,
    required this.color,
    required this.bgColor,
  });
  final String emoji;
  final String message;
  final Color color;
  final Color bgColor;
}

class _NudgeCard extends StatelessWidget {
  const _NudgeCard({required this.data, required this.onDismiss});
  final _NudgeData data;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: data.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: data.color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(data.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            data.message,
            style: AppTextStyles.caption.copyWith(
              color: data.color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close_rounded, size: 14, color: data.color),
          ),
        ],
      ),
    );
  }
}
