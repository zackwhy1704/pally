import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/adaptive_center.dart';
import 'package:pally/core/ui/confetti_burst.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/features/boss_battle/presentation/boss_battle_game.dart';
import 'package:pally/features/boss_battle/presentation/boss_battle_view_model.dart';
import 'package:pally/shared/models/boss_state.dart';

/// Phase 1 boss battle (v1). Server-authoritative: this screen never computes
/// hp/defeated/outcome itself — it renders exactly what
/// [BossBattleViewModel] fetched, and the embedded [BossBattleGame] only
/// visualizes the numbers it's handed.
class BossBattleScreen extends ConsumerStatefulWidget {
  const BossBattleScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  ConsumerState<BossBattleScreen> createState() => _BossBattleScreenState();
}

class _BossBattleScreenState extends ConsumerState<BossBattleScreen> {
  BossBattleGame? _game;

  /// True while the defeat animation is still playing. The screen only
  /// switches to the victory card once this flips back to false — a
  /// presentation-sequencing flag, not a game-state one; boss.defeated is
  /// already server-confirmed the moment this becomes true.
  bool _showingDefeat = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bossBattleViewModelProvider(widget.avatarId));

    // Fires the defeat animation exactly once, on the edge where the SERVER
    // response first reports defeated=true — never derived/guessed locally.
    ref.listen<BossBattleState>(bossBattleViewModelProvider(widget.avatarId),
        (previous, next) {
      final justDefeated =
          next.boss?.defeated == true && previous?.boss?.defeated != true;
      if (justDefeated && _game != null) {
        setState(() => _showingDefeat = true);
        _game!.playDefeatSequence().then((_) {
          if (mounted) setState(() => _showingDefeat = false);
        });
      }
    });

    // Push server-truth HP/outcome into the already-running game instance —
    // never recreate the game on every rebuild (that would reset its state).
    final boss = state.boss;
    if (boss != null && boss.active) {
      _game ??= BossBattleGame(hpMax: boss.hpMax, hpRemaining: boss.hpRemaining);
      if (!boss.defeated) {
        _game!.updateBattleState(
          hpRemaining: boss.hpRemaining,
          hpMax: boss.hpMax,
          hitLanded: state.lastHitLanded,
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(AppLocalizations.of(context).bossBattleTitle,
            style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: SafeArea(child: _buildBody(context, state)),
    );
  }

  Widget _buildBody(BuildContext context, BossBattleState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return PallyErrorCard(
        message: state.error!.userMessage,
        onRetry: () =>
            ref.read(bossBattleViewModelProvider(widget.avatarId).notifier).retry(),
      );
    }
    final boss = state.boss;
    if (boss == null || !boss.active) {
      return const _NoBossCard();
    }
    if (boss.defeated && !_showingDefeat) {
      return _VictoryCard(boss: boss);
    }
    // Active fight, OR just-defeated-but-still-playing-the-sequence — the
    // battle canvas stays up so the defeat animation has something to play on.
    return _BattleView(
      state: state,
      game: _game!,
      onSelect: (i) => ref
          .read(bossBattleViewModelProvider(widget.avatarId).notifier)
          .selectAnswer(i),
      onAttack: () =>
          ref.read(bossBattleViewModelProvider(widget.avatarId).notifier).attack(),
    );
  }
}

class _NoBossCard extends StatelessWidget {
  const _NoBossCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizing.iconContainer,
              height: AppSizing.iconContainer,
              decoration: const BoxDecoration(
                color: AppColors.purpleL,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_moon_outlined,
                  color: AppColors.purple, size: 36),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(AppLocalizations.of(context).bossBattleNoBossTitle,
                style: AppTextStyles.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppLocalizations.of(context).bossBattleNoBossBody,
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// The post-battle celebration. When [BossState.rewardUnlocked] is set (the
/// server's flag, never derived here), this plays a distinct companion-unlock
/// beat below the plain "defeated" heading — confetti + a gold badge, reusing
/// the same [ConfettiBurst] effect the level-up celebration uses so the
/// visual language matches across reward moments.
class _VictoryCard extends StatefulWidget {
  const _VictoryCard({required this.boss});
  final BossState boss;

  @override
  State<_VictoryCard> createState() => _VictoryCardState();
}

class _VictoryCardState extends State<_VictoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boss = widget.boss;
    return Stack(
      children: [
        if (boss.rewardUnlocked)
          Positioned.fill(child: ConfettiBurst(progress: _controller)),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ScaleTransition(
              scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppSizing.iconContainer,
                    height: AppSizing.iconContainer,
                    decoration: const BoxDecoration(
                      color: AppColors.tealL,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.celebration_rounded,
                        color: AppColors.teal, size: 36),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(AppLocalizations.of(context).bossBattleDefeatedTitle,
                      style: AppTextStyles.heading1, textAlign: TextAlign.center),
                  if (boss.rewardUnlocked) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _CompanionUnlockBadge(
                      message: AppLocalizations.of(context).bossBattleRewardMessage(
                          AppLocalizations.of(context).mascotName),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The Mochi companion-unlock moment — distinct from the plain "defeated"
/// heading above it, gated entirely on the server's rewardUnlocked flag.
class _CompanionUnlockBadge extends StatelessWidget {
  const _CompanionUnlockBadge({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.amber],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BattleView extends StatelessWidget {
  const _BattleView({
    required this.state,
    required this.game,
    required this.onSelect,
    required this.onAttack,
  });

  final BossBattleState state;
  final BossBattleGame game;
  final ValueChanged<int> onSelect;
  final VoidCallback onAttack;

  @override
  Widget build(BuildContext context) {
    final boss = state.boss!;
    final question = boss.currentQuestion;

    return SingleChildScrollView(
      child: AdaptiveCenter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                  AppLocalizations.of(context)
                      .bossBattleHpRemaining(boss.hpRemaining, boss.hpMax),
                  style: AppTextStyles.label.copyWith(color: AppColors.text2),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 220,
                child: GameWidget<BossBattleGame>(game: game),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (question != null) ...[
                Text(question.question, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.md),
                for (var i = 0; i < question.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _OptionButton(
                      label: question.options[i],
                      selected: state.selectedIndex == i,
                      onTap: state.isAttacking ? null : () => onSelect(i),
                    ),
                  ),
              ],
              const SizedBox(height: AppSpacing.md),
              if (state.error != null) ...[
                PallyErrorCard(message: state.error!.userMessage, onRetry: onAttack),
                const SizedBox(height: AppSpacing.sm),
              ],
              // Defeated (mid defeat-sequence): no question to answer, no
              // attack to make — the button would just sit there disabled.
              if (!boss.defeated)
                SizedBox(
                  height: AppSizing.buttonHeight,
                  child: FilledButton(
                    onPressed: (state.isAttacking || state.selectedIndex == null)
                        ? null
                        : onAttack,
                    style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
                    child: state.isAttacking
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(AppLocalizations.of(context).bossBattleAttack),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        backgroundColor: selected ? AppColors.purpleL : AppColors.surface,
        side: BorderSide(
            color: selected ? AppColors.purple : AppColors.outline, width: 1.5),
      ),
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: selected ? AppColors.purple : AppColors.text1,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
