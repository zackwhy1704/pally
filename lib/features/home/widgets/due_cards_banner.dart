import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/flashcards/providers/due_cards_summary_provider.dart';

/// Compact banner at the top of Home that surfaces flashcards due for review
/// across all tutors. Hidden when nothing is due. Tap → first tutor with
/// due cards.
class DueCardsBanner extends ConsumerWidget {
  const DueCardsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dueCardsSummaryProvider);
    return summaryAsync.maybeWhen(
      data: (summary) {
        if (summary.isEmpty || summary.firstDueAvatar == null) {
          return const SizedBox.shrink();
        }
        final count = summary.totalDue;
        final avatar = summary.firstDueAvatar!;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
          child: Material(
            color: AppColors.amberL,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () =>
                  FlashcardRoute(avatarId: avatar.id).push(context),
              child: Padding(
                padding: AppSpacing.card,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$count flashcard${count == 1 ? '' : 's'} due',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.text1,
                            ),
                          ),
                          Text(
                            'Start with ${avatar.name} — 2-min review',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.text2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.text2, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
