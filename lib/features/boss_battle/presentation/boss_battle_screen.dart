import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/adaptive_center.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bossBattleViewModelProvider(widget.avatarId));

    // Push server-truth HP/outcome into the already-running game instance —
    // never recreate the game on every rebuild (that would reset its state).
    final boss = state.boss;
    if (boss != null && boss.active && !boss.defeated) {
      _game ??=
          BossBattleGame(hpMax: boss.hpMax, hpRemaining: boss.hpRemaining);
      _game!.updateBattleState(
        hpRemaining: boss.hpRemaining,
        hpMax: boss.hpMax,
        hitLanded: state.lastHitLanded,
      );
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
        onRetry: () => ref
            .read(bossBattleViewModelProvider(widget.avatarId).notifier)
            .retry(),
      );
    }
    final boss = state.boss;
    if (boss == null || !boss.active) {
      return const _NoBossCard();
    }
    if (boss.defeated) {
      return _VictoryCard(boss: boss);
    }
    return _BattleView(
      state: state,
      game: _game!,
      onSelect: (i) => ref
          .read(bossBattleViewModelProvider(widget.avatarId).notifier)
          .selectAnswer(i),
      onAttack: () => ref
          .read(bossBattleViewModelProvider(widget.avatarId).notifier)
          .attack(),
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

class _VictoryCard extends StatelessWidget {
  const _VictoryCard({required this.boss});
  final BossState boss;

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
              const SizedBox(height: AppSpacing.sm),
              Text(
                  AppLocalizations.of(context).bossBattleRewardMessage(
                      AppLocalizations.of(context).mascotName),
                  style: AppTextStyles.body.copyWith(color: AppColors.text2),
                  textAlign: TextAlign.center),
            ],
          ],
        ),
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

    // AdaptiveCenter is ALREADY a scrollable (SafeArea + SingleChildScrollView
    // + IntrinsicHeight internally) — nesting it inside another
    // SingleChildScrollView gives it infinite height and crashes layout.
    // It must be the outermost/sole scroll wrapper here.
    return AdaptiveCenter(
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
            PallyErrorCard(
                message: state.error!.userMessage, onRetry: onAttack),
            const SizedBox(height: AppSpacing.sm),
          ],
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
