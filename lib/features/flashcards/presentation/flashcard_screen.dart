import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/no_notes_cta.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/adaptive_center.dart';
import 'package:pally/core/ui/pally_error_card.dart';
// pally_loading_spinner removed — replaced by _GeneratingView inline
import 'package:pally/features/flashcards/presentation/flashcard_view_model.dart';
import 'package:pally/shared/models/flash_card.dart';

class FlashcardScreen extends ConsumerWidget {
  const FlashcardScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(flashCardViewModelProvider(avatarId));
    final notifier = ref.read(flashCardViewModelProvider(avatarId).notifier);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Flashcards', style: AppTextStyles.title),
        centerTitle: true,
        actions: [
          // Regenerate action — visible when cards exist or pages exist
          if (!state.isGenerating && !state.isLoading)
            IconButton(
              icon: const Icon(Icons.auto_fix_high_rounded),
              tooltip: 'Regenerate cards',
              onPressed: notifier.generateCards,
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: notifier.refresh,
          ),
        ],
      ),
      body: state.isLoading || state.isGenerating
          ? _GeneratingView(isGenerating: state.isGenerating)
          : state.error != null
              ? PallyErrorCard(
                  message: state.error ?? 'Something went wrong — try again.',
                  onRetry: notifier.refresh,
                )
              : Column(
                  children: [
                    // Only show filters when there are cards to filter
                    if (state.cards.isNotEmpty)
                      _FilterChips(
                        selected: state.filter,
                        onSelect: notifier.setFilter,
                      ),
                    if (state.cards.isNotEmpty)
                      const SizedBox(height: AppSpacing.md),
                    if (!state.hasCards)
                      Expanded(
                        child: _EmptyState(
                          avatarId: avatarId,
                          hasWikiPages: state.hasWikiPages,
                          filter: state.filter,
                          totalCards: state.cards.length,
                          onGenerate: notifier.generateCards,
                        ),
                      )
                    else ...[
                      _CardCounter(
                        current: state.currentIndex + 1,
                        total: state.totalFiltered,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Expanded(
                        child: _FlipCardView(
                          card: state.currentCard!,
                          isFlipped: state.isFlipped,
                          onTap: notifier.flip,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (state.isFlipped)
                        _RatingRow(
                          isRating: state.isRating,
                          onRate: notifier.rate,
                        ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ],
                ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelect});

  final FlashCardFilter selected;
  final ValueChanged<FlashCardFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    const filters = [
      (FlashCardFilter.all, 'All'),
      (FlashCardFilter.due, 'Due'),
      (FlashCardFilter.weak, 'Weak'),
      (FlashCardFilter.done, 'Done'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: filters.map((entry) {
          final (filter, label) = entry;
          final isSelected = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onSelect(filter),
              selectedColor: AppColors.purpleL,
              checkmarkColor: AppColors.purple,
              labelStyle: AppTextStyles.label.copyWith(
                color: isSelected ? AppColors.purple : AppColors.text2,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.purple : AppColors.outline,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CardCounter extends StatelessWidget {
  const _CardCounter({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$current / $total',
      style: AppTextStyles.label.copyWith(color: AppColors.text3),
      textAlign: TextAlign.center,
    );
  }
}

class _FlipCardView extends StatelessWidget {
  const _FlipCardView({
    required this.card,
    required this.isFlipped,
    required this.onTap,
  });

  final FlashCard card;
  final bool isFlipped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: isFlipped
              ? _CardFace(
                  key: const ValueKey('back'),
                  text: card.back,
                  label: 'Answer',
                  bgColor: AppColors.tealL,
                  labelColor: AppColors.teal,
                  icon: Icons.lightbulb_rounded,
                  sourceFile: card.sourceFile,
                )
              : _CardFace(
                  key: const ValueKey('front'),
                  text: card.front,
                  label: 'Question',
                  bgColor: AppColors.purpleL,
                  labelColor: AppColors.purple,
                  icon: Icons.help_outline_rounded,
                ),
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    super.key,
    required this.text,
    required this.label,
    required this.bgColor,
    required this.labelColor,
    required this.icon,
    this.sourceFile,
  });

  final String text;
  final String label;
  final Color bgColor;
  final Color labelColor;
  final IconData icon;
  final String? sourceFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: labelColor.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: labelColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: labelColor),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            text,
            style: AppTextStyles.title.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          if (sourceFile != null && sourceFile!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.source_rounded,
                    size: 12, color: AppColors.text3),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(sourceFile!,
                      style: AppTextStyles.caption
                          .copyWith(fontStyle: FontStyle.italic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tap to flip',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.isRating, required this.onRate});

  final bool isRating;
  final Future<void> Function(CardRating) onRate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _RateButton(
              label: 'Hard',
              color: AppColors.coral,
              bgColor: AppColors.coralL,
              icon: Icons.sentiment_dissatisfied_rounded,
              isLoading: isRating,
              onTap: () => onRate(CardRating.hard),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _RateButton(
              label: 'Okay',
              color: AppColors.amber,
              bgColor: AppColors.amberL,
              icon: Icons.sentiment_neutral_rounded,
              isLoading: isRating,
              onTap: () => onRate(CardRating.okay),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _RateButton(
              label: 'Easy',
              color: AppColors.teal,
              bgColor: AppColors.tealL,
              icon: Icons.sentiment_satisfied_rounded,
              isLoading: isRating,
              onTap: () => onRate(CardRating.easy),
            ),
          ),
        ],
      ),
    );
  }
}

class _RateButton extends StatelessWidget {
  const _RateButton({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown while the auto-generate or manual generate call is in progress.
class _GeneratingView extends StatelessWidget {
  const _GeneratingView({required this.isGenerating});
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    return AdaptiveCenter(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.purple),
          const SizedBox(height: AppSpacing.md),
          Text(
            isGenerating
                ? 'Making flashcards from your notes...'
                : 'Loading...',
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Context-aware empty state — explains WHY it's empty and what to do.
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.avatarId,
    required this.hasWikiPages,
    required this.filter,
    required this.totalCards,
    required this.onGenerate,
  });

  final String avatarId;
  final bool? hasWikiPages;
  final FlashCardFilter filter;
  final int totalCards;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    // Case 1: Cards exist but none match the active filter.
    if (totalCards > 0) {
      final (icon, message) = switch (filter) {
        FlashCardFilter.due => (
            Icons.check_circle_outline_rounded,
            'All caught up! No cards due right now.\nCome back later or switch to All.',
          ),
        FlashCardFilter.weak => (
            Icons.thumb_up_rounded,
            'No weak cards yet.\nRate some cards hard to see them here.',
          ),
        FlashCardFilter.done => (
            Icons.hourglass_empty_rounded,
            'No easy cards yet.\nRate some cards easy to see them here.',
          ),
        _ => (Icons.style_rounded, 'No cards in this filter.'),
      };
      return AdaptiveCenter(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppColors.text3),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Case 2: No cards at all AND no wiki pages — needs an upload first.
    if (hasWikiPages == false) {
      return AdaptiveCenter(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📚', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            Text('No flashcards yet',
                style: AppTextStyles.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            NoNotesCta(
              avatarId: avatarId,
              personalDescription:
                  'Upload notes or a document for this Mochi and cards will be made automatically.',
            ),
          ],
        ),
      );
    }

    // Case 3: Has wiki pages but 0 cards — silent generation failure.
    // hasWikiPages == true OR null (still unknown / checking).
    return AdaptiveCenter(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✨', style: TextStyle(fontSize: 56)),
          const SizedBox(height: AppSpacing.md),
          Text('Ready to make cards',
              style: AppTextStyles.title, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your Mochi has notes but no cards yet.\nTap the button below to generate them.',
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onGenerate,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
            label: const Text('Generate flashcards'),
          ),
        ],
      ),
    );
  }
}

