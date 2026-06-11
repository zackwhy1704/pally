import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';
import 'package:pally/shared/models/learning_module.dart';
import 'package:pally/shared/models/narration.dart';

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
            _RevisionBanner(),
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
      return Center(
        child: Padding(
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
        ),
      );
    }

    if (playerState.isComplete) {
      return _CompleteBody(
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
      'LEARN' => _LearnBody(
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
      'TEST' => _TestBody(
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
      'PROVE' => _ProveBody(
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

// ── LEARN stage: horizontal swipeable micro-cards ───────────────────────────

class _LearnBody extends StatelessWidget {
  const _LearnBody({
    required this.items,
    required this.pageController,
    required this.currentIndex,
    required this.onNext,
    required this.isLast,
    required this.isSubmitting,
    required this.narration,
    required this.narrationLoading,
    required this.isPlaying,
    required this.isPlayingAll,
    required this.currentPlayingCard,
    required this.onPlayCard,
    required this.onPlayAll,
    required this.onPause,
    required this.onFetchNarration,
  });

  final List<ModuleContentItem> items;
  final PageController pageController;
  final int currentIndex;
  final VoidCallback onNext;
  final bool isLast;
  final bool isSubmitting;
  final Narration? narration;
  final bool narrationLoading;
  final bool isPlaying;
  final bool isPlayingAll;
  final int currentPlayingCard;
  final void Function(int) onPlayCard;
  final VoidCallback onPlayAll;
  final VoidCallback onPause;
  final VoidCallback onFetchNarration;

  @override
  Widget build(BuildContext context) {
    final hasNarration =
        narration != null && narration!.status == 'READY';

    return Column(
      children: [
        // Progress dots + Play All button
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: List.generate(items.length, (i) {
                    final isActive = i <= currentIndex;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          right: i < items.length - 1 ? 4 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.teal : AppColors.outline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Play All / Pause button
              _PlayAllButton(
                hasNarration: hasNarration,
                isPlaying: isPlaying,
                isPlayingAll: isPlayingAll,
                narrationLoading: narrationLoading,
                onPlayAll: onPlayAll,
                onPause: onPause,
                onFetchNarration: onFetchNarration,
              ),
            ],
          ),
        ),
        // Cards
        Expanded(
          child: PageView.builder(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) => _MicroCard(
              item: items[index],
              cardNumber: index + 1,
              total: items.length,
              isCurrentlyPlaying: currentPlayingCard == index,
              narrationLoading: narrationLoading,
              hasNarration: hasNarration,
              onListen: () => onPlayCard(index),
              onPause: onPause,
              onFetchNarration: onFetchNarration,
            ),
          ),
        ),
        // Next button
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md + MediaQuery.of(context).padding.bottom,
          ),
          child: SizedBox(
            width: double.infinity,
            height: AppSizing.buttonHeight,
            child: FilledButton(
              onPressed: isSubmitting ? null : onNext,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: AppSizing.spinnerSm,
                      height: AppSizing.spinnerSm,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isLast ? 'Ready to test yourself' : 'Next',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Play All button ─────────────────────────────────────────────────────────

class _PlayAllButton extends StatelessWidget {
  const _PlayAllButton({
    required this.hasNarration,
    required this.isPlaying,
    required this.isPlayingAll,
    required this.narrationLoading,
    required this.onPlayAll,
    required this.onPause,
    required this.onFetchNarration,
  });

  final bool hasNarration;
  final bool isPlaying;
  final bool isPlayingAll;
  final bool narrationLoading;
  final VoidCallback onPlayAll;
  final VoidCallback onPause;
  final VoidCallback onFetchNarration;

  @override
  Widget build(BuildContext context) {
    if (narrationLoading) {
      return const SizedBox(
        width: AppSizing.spinnerSm,
        height: AppSizing.spinnerSm,
        child: CircularProgressIndicator(
            strokeWidth: 2, color: AppColors.teal),
      );
    }

    if (isPlayingAll) {
      return GestureDetector(
        onTap: onPause,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.tealL,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_rounded, size: 16, color: AppColors.teal),
              const SizedBox(width: 4),
              Text('Pause',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.teal, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: hasNarration ? onPlayAll : onFetchNarration,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.tealL,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasNarration
                  ? Icons.play_arrow_rounded
                  : Icons.volume_up_rounded,
              size: 16,
              color: AppColors.teal,
            ),
            const SizedBox(width: 4),
            Text(
              hasNarration ? 'Play all' : 'Listen',
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.teal, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _MicroCard extends StatelessWidget {
  const _MicroCard({
    required this.item,
    required this.cardNumber,
    required this.total,
    this.isCurrentlyPlaying = false,
    this.narrationLoading = false,
    this.hasNarration = false,
    this.onListen,
    this.onPause,
    this.onFetchNarration,
  });

  final ModuleContentItem item;
  final int cardNumber;
  final int total;
  final bool isCurrentlyPlaying;
  final bool narrationLoading;
  final bool hasNarration;
  final VoidCallback? onListen;
  final VoidCallback? onPause;
  final VoidCallback? onFetchNarration;

  @override
  Widget build(BuildContext context) {
    final content = item.contentJson;
    final title = content['title'] as String? ?? 'Card $cardNumber';
    final body = content['body'] as String? ?? '';
    final keyTerms = (content['keyTerms'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrentlyPlaying ? AppColors.teal : AppColors.outline,
            width: isCurrentlyPlaying ? 2 : 1,
          ),
        ),
        child: SingleChildScrollView(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Card $cardNumber of $total',
                      style:
                          AppTextStyles.caption.copyWith(color: AppColors.teal),
                    ),
                  ),
                  // Listen / Pause button
                  _ListenButton(
                    isPlaying: isCurrentlyPlaying,
                    isLoading: narrationLoading,
                    hasNarration: hasNarration,
                    onListen: onListen,
                    onPause: onPause,
                    onFetchNarration: onFetchNarration,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(title, style: AppTextStyles.heading1),
              const SizedBox(height: AppSpacing.md),
              _RichBodyText(body: body, keyTerms: keyTerms),
              if (keyTerms.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('Key terms',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.teal, fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: keyTerms
                      .map((t) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.tealL,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(t,
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.teal,
                                    fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Listen button on each micro-card ────────────────────────────────────────

class _ListenButton extends StatelessWidget {
  const _ListenButton({
    required this.isPlaying,
    required this.isLoading,
    required this.hasNarration,
    this.onListen,
    this.onPause,
    this.onFetchNarration,
  });

  final bool isPlaying;
  final bool isLoading;
  final bool hasNarration;
  final VoidCallback? onListen;
  final VoidCallback? onPause;
  final VoidCallback? onFetchNarration;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: AppSizing.spinnerXs,
        height: AppSizing.spinnerXs,
        child: CircularProgressIndicator(
            strokeWidth: 1.5, color: AppColors.teal),
      );
    }

    if (isPlaying) {
      return GestureDetector(
        onTap: onPause,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppColors.tealL,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.pause_rounded,
              size: AppSizing.iconSm, color: AppColors.teal),
        ),
      );
    }

    return GestureDetector(
      onTap: hasNarration ? onListen : onFetchNarration,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: AppColors.tealL,
          shape: BoxShape.circle,
        ),
        child: Icon(
          hasNarration ? Icons.volume_up_rounded : Icons.volume_up_outlined,
          size: AppSizing.iconSm,
          color: AppColors.teal,
        ),
      ),
    );
  }
}

/// Renders body text with key terms bolded.
class _RichBodyText extends StatelessWidget {
  const _RichBodyText({required this.body, required this.keyTerms});
  final String body;
  final List<String> keyTerms;

  @override
  Widget build(BuildContext context) {
    if (keyTerms.isEmpty) {
      return Text(body, style: AppTextStyles.body);
    }

    // Build a regex that matches any key term (case-insensitive)
    final pattern = keyTerms
        .map((t) => RegExp.escape(t))
        .join('|');
    final regex = RegExp('($pattern)', caseSensitive: false);

    final spans = <TextSpan>[];
    int lastEnd = 0;
    for (final match in regex.allMatches(body)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: body.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < body.length) {
      spans.add(TextSpan(text: body.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: AppTextStyles.body,
        children: spans,
      ),
    );
  }
}

// ── TEST stage: sequential items ────────────────────────────────────────────

class _TestBody extends StatelessWidget {
  const _TestBody({
    required this.item,
    required this.currentIndex,
    required this.totalItems,
    required this.isRevealed,
    required this.answer,
    required this.onAnswer,
    required this.onNext,
    required this.isLast,
    required this.isSubmitting,
  });

  final ModuleContentItem? item;
  final int currentIndex;
  final int totalItems;
  final bool isRevealed;
  final String? answer;
  final void Function(String itemId, String response) onAnswer;
  final VoidCallback onNext;
  final bool isLast;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return const Center(child: Text('No items'));
    }

    return Column(
      children: [
        // Progress dots
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: List.generate(totalItems, (i) {
              final isActive = i <= currentIndex;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < totalItems - 1 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.amber : AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildItemWidget(context),
          ),
        ),
        if (isRevealed)
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md + MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              height: AppSizing.buttonHeight,
              child: FilledButton(
                onPressed: isSubmitting ? null : onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: AppSizing.spinnerSm,
                        height: AppSizing.spinnerSm,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        isLast ? 'Time to prove you understand' : 'Next',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildItemWidget(BuildContext context) {
    final content = item!.contentJson;
    return switch (item!.type) {
      'HOT_TAKE' => _HotTakeCard(
          statement: content['statement'] as String? ?? '',
          explanation: content['explanation'] as String? ?? '',
          isCorrect: content['isCorrect'] as bool? ?? true,
          isRevealed: isRevealed,
          answer: answer,
          onAnswer: (response) => onAnswer(item!.id, response),
        ),
      'SPOT_MISTAKE' => _SpotMistakeCard(
          problem: content['problem'] as String? ?? '',
          wrongSolution: content['wrongSolution'] as String? ?? '',
          errorDescription: content['errorDescription'] as String? ?? '',
          correctSolution: content['correctSolution'] as String? ?? '',
          isRevealed: isRevealed,
          onReveal: () => onAnswer(item!.id, 'found'),
        ),
      'CHALLENGE' => _ChallengeCard(
          question: content['question'] as String? ?? '',
          explanation: content['explanation'] as String? ?? '',
          isRevealed: isRevealed,
          answer: answer ?? '',
          onSubmit: (response) => onAnswer(item!.id, response),
        ),
      _ => _GenericTestCard(
          content: content,
          isRevealed: isRevealed,
          onAnswer: (response) => onAnswer(item!.id, response),
        ),
    };
  }
}

class _HotTakeCard extends StatelessWidget {
  const _HotTakeCard({
    required this.statement,
    required this.explanation,
    required this.isCorrect,
    required this.isRevealed,
    required this.answer,
    required this.onAnswer,
  });

  final String statement;
  final String explanation;
  final bool isCorrect;
  final bool isRevealed;
  final String? answer;
  final void Function(String) onAnswer;

  @override
  Widget build(BuildContext context) {
    final userAgreed = answer == 'AGREE';
    final wasRight =
        isRevealed && ((userAgreed && isCorrect) || (!userAgreed && !isCorrect));

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('True or False?',
              style: AppTextStyles.label.copyWith(
                  color: AppColors.amber, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          Text(statement, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          if (!isRevealed)
            Row(
              children: [
                Expanded(
                  child: _AnswerButton(
                    label: 'Agree',
                    color: AppColors.green,
                    onTap: () => onAnswer('AGREE'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _AnswerButton(
                    label: 'Disagree',
                    color: AppColors.coral,
                    onTap: () => onAnswer('DISAGREE'),
                  ),
                ),
              ],
            ),
          if (isRevealed) ...[
            Container(
              width: double.infinity,
              padding: AppSpacing.card,
              decoration: BoxDecoration(
                color: wasRight ? AppColors.greenL : AppColors.coralL,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        wasRight
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: wasRight ? AppColors.green : AppColors.coral,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        wasRight ? 'Correct!' : 'Not quite',
                        style: AppTextStyles.body.copyWith(
                          color:
                              wasRight ? AppColors.green : AppColors.coral,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(explanation, style: AppTextStyles.body),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizing.buttonHeight,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotMistakeCard extends StatelessWidget {
  const _SpotMistakeCard({
    required this.problem,
    required this.wrongSolution,
    required this.errorDescription,
    required this.correctSolution,
    required this.isRevealed,
    required this.onReveal,
  });

  final String problem;
  final String wrongSolution;
  final String errorDescription;
  final String correctSolution;
  final bool isRevealed;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spot the mistake',
              style: AppTextStyles.label.copyWith(
                  color: AppColors.amber, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          Text(problem, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: AppSpacing.card,
            decoration: BoxDecoration(
              color: AppColors.coralL,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.coral.withValues(alpha: 0.3)),
            ),
            child: Text(wrongSolution,
                style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!isRevealed)
            SizedBox(
              width: double.infinity,
              height: AppSizing.buttonHeight,
              child: OutlinedButton(
                onPressed: onReveal,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.amber,
                  side: const BorderSide(color: AppColors.amber),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('I found it!'),
              ),
            ),
          if (isRevealed) ...[
            Container(
              width: double.infinity,
              padding: AppSpacing.card,
              decoration: BoxDecoration(
                color: AppColors.greenL,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('The error:',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(errorDescription, style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Correct solution:',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.green,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(correctSolution, style: AppTextStyles.body),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatefulWidget {
  const _ChallengeCard({
    required this.question,
    required this.explanation,
    required this.isRevealed,
    required this.answer,
    required this.onSubmit,
  });

  final String question;
  final String explanation;
  final bool isRevealed;
  final String answer;
  final void Function(String) onSubmit;

  @override
  State<_ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<_ChallengeCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.answer);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Challenge',
              style: AppTextStyles.label.copyWith(
                  color: AppColors.amber, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          Text(widget.question, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          if (!widget.isRevealed) ...[
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Type your answer...',
                hintStyle:
                    AppTextStyles.body.copyWith(color: AppColors.text3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.amber),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: AppSizing.buttonHeight,
              child: FilledButton(
                onPressed: _controller.text.trim().isEmpty
                    ? null
                    : () => widget.onSubmit(_controller.text.trim()),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
          if (widget.isRevealed) ...[
            Container(
              width: double.infinity,
              padding: AppSpacing.card,
              decoration: BoxDecoration(
                color: AppColors.amberL,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your answer:',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.text2)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(widget.answer, style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Explanation:',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.amber,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(widget.explanation, style: AppTextStyles.body),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GenericTestCard extends StatelessWidget {
  const _GenericTestCard({
    required this.content,
    required this.isRevealed,
    required this.onAnswer,
  });

  final Map<String, dynamic> content;
  final bool isRevealed;
  final void Function(String) onAnswer;

  @override
  Widget build(BuildContext context) {
    final question = content['question'] as String? ?? '';
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          if (!isRevealed)
            SizedBox(
              width: double.infinity,
              height: AppSizing.buttonHeight,
              child: FilledButton(
                onPressed: () => onAnswer('answered'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Answer'),
              ),
            ),
        ],
      ),
    );
  }
}

// ── PROVE stage: all short-answer questions ─────────────────────────────────

class _ProveBody extends StatelessWidget {
  const _ProveBody({
    required this.items,
    required this.answers,
    required this.onAnswerChanged,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final List<ModuleContentItem> items;
  final Map<String, String> answers;
  final void Function(String itemId, String response) onAnswerChanged;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final allAnswered = items.every(
        (item) => (answers[item.id] ?? '').trim().isNotEmpty);

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = items[index];
              final question =
                  item.contentJson['question'] as String? ?? '';
              return _ProveQuestion(
                questionNumber: index + 1,
                question: question,
                answer: answers[item.id] ?? '',
                onChanged: (value) => onAnswerChanged(item.id, value),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md + MediaQuery.of(context).padding.bottom,
          ),
          child: SizedBox(
            width: double.infinity,
            height: AppSizing.buttonHeight,
            child: FilledButton(
              onPressed: isSubmitting || !allAnswered ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: AppSizing.spinnerSm,
                      height: AppSizing.spinnerSm,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Submit all answers'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProveQuestion extends StatefulWidget {
  const _ProveQuestion({
    required this.questionNumber,
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  final int questionNumber;
  final String question;
  final String answer;
  final ValueChanged<String> onChanged;

  @override
  State<_ProveQuestion> createState() => _ProveQuestionState();
}

class _ProveQuestionState extends State<_ProveQuestion> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.answer);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          Text(
            'Question ${widget.questionNumber}',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.purple, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(widget.question, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            maxLines: 3,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: 'Write your answer (1-3 sentences)...',
              hintStyle:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.text3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.purple),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── COMPLETE stage ──────────────────────────────────────────────────────────

class _CompleteBody extends StatelessWidget {
  const _CompleteBody({required this.results, required this.onBack});
  final ModuleResults? results;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final concepts = results?.concepts ?? const [];
    final xpEarned = results?.xpEarned ?? 0;

    // Find the weakest concept for recommendation
    ConceptMastery? weakest;
    for (final c in concepts) {
      if (weakest == null || c.mastery < weakest.mastery) {
        weakest = c;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          // Celebration
          Container(
            width: MediaQuery.of(context).size.shortestSide * 0.3,
            height: MediaQuery.of(context).size.shortestSide * 0.3,
            decoration: const BoxDecoration(
              color: AppColors.greenL,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.celebration_rounded,
                  size: 48, color: AppColors.green),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Module complete!', style: AppTextStyles.heading1),
          if (xpEarned > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.amberL,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+$xpEarned XP',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.amber,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],

          // Mastery bars
          if (concepts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Your mastery',
                style: AppTextStyles.title.copyWith(fontSize: 16)),
            const SizedBox(height: AppSpacing.md),
            ...concepts.map((c) => _MasteryRow(concept: c)),
          ],

          // Weakest concept recommendation
          if (weakest != null && !weakest.passed) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: AppSpacing.card,
              decoration: BoxDecoration(
                color: AppColors.amberL,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.amber.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Focus area',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.amber,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Review "${weakest.concept}" to improve your mastery.',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: AppSizing.buttonHeight,
            child: FilledButton(
              onPressed: onBack,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Back to modules'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }
}

class _MasteryRow extends StatelessWidget {
  const _MasteryRow({required this.concept});
  final ConceptMastery concept;

  @override
  Widget build(BuildContext context) {
    final pct = (concept.mastery * 100).round();
    final color = concept.passed ? AppColors.green : AppColors.amber;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                concept.passed
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                size: 16,
                color: color,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  concept.concept,
                  style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('$pct%',
                  style: AppTextStyles.label.copyWith(
                      color: color, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: concept.mastery.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.outline,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (concept.feedback.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(concept.feedback,
                style: AppTextStyles.caption.copyWith(color: AppColors.text2)),
          ],
        ],
      ),
    );
  }
}

// ── Revision mode banner ───────────────────────────────────────────────────

class _RevisionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.purpleL,
      child: Row(
        children: [
          const Icon(Icons.replay_rounded, size: 18, color: AppColors.purple),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Revision mode — fresh questions to check your progress.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.purple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
