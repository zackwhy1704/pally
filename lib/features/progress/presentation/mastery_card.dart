import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/progress/presentation/coverage_provider.dart';
import 'package:pally/shared/models/coverage_summary.dart';

/// Headline mastery card — "You've mastered 18 of 42 topics" with a per
/// -subject breakdown. The Khan-style North Star metric.
class MasteryCard extends ConsumerWidget {
  const MasteryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(coverageProvider);
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (c) {
        if (c.overall.total == 0) return const SizedBox.shrink();
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
              Row(
                children: [
                  const Text('🧠', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: AppTextStyles.title,
                        children: [
                          const TextSpan(text: "You've mastered "),
                          TextSpan(
                            text: '${c.overall.mastered} of ${c.overall.total}',
                            style: AppTextStyles.title
                                .copyWith(color: AppColors.purple),
                          ),
                          const TextSpan(text: ' topics'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _ratio(c.overall.mastered, c.overall.total),
                  backgroundColor: AppColors.outline,
                  valueColor: const AlwaysStoppedAnimation(AppColors.purple),
                  minHeight: 8,
                ),
              ),
              if (c.bySubject.length > 1) ...[
                const SizedBox(height: AppSpacing.md),
                for (final s in c.bySubject.take(4)) _SubjectRow(subject: s),
              ],
            ],
          ),
        );
      },
    );
  }

  static double _ratio(int n, int d) =>
      d == 0 ? 0 : (n / math.max(1, d)).clamp(0.0, 1.0);
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.subject});
  final SubjectCoverage subject;

  String _pretty(String raw) {
    return raw
        .toLowerCase()
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final ratio = subject.total == 0 ? 0.0 : subject.mastered / subject.total;
    final pct = (ratio * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _pretty(subject.subject),
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('${subject.mastered}/${subject.total}  $pct%',
                  style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              backgroundColor: AppColors.outline,
              valueColor: const AlwaysStoppedAnimation(AppColors.teal),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
