import 'package:flutter/material.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/features/chat/presentation/widgets/answer_card.dart';
import 'package:pally/shared/models/photo_question.dart';

class HomeworkScanResultBubble extends StatefulWidget {
  const HomeworkScanResultBubble({super.key, required this.result});

  final HomeworkScanResult result;

  @override
  State<HomeworkScanResultBubble> createState() =>
      _HomeworkScanResultBubbleState();
}

class _HomeworkScanResultBubbleState extends State<HomeworkScanResultBubble> {
  late List<bool> _expanded;

  static const List<Color> _colors = [
    AppColors.teal,
    AppColors.green,
    AppColors.purple,
    AppColors.amber,
  ];

  @override
  void initState() {
    super.initState();
    // First answer expanded by default
    _expanded = List.generate(
      widget.result.answers.length,
      (i) => i == 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final answers = widget.result.answers;

    return Padding(
      padding: const EdgeInsets.only(
          left: AppSpacing.md, right: AppSpacing.md, bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: () => HomeworkScanDetailRoute($extra: widget.result)
            .push<void>(context),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _ResultHeader(count: answers.length),
          const SizedBox(height: AppSpacing.sm),

          // Answer cards
          ...answers.asMap().entries.map((entry) {
            final i = entry.key;
            final answer = entry.value;
            final color = _colors[i % _colors.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AnswerCard(
                answer: answer,
                questionNumber: i + 1,
                color: color,
                isExpanded: i < _expanded.length && _expanded[i],
                onToggle: () {
                  if (i < _expanded.length) {
                    setState(() => _expanded[i] = !_expanded[i]);
                  }
                },
              ),
            );
          }),

          // XP badge
          _XpBadge(xp: widget.result.xpEarned),
          const SizedBox(height: AppSpacing.sm),

          // Follow-up chips
          _FollowUpChips(),

          // Source citation
          if (widget.result.sourceWikiPage != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: _SourceBadge(pageSlug: widget.result.sourceWikiPage!),
            ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap to view full results →',
            style: AppTextStyles.caption.copyWith(color: AppColors.text3),
          ),
        ],
        ),
      ),
    );
  }
}

// ── Result header ─────────────────────────────────────────────────────────────

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.purpleL,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            'Solved $count question${count == 1 ? '' : 's'}!',
            style:
                AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── XP badge ─────────────────────────────────────────────────────────────────

class _XpBadge extends StatelessWidget {
  const _XpBadge({required this.xp});
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.amberL,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '+$xp XP earned',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.amber,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Follow-up chips ──────────────────────────────────────────────────────────

class _FollowUpChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        _Chip(label: '📝 Show full working', onTap: () {}),
        _Chip(label: '🔄 Another example', onTap: () {}),
        _Chip(label: '⚡ Quiz me on this', onTap: () {}),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outline),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.purple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Source badge ──────────────────────────────────────────────────────────────

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.pageSlug});
  final String pageSlug;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.tealL,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
      ),
      child: Text(
        '📖 from $pageSlug.md',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.teal,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
