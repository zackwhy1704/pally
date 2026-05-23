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
  });

  final String avatarId;
  final List<String> newPageTitles;

  @override
  Widget build(BuildContext context) {
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
              Text('Knowledge Added!',
                  style: AppTextStyles.heading1, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your tutor brain has been updated with ${newPageTitles.length} new ${newPageTitles.length == 1 ? 'page' : 'pages'}.',
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
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
}

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
          label: const Text('Ask Tutor Now'),
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
