import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/shared/models/learning_module.dart';

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
  });

  final List<ModuleContentItem> items;
  final PageController pageController;
  final int currentIndex;
  final VoidCallback onNext;
  final bool isLast;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress dots
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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

class MicroCard extends StatelessWidget {
  const MicroCard({
    super.key,
    required this.item,
    required this.cardNumber,
    required this.total,
  });

  final ModuleContentItem item;
  final int cardNumber;
  final int total;

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
          border: Border.all(color: AppColors.outline),
        ),
        child: SingleChildScrollView(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Card $cardNumber of $total',
                style: AppTextStyles.caption.copyWith(color: AppColors.teal),
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
