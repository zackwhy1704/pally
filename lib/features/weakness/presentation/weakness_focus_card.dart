import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/weakness/data/weakness_focus.dart';
import 'package:pally/features/weakness/data/weakness_service.dart';

/// The student-visible "closing the loop" card: shows what Mochi is focusing on
/// (their weak spots, framed forward-looking) + a celebration of topics they
/// recently improved on. Renders NOTHING until the pilot flag is on and there's
/// content — so it's invisible in the default (flag-off) state.
class WeaknessFocusCard extends ConsumerWidget {
  const WeaknessFocusCard({super.key, required this.backendSubject});

  final String backendSubject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focus = ref.watch(weaknessFocusProvider(backendSubject));
    return focus.maybeWhen(
      data: (f) => f.hasContent ? _card(f) : const SizedBox.shrink(),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _card(WeaknessFocus f) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.purpleL,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (f.recentWins.isNotEmpty) ...[
            Row(
              children: [
                const Text('✅', style: TextStyle(fontSize: 16)),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    'You improved on ${_pretty(f.recentWins)}! 📈',
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.green, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (f.focusAreas.isNotEmpty) const SizedBox(height: AppSpacing.sm),
          ],
          if (f.focusAreas.isNotEmpty) ...[
            Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 16)),
                const SizedBox(width: AppSpacing.xs),
                Text("Let's focus on",
                    style: AppTextStyles.title.copyWith(fontSize: 15)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final a in f.focusAreas)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.purpleC),
                    ),
                    child: Text(a.title,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.purple)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Mochi will help you practise these.',
                style: AppTextStyles.caption.copyWith(color: AppColors.text2)),
          ],
        ],
      ),
    );
  }

  String _pretty(List<String> slugs) {
    final words = slugs
        .take(2)
        .map((s) => s.replaceAll('-', ' ').replaceAll('_', ' '))
        .toList();
    return words.join(' and ');
  }
}
