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
import 'package:pally/features/boss_battle/presentation/boss_battle_game.dart';
import 'package:pally/features/classroom/presentation/classroom_session_view_model.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/shared/models/classroom_state.dart';

/// Live shared-boss classroom battle. Server-authoritative, same invariant
/// as the solo boss battle: this screen computes nothing — it renders the
/// live-pushed collective HP and other participants' hits as they land, via
/// nothing more than their ambient nickname. No roster, no chat, no way to
/// see a classmate's persistent profile.
class ClassroomBattleScreen extends ConsumerStatefulWidget {
  const ClassroomBattleScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  ConsumerState<ClassroomBattleScreen> createState() =>
      _ClassroomBattleScreenState();
}

class _ClassroomBattleScreenState extends ConsumerState<ClassroomBattleScreen> {
  BossBattleGame? _game;
  int? _lastHpSeen;

  @override
  Widget build(BuildContext context) {
    final vmState =
        ref.watch(classroomSessionViewModelProvider(widget.avatarId));
    final classroomState = vmState.state;

    if (classroomState != null && !classroomState.defeated) {
      _game ??= BossBattleGame(
          hpMax: classroomState.hpMax, hpRemaining: classroomState.hpRemaining);
      final hitLanded = _lastHpSeen == null
          ? null
          : (classroomState.hpRemaining < _lastHpSeen! ? true : null);
      _game!.updateBattleState(
        hpRemaining: classroomState.hpRemaining,
        hpMax: classroomState.hpMax,
        hitLanded: hitLanded,
      );
      _lastHpSeen = classroomState.hpRemaining;
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
        title: Text(AppLocalizations.of(context).classroomBattleTitle,
            style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: SafeArea(child: _buildBody(context, vmState)),
    );
  }

  Widget _buildBody(BuildContext context, ClassroomSessionState vmState) {
    final classroomState = vmState.state;
    if (classroomState == null) {
      return Center(
        child: Text(AppLocalizations.of(context).classroomNotJoinedYet,
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center),
      );
    }
    if (classroomState.status == 'ENDED') {
      return _EndedCard(nickname: vmState.nickname);
    }
    if (classroomState.defeated) {
      return _VictoryCard();
    }
    return _LiveBattleView(
      vmState: vmState,
      classroomState: classroomState,
      game: _game!,
      onSelect: (i) => ref
          .read(classroomSessionViewModelProvider(widget.avatarId).notifier)
          .selectAnswer(i),
      onAttack: () => ref
          .read(classroomSessionViewModelProvider(widget.avatarId).notifier)
          .attack(),
    );
  }
}

class _EndedCard extends StatelessWidget {
  const _EndedCard({this.nickname});
  final String? nickname;

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
                  color: AppColors.surf2, shape: BoxShape.circle),
              child: const Icon(Icons.flag_circle_rounded,
                  color: AppColors.text2, size: 36),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(AppLocalizations.of(context).classroomSessionEnded,
                style: AppTextStyles.title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _VictoryCard extends StatelessWidget {
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
                  color: AppColors.tealL, shape: BoxShape.circle),
              child: const Icon(Icons.celebration_rounded,
                  color: AppColors.teal, size: 36),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(AppLocalizations.of(context).classroomBossDefeated,
                style: AppTextStyles.heading1, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _LiveBattleView extends StatelessWidget {
  const _LiveBattleView({
    required this.vmState,
    required this.classroomState,
    required this.game,
    required this.onSelect,
    required this.onAttack,
  });

  final ClassroomSessionState vmState;
  final ClassroomState classroomState;
  final BossBattleGame game;
  final ValueChanged<int> onSelect;
  final VoidCallback onAttack;

  @override
  Widget build(BuildContext context) {
    final question = classroomState.currentQuestion;

    // AdaptiveCenter is ALREADY a scrollable (SafeArea + SingleChildScrollView
    // + IntrinsicHeight internally) — it must be the outermost/sole scroll
    // wrapper; nesting it inside another SingleChildScrollView gives it
    // infinite height and crashes layout.
    return AdaptiveCenter(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
              AppLocalizations.of(context)
                  .classroomParticipantCount(classroomState.participantCount),
              style: AppTextStyles.label.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(
              AppLocalizations.of(context).bossBattleHpRemaining(
                  classroomState.hpRemaining, classroomState.hpMax),
              style: AppTextStyles.label.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(height: 220, child: GameWidget<BossBattleGame>(game: game)),
          if (vmState.recentHits.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: vmState.recentHits.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.xs),
                itemBuilder: (_, i) {
                  final hit = vmState.recentHits[i];
                  return Chip(
                    label: Text(hit.nickname, overflow: TextOverflow.ellipsis),
                    avatar: Icon(
                      hit.hitLanded ? Icons.check_circle : Icons.close,
                      color: hit.hitLanded ? AppColors.green : AppColors.text3,
                      size: 16,
                    ),
                    backgroundColor:
                        hit.hitLanded ? AppColors.tealL : AppColors.surf2,
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (question != null) ...[
            Text(question.question, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < question.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _OptionButton(
                  label: question.options[i],
                  selected: vmState.selectedIndex == i,
                  onTap: vmState.isAttacking ? null : () => onSelect(i),
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (vmState.error != null) ...[
            PallyErrorCard(
                message: vmState.error!.userMessage, onRetry: onAttack),
            const SizedBox(height: AppSpacing.sm),
          ],
          SizedBox(
            height: AppSizing.buttonHeight,
            child: FilledButton(
              onPressed: (vmState.isAttacking || vmState.selectedIndex == null)
                  ? null
                  : onAttack,
              style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
              child: vmState.isAttacking
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
  const _OptionButton(
      {required this.label, required this.selected, required this.onTap});

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
        style: AppTextStyles.body
            .copyWith(color: selected ? AppColors.purple : AppColors.text1),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
