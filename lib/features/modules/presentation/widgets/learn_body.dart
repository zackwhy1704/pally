import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/shared/models/learning_module.dart';
import 'package:pally/shared/models/narration.dart';

// ── LEARN stage: horizontal swipeable micro-cards ───────────────────────────

class LearnBody extends StatelessWidget {
  const LearnBody({
    super.key,
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
              PlayAllButton(
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
            itemBuilder: (context, index) => MicroCard(
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

class PlayAllButton extends StatelessWidget {
  const PlayAllButton({
    super.key,
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

class MicroCard extends StatelessWidget {
  const MicroCard({
    super.key,
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
                  ListenButton(
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
              RichBodyText(body: body, keyTerms: keyTerms),
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

class ListenButton extends StatelessWidget {
  const ListenButton({
    super.key,
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
class RichBodyText extends StatelessWidget {
  const RichBodyText({super.key, required this.body, required this.keyTerms});
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
