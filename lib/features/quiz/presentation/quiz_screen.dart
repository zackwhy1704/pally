import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/ui/no_notes_cta.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/pally_error_card.dart';
import 'package:pally/core/widgets/loading/splash_lines.dart';
import 'package:pally/features/quiz/presentation/quiz_view_model.dart';
import 'package:pally/features/progress/presentation/level_up_controller.dart';
import 'package:pally/shared/models/quiz_question.dart';

/// Turns a topic slug like "photosynthesis-chapter-3" into a readable
/// "Photosynthesis Chapter 3". Used wherever the backend only gives us a
/// slug and no human title — never show the raw slug to a child.
String humaniseSlug(String slug) {
  return slug
      .replaceAll('-', ' ')
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ')
      .trim();
}

/// Resolves a question ID to its human-readable question stem using the
/// session's questions. Falls back to a humanised slug of the id (never the
/// raw id/UUID) when the question can't be found.
String questionLabel(String id, List<QuizQuestion> questions) {
  for (final q in questions) {
    if (q.id == id) {
      final text = q.question.trim();
      if (text.isEmpty) break;
      return text.length > 60 ? '${text.substring(0, 57)}…' : text;
    }
  }
  return humaniseSlug(id);
}

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizViewModelProvider(avatarId));

    // Fire the level-up overlay exactly once when the backend reports a
    // crossing on quiz completion. Centralised through LevelUpController
    // so quiz / photo / chat / teach all celebrate identically.
    ref.listen<QuizState>(quizViewModelProvider(avatarId), (prev, next) {
      final justLevelledUp = next.levelledUp &&
          next.isComplete &&
          (prev == null || !prev.isComplete);
      if (justLevelledUp) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          LevelUpController.maybeCelebrate(
            context,
            levelledUp: true,
            newLevel: next.newLevel,
          );
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text('Daily Quiz', style: AppTextStyles.title),
        centerTitle: true,
        actions: [
          if (!quizState.isLoading && !quizState.isComplete) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Center(
                child: GestureDetector(
                  onTap: () => ref
                      .read(quizViewModelProvider(avatarId).notifier)
                      .toggleConfidenceMode(!quizState.confidenceMode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: quizState.confidenceMode
                          ? AppColors.purpleL
                          : AppColors.surf2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: quizState.confidenceMode
                              ? AppColors.purple
                              : AppColors.outline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.psychology_outlined,
                            size: 14,
                            color: quizState.confidenceMode
                                ? AppColors.purple
                                : AppColors.text2),
                        const SizedBox(width: 4),
                        Text(
                          'Confidence',
                          style: AppTextStyles.label.copyWith(
                              color: quizState.confidenceMode
                                  ? AppColors.purple
                                  : AppColors.text2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: Text(
                  '${quizState.currentIndex + 1}/${quizState.totalQuestions}',
                  style: AppTextStyles.label.copyWith(color: AppColors.purple),
                ),
              ),
            ),
          ],
        ],
      ),
      body: quizState.isLoading
          ? const _QuizLoadingView()
          : quizState.error != null
              ? PallyErrorCard(
                  message: quizState.error?.userMessage ?? 'Something went wrong — try again.',
                  onRetry: () => ref
                      .read(quizViewModelProvider(avatarId).notifier)
                      .restart(),
                )
              : quizState.questions.isEmpty
                  ? _NoQuestionsView(avatarId: avatarId)
                  : quizState.isComplete
                  ? _CompletionView(
                      score: quizState.score,
                      total: quizState.totalQuestions,
                      xpEarned: quizState.xpEarned,
                      avatarId: avatarId,
                      matrix: quizState.masteryMatrix,
                      questions: quizState.questions,
                    )
                  : _QuizBody(
                      avatarId: avatarId,
                      quizState: quizState,
                      onAnswer: (i) => ref
                          .read(quizViewModelProvider(avatarId).notifier)
                          .answerQuestion(i),
                      onNext: () => ref
                          .read(quizViewModelProvider(avatarId).notifier)
                          .nextQuestion(),
                      onConfidence: (c) => ref
                          .read(quizViewModelProvider(avatarId).notifier)
                          .setConfidence(c),
                    ),
    );
  }
}

class _QuizBody extends StatelessWidget {
  const _QuizBody({
    required this.quizState,
    required this.onAnswer,
    required this.onNext,
    required this.onConfidence,
    required this.avatarId,
  });

