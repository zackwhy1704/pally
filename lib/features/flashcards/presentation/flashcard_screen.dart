import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: notifier.refresh,
          ),
        ],
      ),
      body: state.isLoading
          ? const PallyLoadingSpinner()
          : state.error != null
              ? _ErrorView(onRetry: notifier.refresh)
              : Column(
                  children: [
                    _FilterChips(
                      selected: state.filter,
                      onSelect: notifier.setFilter,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (!state.hasCards)
                      const Expanded(child: _EmptyFilterView())
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
                Text(sourceFile!,
                    style: AppTextStyles.caption
                        .copyWith(fontStyle: FontStyle.italic)),
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

class _EmptyFilterView extends StatelessWidget {
  const _EmptyFilterView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.style_rounded, size: 60, color: AppColors.text3),
          const SizedBox(height: AppSpacing.md),
          Text('No cards in this filter', style: AppTextStyles.body),
        ],
      ),
    );
  }
}

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
          Text('Could not load flashcards', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
