import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';

const _kSeenKey = 'pally_different_seen_v1';

/// Shows the "How Pally is different" explainer once after first tutor
/// creation and is findable again from Settings → About.
///
/// Call [HowPallyIsDifferent.maybeShow] after tutor creation to trigger
/// it automatically, or call [HowPallyIsDifferent.show] directly from
/// Settings for the always-accessible path.
class HowPallyIsDifferent {
  static Future<void> maybeShow(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kSeenKey) ?? false) return;
    if (!context.mounted) return;
    await show(context);
    await prefs.setBool(_kSeenKey, true);
  }

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ExplainerSheet(),
    );
  }
}

class _ExplainerSheet extends StatelessWidget {
  const _ExplainerSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Text('What makes Pally different 🧠',
                style: AppTextStyles.heading1.copyWith(fontSize: 20),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "Here's what you just got — and why it matters.",
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            const _DifferentiatorCard(
              emoji: '📚',
              title: 'Built from your notes',
              body: 'Your tutor learns your material — your textbook, your class notes, your syllabus. So every answer matches what your teacher actually taught, not a generic textbook.',
              color: AppColors.purpleL,
              border: AppColors.purple,
            ),
            const SizedBox(height: AppSpacing.sm),
            const _DifferentiatorCard(
              emoji: '🧠',
              title: 'Remembers how you learn',
              body: 'It tracks which topics trip you up and brings them back until they stick. Easy things get spaced out. No time wasted on what you already know.',
              color: AppColors.amberL,
              border: AppColors.amber,
            ),
            const SizedBox(height: AppSpacing.sm),
            const _DifferentiatorCard(
              emoji: '🎯',
              title: 'Made for real studying',
              body: 'Subject-specialist tutors, spaced-repetition flashcards, daily quizzes, mastery tracking, curriculum-aligned — depth designed for serious learners.',
              color: AppColors.tealL,
              border: AppColors.teal,
            ),

            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surf2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"Not a tutor that knows the textbook. A tutor that knows yours."',
                style: AppTextStyles.body.copyWith(
                    color: AppColors.purple,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Got it — let's study!"),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifferentiatorCard extends StatelessWidget {
  const _DifferentiatorCard({
    required this.emoji,
    required this.title,
    required this.body,
    required this.color,
    required this.border,
  });

  final String emoji;
  final String title;
  final String body;
  final Color color;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(body,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.text2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