  final QuizState quizState;
  final ValueChanged<int> onAnswer;
  final VoidCallback onNext;
  final ValueChanged<Confidence> onConfidence;
  final String avatarId;

  @override
  Widget build(BuildContext context) {
    final question = quizState.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProgressBar(
            current: quizState.currentIndex + 1,
            total: quizState.totalQuestions,
          ),
          const SizedBox(height: AppSpacing.lg),
          _QuestionCard(question: question),
          if (quizState.confidenceMode && !quizState.isAnswered) ...[
            const SizedBox(height: AppSpacing.md),
            _ConfidencePicker(
              selected: quizState.selectedConfidence,
              onSelect: onConfidence,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(question.options.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _OptionButton(
                label: question.options[index],
                index: index,
                isSelected: quizState.selectedAnswer == index,
                isAnswered: quizState.isAnswered,
                isCorrect: index == question.correctIndex,
                disabled: quizState.confidenceMode &&
                    quizState.selectedConfidence == null,
                onTap: () => onAnswer(index),
              ),
            );
          }),
          if (quizState.isAnswered) ...[
            const SizedBox(height: AppSpacing.md),
            _ExplanationCard(
              question: question,
              isCorrect: quizState.selectedAnswer == question.correctIndex,
              avatarId: avatarId,
            ),
            const SizedBox(height: AppSpacing.md),
            const _XpBadge(xp: 20),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                quizState.isLastQuestion ? 'Finish Quiz' : 'Next Question',
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question $current of $total', style: AppTextStyles.label),
            Text('${((current / total) * 100).round()}%',
                style: AppTextStyles.label.copyWith(color: AppColors.purple)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current / total,
            backgroundColor: AppColors.outline,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.purple),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});

  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.purpleL,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.help_outline_rounded,
              color: AppColors.purple, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              question.question,
              style: AppTextStyles.title.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.isAnswered,
    required this.isCorrect,
    required this.onTap,
    this.disabled = false,
  });

  final String label;
  final int index;
  final bool isSelected;
  final bool isAnswered;
  final bool isCorrect;
  final VoidCallback onTap;
  final bool disabled;

  Color get _bgColor {
    if (!isAnswered) {
      return isSelected ? AppColors.purpleL : AppColors.surface;
    }
    if (isCorrect) return AppColors.greenL;
    if (isSelected && !isCorrect) return AppColors.coralL;
    return AppColors.surface;
  }

  Color get _borderColor {
    if (!isAnswered) {
      return isSelected ? AppColors.purple : AppColors.outline;
    }
    if (isCorrect) return AppColors.green;
    if (isSelected && !isCorrect) return AppColors.coral;
    return AppColors.outline;
  }

  Color get _textColor {
    if (!isAnswered) {
      return isSelected ? AppColors.purple : AppColors.text1;
    }
    if (isCorrect) return AppColors.green;
    if (isSelected && !isCorrect) return AppColors.coral;
    return AppColors.text2;
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['A', 'B', 'C', 'D'];
    return Opacity(
      opacity: disabled && !isAnswered ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: (isAnswered || disabled) ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: AppSpacing.card,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor, width: 2),
          ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _borderColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  labels[index],
                  style: AppTextStyles.label.copyWith(
                    color: _textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(color: _textColor),
              ),
            ),
            if (isAnswered && isCorrect)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.green, size: 20),
            if (isAnswered && isSelected && !isCorrect)
              const Icon(Icons.cancel_rounded,
                  color: AppColors.coral, size: 20),
          ],
        ),
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    required this.question,
    required this.isCorrect,
    required this.avatarId,
  });

  final QuizQuestion question;
  final bool isCorrect;
  final String avatarId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.greenL : AppColors.coralL,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                color: isCorrect ? AppColors.green : AppColors.coral,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                isCorrect ? 'Correct!' : 'Not quite',
                style: AppTextStyles.body.copyWith(
                  color: isCorrect ? AppColors.green : AppColors.coral,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (question.explanation.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(question.explanation, style: AppTextStyles.bodySmall),
          ],
          if (question.sourcePage.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            InkWell(
              onTap: () => WikiViewerRoute(avatarId: avatarId).push(context),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.source_rounded,
                        size: 12, color: AppColors.purple),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        humaniseSlug(question.sourcePage),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.purple,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_outward_rounded,
                        size: 11, color: AppColors.purple),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _XpBadge extends StatelessWidget {
  const _XpBadge({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.goldL,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
            const SizedBox(width: 4),
            Text(
              '+$xp XP',
              style: AppTextStyles.label.copyWith(
                color: AppColors.amber,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionView extends StatelessWidget {
  const _CompletionView({
    required this.score,
    required this.total,
    required this.xpEarned,
    required this.avatarId,
    required this.questions,
    this.matrix,
  });

  final int score;
  final int total;
  final int xpEarned;
  final String avatarId;
  final List<QuizQuestion> questions;
  final MasteryMatrix? matrix;

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (score / total * 100).round() : 0;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.purpleL,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$percentage%',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.purple,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Quiz Complete!', style: AppTextStyles.heading1),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'You got $score out of $total correct.',
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.goldL,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.gold, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '+$xpEarned XP earned',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.amber,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Part 3 — Show the adaptation signal honestly, only when the
            // harness actually fired on a tricky topic.
            if (matrix?.priorityReview != null ||
                (matrix?.misconception.isNotEmpty ?? false) ||
                (matrix?.knownGap.isNotEmpty ?? false)) ...[
              const SizedBox(height: AppSpacing.md),
              _MemoryNoticeCard(
                // These matrix fields carry question IDs (often UUIDs), not
                // slugs — resolve each to its question text before display so
                // a child never sees a raw id.
                topicLabel: questionLabel(
                  matrix?.priorityReview
                      ?? matrix?.misconception.firstOrNull
                      ?? matrix?.knownGap.firstOrNull
                      ?? '',
                  questions,
                ),
              ),
            ],
            if (matrix != null && matrix!.hasAny) ...[
              const SizedBox(height: AppSpacing.md),
              _MasteryMatrixCard(matrix: matrix!, questions: questions),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                // Use .go() to replace the route stack (home → quiz → chat
                // would loop back to quiz on back press). Now back from chat
                // returns to home, as expected.
                onPressed: () => ChatRoute(avatarId: avatarId).go(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Back to Mochi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Three-button row asking the student to self-rate how sure they are BEFORE
/// they answer. Drives the mastery-matrix classification shown on completion.
class _ConfidencePicker extends StatelessWidget {
  const _ConfidencePicker({required this.selected, required this.onSelect});

  final Confidence? selected;
  final ValueChanged<Confidence> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How sure are you?',
          style: AppTextStyles.label.copyWith(color: AppColors.text2),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
                child: _ConfidenceChip(
                    emoji: '😬',
                    label: 'Not sure',
                    value: Confidence.low,
                    selected: selected,
                    onSelect: onSelect)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
                child: _ConfidenceChip(
                    emoji: '🤔',
                    label: 'Kinda',
                    value: Confidence.medium,
                    selected: selected,
                    onSelect: onSelect)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
                child: _ConfidenceChip(
                    emoji: '😎',
                    label: 'Very sure',
                    value: Confidence.high,
                    selected: selected,
                    onSelect: onSelect)),
          ],
        ),
      ],
    );
  }
}

class _ConfidenceChip extends StatelessWidget {
  const _ConfidenceChip({
    required this.emoji,
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelect,
  });

  final String emoji;
  final String label;
  final Confidence value;
  final Confidence? selected;
  final ValueChanged<Confidence> onSelect;

  @override
  Widget build(BuildContext context) {
    final isOn = selected == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isOn ? AppColors.purpleL : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isOn ? AppColors.purple : AppColors.outline,
              width: isOn ? 2 : 1),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: isOn ? AppColors.purple : AppColors.text2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 2×2 mastery matrix — mastered / misconception / luckyGuess / knownGap.
/// Misconceptions get a high-contrast warning treatment because they're the
/// most dangerous category (confidently wrong knowledge that compounds).
class _MasteryMatrixCard extends StatelessWidget {
  const _MasteryMatrixCard({required this.matrix, required this.questions});

  final MasteryMatrix matrix;
  final List<QuizQuestion> questions;

  /// Resolves a question ID to a short, human-readable label (the question
  /// stem). Never surfaces a raw id/UUID — falls back to a humanised slug.
  String _label(String id) => questionLabel(id, questions);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Mastery breakdown', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _MasteryQuadrant(
                title: 'Mastered',
                emoji: '✅',
                items: matrix.mastered.map(_label).toList(),
                color: AppColors.green,
                bgColor: AppColors.greenL,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MasteryQuadrant(
                title: 'Misconception',
                emoji: '⚠️',
                items: matrix.misconception.map(_label).toList(),
                color: AppColors.coral,
                bgColor: AppColors.coralL,
                emphasis: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _MasteryQuadrant(
                title: 'Lucky guess',
                emoji: '🍀',
                items: matrix.luckyGuess.map(_label).toList(),
                color: AppColors.amber,
                bgColor: AppColors.amberL,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MasteryQuadrant(
                title: 'Known gap',
                emoji: '📚',
                items: matrix.knownGap.map(_label).toList(),
                color: AppColors.purple,
                bgColor: AppColors.purpleL,
              ),
            ),
          ],
        ),
        if (matrix.priorityReview != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: AppSpacing.card,
            decoration: BoxDecoration(
              color: AppColors.coralL,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.coral, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.priority_high_rounded,
                    color: AppColors.coral, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Focus next: ${_label(matrix.priorityReview!)}',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.text1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MasteryQuadrant extends StatelessWidget {
  const _MasteryQuadrant({
    required this.title,
    required this.emoji,
    required this.items,
    required this.color,
    required this.bgColor,
    this.emphasis = false,
  });

  final String title;
  final String emoji;
  final List<String> items;
  final Color color;
  final Color bgColor;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: emphasis ? Border.all(color: color, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text('${items.length}',
                  style: AppTextStyles.body.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  )),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 6),
            for (final item in items.take(3))
              Text(
                '· $item',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.text2,
                ),
              ),
            if (items.length > 3)
              Text('+${items.length - 3} more',
                  style: AppTextStyles.caption.copyWith(color: color)),
          ],
        ],
      ),
    );
  }
}

