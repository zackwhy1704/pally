import 'package:flutter/material.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';

class WikiCompiledScreen extends StatelessWidget {
  const WikiCompiledScreen({
    super.key,
    required this.avatarId,
    required this.newPageTitles,
    this.brainScore,
  });

  final String avatarId;
  final List<String> newPageTitles;
  final int? brainScore;

  @override
  Widget build(BuildContext context) {
    final score = brainScore ?? _computeScore(newPageTitles.length);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenH,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              _SuccessHero(),
              const SizedBox(height: AppSpacing.lg),
              Text(
                newPageTitles.isEmpty ? 'Notes received! 🧠' : 'Knowledge Added!',
                style: AppTextStyles.heading1, textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                newPageTitles.isEmpty
                    ? 'Mochi is reading your notes and building your brain in the background. Check back in a minute!'
                    : 'Your Mochi brain has been updated with ${newPageTitles.length} new ${newPageTitles.length == 1 ? 'page' : 'pages'}.',
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              _BrainQualityCard(score: score, pageCount: newPageTitles.length),
              const SizedBox(height: AppSpacing.md),
              if (newPageTitles.isNotEmpty)
                Expanded(
                  child: _PagesList(titles: newPageTitles),
                ),
              const SizedBox(height: AppSpacing.lg),
              _ActionButtons(avatarId: avatarId),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  static int _computeScore(int pageCount) {
    if (pageCount >= 10) return 9;
    if (pageCount >= 6) return 8;
    if (pageCount >= 3) return 7;
    if (pageCount >= 1) return 5;
    return 3;
  }
}

// ── Brain Quality Score card ──────────────────────────────────────────────────

class _BrainQualityCard extends StatelessWidget {
  const _BrainQualityCard({required this.score, required this.pageCount});

  final int score;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final fraction = score / 10.0;
    final (barColor, status) = score >= 8
        ? (AppColors.green, 'Excellent')
        : score >= 6
            ? (AppColors.teal, 'Good')
            : score >= 4
                ? (AppColors.amber, 'Building up')
                : (AppColors.coral, 'Needs more content');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.purpleL,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  'Brain Quality Score',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.text2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$score/10',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.purple,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: AppColors.outline,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatusRow(
            icon: pageCount >= 1 ? '✅' : '⚠️',
            text: pageCount >= 1
                ? '$pageCount page${pageCount == 1 ? '' : 's'} of content added'
                : 'No content uploaded yet',
            positive: pageCount >= 1,
          ),
          const SizedBox(height: 4),
          _StatusRow(
            icon: pageCount >= 5 ? '✅' : '⚠️',
            text: pageCount >= 5
                ? 'Good breadth of topics'
                : 'Upload more pages for better coverage',
            positive: pageCount >= 5,
          ),
          const SizedBox(height: 4),
          _StatusRow(
            icon: '✅',
            text: 'Brain status: $status',
            positive: score >= 6,
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.text,
    required this.positive,
  });

  final String icon;
  final String text;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: positive ? AppColors.text1 : AppColors.amber,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Success hero ──────────────────────────────────────────────────────────────

class _SuccessHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.greenL,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: AppColors.green,
        size: 52,
      ),
    );
  }
}

class _PagesList extends StatelessWidget {
  const _PagesList({required this.titles});

  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: ListView.separated(
        padding: AppSpacing.card,
        shrinkWrap: true,
        itemCount: titles.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 16, color: AppColors.outline),
        itemBuilder: (context, index) {
          return Row(
            children: [
              const Icon(Icons.article_outlined,
                  size: 18, color: AppColors.purple),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  titles[index],
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.check_circle_rounded,
                  size: 16, color: AppColors.green),
            ],
          );
        },
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.avatarId});

  final String avatarId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => ChatRoute(avatarId: avatarId).push(context),
          icon: const Icon(Icons.chat_bubble_rounded),
          label: const Text('Ask Mochi Now'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.purple,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => QuizRoute(avatarId: avatarId).push(context),
                icon: const Icon(Icons.bolt_rounded, size: 18),
                label: const Text('Quick Quiz'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.amber,
                  side: const BorderSide(color: AppColors.amber),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    WikiViewerRoute(avatarId: avatarId).push(context),
                icon: const Icon(Icons.psychology_rounded, size: 18),
                label: const Text('View Brain'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  side: const BorderSide(color: AppColors.teal),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
