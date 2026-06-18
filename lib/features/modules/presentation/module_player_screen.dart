import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/adaptive_center.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';
import 'package:pally/features/modules/presentation/widgets/learn_body.dart';
import 'package:pally/features/modules/presentation/widgets/test_body.dart';
import 'package:pally/features/modules/presentation/widgets/prove_body.dart';
import 'package:pally/features/modules/presentation/widgets/muddiest_body.dart';
import 'package:pally/features/modules/presentation/widgets/complete_body.dart';

class ModulePlayerScreen extends ConsumerStatefulWidget {
  const ModulePlayerScreen({
    super.key,
    required this.avatarId,
    required this.moduleId,
  });

  final String avatarId;
  final String moduleId;

  @override
  ConsumerState<ModulePlayerScreen> createState() =>
      _ModulePlayerScreenState();
}

class _ModulePlayerScreenState extends ConsumerState<ModulePlayerScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _stageColor(String stage) => switch (stage) {
        'LEARN' => AppColors.teal,
        'TEST' => AppColors.amber,
        'PROVE' => AppColors.purple,
        'COMPLETE' => AppColors.green,
        _ => AppColors.text3,
      };

  String _stageTitle(String stage) => switch (stage) {
        'LEARN' => 'Learn',
        'TEST' => 'Test',
        'PROVE' => 'Prove',
        'COMPLETE' => 'Complete',
        _ => stage,
      };

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(
      modulePlayerViewModelProvider(widget.avatarId, widget.moduleId),
    );

    // Toast on transient action errors (submit/start failures) so the user
    // knows something failed even when the inline error banner isn't visible.
    ref.listen<ModulePlayerState>(
      modulePlayerViewModelProvider(widget.avatarId, widget.moduleId),
      (prev, next) {
        if (next.error != null && prev?.error != next.error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(next.error!.userMessage),
                backgroundColor: AppColors.coral,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 12),
                duration: const Duration(seconds: 4),
              ),
            );
        }
      },
    );

    final stageColor = _stageColor(playerState.stage);
    final stageTitle = _stageTitle(playerState.stage);

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
        title: playerState.isComplete
            ? Text('Complete', style: AppTextStyles.title)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: stageColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      stageTitle,
                      style: AppTextStyles.label.copyWith(
                        color: stageColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (playerState.totalItems > 0) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${playerState.currentIndex + 1}/${playerState.totalItems}',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.text2),
                    ),
                  ],
                ],
              ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (playerState.isRevision && !playerState.isComplete)
            const RevisionBanner(),
          Expanded(child: _buildBody(playerState)),
        ],
      ),
    );
  }

  Widget _buildBody(ModulePlayerState playerState) {
    if (playerState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purple),
      );
    }

    if (playerState.error != null) {
      return AdaptiveCenter(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.coral),
              const SizedBox(height: AppSpacing.md),
              Text(
                playerState.error!.userMessage,
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => ref
                    .read(modulePlayerViewModelProvider(
                            widget.avatarId, widget.moduleId)
                        .notifier)
                    .startStage(),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple),
                child: const Text('Try again'),
              ),
            ],
          ),
      );
    }

    if (playerState.isComplete) {
      final concepts = playerState.results?.concepts ?? const [];
      // Post-PROVE muddiest-point check: one tap to flag the hardest concept,
      // shown once before the celebration. Skipped automatically when the
      // module reported no concepts to choose between.
      if (!playerState.muddiestSubmitted && concepts.isNotEmpty) {
        final vm = ref.read(
          modulePlayerViewModelProvider(widget.avatarId, widget.moduleId)
              .notifier,
        );
        return MuddiestBody(
          concepts: concepts,
          onPick: vm.submitMuddiest,
          onSkip: vm.skipMuddiest,
        );
      }
      return CompleteBody(
        results: playerState.results,
        onBack: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go('/');
          }
        },
      );
    }

    return switch (playerState.stage) {
      'LEARN' => LearnBody(
          items: playerState.items,
          pageController: _pageController,
          currentIndex: playerState.currentIndex,
          onNext: () {
            final vm = ref.read(
              modulePlayerViewModelProvider(
                      widget.avatarId, widget.moduleId)
                  .notifier,
            );
            if (playerState.isLastItem) {
              vm.submitStage();
            } else {
              vm.nextItem();
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          isLast: playerState.isLastItem,
          isSubmitting: playerState.isSubmitting,
          narration: playerState.narration,
          narrationLoading: playerState.narrationLoading,
          isPlaying: playerState.isPlaying,
          isPlayingAll: playerState.isPlayingAll,
          currentPlayingCard: playerState.currentPlayingCard,
          onPlayCard: (index) => ref
              .read(modulePlayerViewModelProvider(
                      widget.avatarId, widget.moduleId)
                  .notifier)
              .playCard(index),
          onPlayAll: () => ref
              .read(modulePlayerViewModelProvider(
                      widget.avatarId, widget.moduleId)
                  .notifier)
              .playAll(),
          onPause: () => ref
              .read(modulePlayerViewModelProvider(
                      widget.avatarId, widget.moduleId)
                  .notifier)
              .pauseNarration(),
          onFetchNarration: () => ref
              .read(modulePlayerViewModelProvider(
                      widget.avatarId, widget.moduleId)
                  .notifier)
              .fetchNarration(),
        ),
      'TEST' => TestBody(
          item: playerState.currentItem,
          currentIndex: playerState.currentIndex,
          totalItems: playerState.totalItems,
          isRevealed: playerState.currentItem != null &&
              playerState.revealedItems
                  .contains(playerState.currentItem!.id),
          answer: playerState.currentItem != null
              ? playerState.answers[playerState.currentItem!.id]
              : null,
          onAnswer: (itemId, response) {
            final vm = ref.read(
              modulePlayerViewModelProvider(
                      widget.avatarId, widget.moduleId)
                  .notifier,
            );
            vm.setAnswer(itemId, response);
            vm.revealItem(itemId);
          },
          onNext: () {
            final vm = ref.read(
              modulePlayerViewModelProvider(
                      widget.avatarId, widget.moduleId)
                  .notifier,
            );
            if (playerState.isLastItem) {
              vm.submitStage();
            } else {
              vm.nextItem();
            }
          },
          isLast: playerState.isLastItem,
          isSubmitting: playerState.isSubmitting,
        ),
      'PROVE' => ProveBody(
          items: playerState.items,
          answers: playerState.answers,
          onAnswerChanged: (itemId, response) {
            ref
                .read(modulePlayerViewModelProvider(
                        widget.avatarId, widget.moduleId)
                    .notifier)
                .setAnswer(itemId, response);
          },
          onSubmit: () {
            ref
                .read(modulePlayerViewModelProvider(
                        widget.avatarId, widget.moduleId)
                    .notifier)
                .submitStage();
          },
          isSubmitting: playerState.isSubmitting,
        ),
      _ => const Center(child: Text('Unknown stage')),
    };
  }
}