/// Shown after a quiz only when the harness actually detected a tricky topic.
/// Maps to real state — never fabricated.
class _MemoryNoticeCard extends StatelessWidget {
  const _MemoryNoticeCard({required this.topicLabel});

  /// Already-resolved, human-readable label (question text or humanised slug).
  /// The caller resolves question IDs upstream — this card never sees a raw id.
  final String topicLabel;

  @override
  Widget build(BuildContext context) {
    final display = topicLabel.trim();

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.amberL,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Text('🧠', style: TextStyle(fontSize: 18)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              display.isNotEmpty
                  ? 'I noticed $display is tricky for you — I\'ll bring it back soon.'
                  : "I noticed some topics were tricky — I'll bring them back soon.",
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.amber, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quiz loading — rotating motivational lines ────────────────────────────────
// Quiz generation calls Claude AI and takes 20-60 s. A plain spinner looks
// frozen. Cycling through the splash quotes keeps the user informed and
// aligned with the app's brand voice.

class _QuizLoadingView extends StatefulWidget {
  const _QuizLoadingView();

  @override
  State<_QuizLoadingView> createState() => _QuizLoadingViewState();
}

class _QuizLoadingViewState extends State<_QuizLoadingView> {
  int _lineIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _lineIndex = (_lineIndex + 1) % kSplashLines.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final line = kSplashLines[_lineIndex];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/mochi.png',
              width: MediaQuery.of(context).size.shortestSide * 0.28,
              height: MediaQuery.of(context).size.shortestSide * 0.28,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSpacing.lg),
            const SizedBox(
              width: AppSpacing.xl,
              height: AppSpacing.xl,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Column(
                key: ValueKey(_lineIndex),
                children: [
                  Text(
                    line.hero,
                    style: AppTextStyles.title
                        .copyWith(color: AppColors.purple),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    line.sub,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.text2),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Building your quiz…',
              style: AppTextStyles.caption.copyWith(color: AppColors.text3),
            ),
          ],
        ),
      ),
    );
  }
}

// ── No questions empty state ──────────────────────────────────────────────────
class _NoQuestionsView extends StatelessWidget {
  const _NoQuestionsView({required this.avatarId});

  final String avatarId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🧠', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No quiz today',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            NoNotesCta(
              avatarId: avatarId,
              personalDescription:
                  'Upload some notes so Mochi can build your first quiz!',
            ),
          ],
        ),
      ),
    );
  }
}
