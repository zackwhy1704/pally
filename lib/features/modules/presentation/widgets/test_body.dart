import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';
import 'package:pally/shared/models/learning_module.dart';

// ── TEST stage: sequential items ────────────────────────────────────────────

class TestBody extends StatelessWidget {
  const TestBody({
    super.key,
    required this.item,
    required this.currentIndex,
    required this.totalItems,
    required this.isRevealed,
    required this.answer,
    required this.onAnswer,
    required this.onNext,
    required this.isLast,
    required this.isSubmitting,
    this.verdict,
    this.verdictPending = false,
  });

  final ModuleContentItem? item;
  final int currentIndex;
  final int totalItems;
  final bool isRevealed;
  final String? answer;
  final void Function(String itemId, String response) onAnswer;
  final VoidCallback onNext;
  final bool isLast;
  final bool isSubmitting;

  /// Server verdict for the current HOT_TAKE (null ⇒ no banner: pending or failed).
  final HotTakeVerdict? verdict;

  /// True while this HOT_TAKE's verdict fetch is in flight (shows "checking…").
  final bool verdictPending;

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return const Center(child: Text('No items'));
    }

    return Column(
      children: [
        // Progress dots
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: List.generate(totalItems, (i) {
              final isActive = i <= currentIndex;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < totalItems - 1 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.amber : AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildItemWidget(context),
          ),
        ),
        if (isRevealed)
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
                  backgroundColor: AppColors.amber,
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
                        isLast ? 'Time to prove you understand' : 'Next',
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

  Widget _buildItemWidget(BuildContext context) {
    final content = item!.contentJson;
    // The PROMPT lives in contentJson. The REVEAL is split by secrecy:
    //  · SPOT_MISTAKE / CHALLENGE are UNGRADED — the server ships their non-secret
    //    reveal at serve time in `revealJson` (field-filtered), read here.
    //  · HOT_TAKE is the graded type — its key (isTrue) is NEVER served; the verdict
    //    + explanation come from the per-item submit response, passed in as [verdict].
    // NB: answerJson is null for TEST at serve, so it is deliberately NOT read here.
    final reveal = item!.revealJson ?? const <String, dynamic>{};
    return switch (item!.type) {
      'HOT_TAKE' => HotTakeCard(
          statement: content['statement'] as String? ?? '',
          verdict: verdict,
          verdictPending: verdictPending,
          isRevealed: isRevealed,
          answer: answer,
          onAnswer: (response) => onAnswer(item!.id, response),
        ),
      'SPOT_MISTAKE' => SpotMistakeCard(
          problem: content['problem'] as String? ?? '',
          wrongSolution: content['wrongSolution'] as String? ?? '',
          errorDescription: reveal['errorDescription'] as String? ?? '',
          correctSolution: reveal['correctSolution'] as String? ?? '',
          isRevealed: isRevealed,
          onReveal: () => onAnswer(item!.id, 'found'),
        ),
      'CHALLENGE' => ChallengeCard(
          question: content['question'] as String? ?? '',
          explanation: reveal['explanation'] as String? ?? '',
          isRevealed: isRevealed,
          answer: answer ?? '',
          onSubmit: (response) => onAnswer(item!.id, response),
        ),
      _ => GenericTestCard(
          content: content,
          isRevealed: isRevealed,
          onAnswer: (response) => onAnswer(item!.id, response),
        ),
    };
  }
}

class HotTakeCard extends StatelessWidget {
  const HotTakeCard({
    super.key,
    required this.statement,
    required this.verdict,
    required this.verdictPending,
    required this.isRevealed,
    required this.answer,
    required this.onAnswer,
  });

  final String statement;

  /// Authoritative SERVER verdict (null ⇒ show the reveal WITHOUT a Correct!/Not quite
  /// banner — we never fabricate correctness client-side, the old `?? true` bug).
  final HotTakeVerdict? verdict;
  final bool verdictPending;
  final bool isRevealed;
  final String? answer;
  final void Function(String) onAnswer;

  @override
  Widget build(BuildContext context) {
    final wasRight = verdict?.correct ?? false;

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
          Text('True or False?',
              style: AppTextStyles.label.copyWith(
                  color: AppColors.amber, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          Text(statement, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          if (!isRevealed)
            Row(
              children: [
                Expanded(
                  child: AnswerButton(
                    label: 'Agree',
                    color: AppColors.green,
                    onTap: () => onAnswer('AGREE'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AnswerButton(
                    label: 'Disagree',
                    color: AppColors.coral,
                    onTap: () => onAnswer('DISAGREE'),
                  ),
                ),
              ],
            ),
          if (isRevealed) ...[
            if (verdictPending)
              // Verdict in flight — a neutral "checking" state so a normal load never
              // flashes the failure copy. The Next button (in TestBody) is unaffected.
              Container(
                width: double.infinity,
                padding: AppSpacing.card,
                decoration: BoxDecoration(
                  color: AppColors.surf2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: AppSizing.spinnerSm,
                      height: AppSizing.spinnerSm,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.purple),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Checking your answer…',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.text2)),
                  ],
                ),
              )
            else if (verdict != null)
              Container(
                width: double.infinity,
                padding: AppSpacing.card,
                decoration: BoxDecoration(
                  color: wasRight ? AppColors.greenL : AppColors.coralL,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          wasRight
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: wasRight ? AppColors.green : AppColors.coral,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          wasRight ? 'Correct!' : 'Not quite',
                          style: AppTextStyles.body.copyWith(
                            color:
                                wasRight ? AppColors.green : AppColors.coral,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (verdict!.explanation.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(verdict!.explanation, style: AppTextStyles.body),
                    ],
                  ],
                ),
              )
            else
              // No verdict (fetch failed) — record the answer honestly WITHOUT a
              // fabricated Correct!/Not quite. The item is still graded at end-of-stage.
              Container(
                width: double.infinity,
                padding: AppSpacing.card,
                decoration: BoxDecoration(
                  color: AppColors.surf2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Answer recorded — couldn't load feedback right now.",
                  style: AppTextStyles.body.copyWith(color: AppColors.text2),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizing.buttonHeight,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class SpotMistakeCard extends StatelessWidget {
  const SpotMistakeCard({
    super.key,
    required this.problem,
    required this.wrongSolution,
    required this.errorDescription,
    required this.correctSolution,
    required this.isRevealed,
    required this.onReveal,
  });

  final String problem;
  final String wrongSolution;
  final String errorDescription;
  final String correctSolution;
  final bool isRevealed;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
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
          Text('Spot the mistake',
              style: AppTextStyles.label.copyWith(
                  color: AppColors.amber, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          Text(problem, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: AppSpacing.card,
            decoration: BoxDecoration(
              color: AppColors.coralL,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.coral.withValues(alpha: 0.3)),
            ),
            child: Text(wrongSolution,
                style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!isRevealed)
            SizedBox(
              width: double.infinity,
              height: AppSizing.buttonHeight,
              child: OutlinedButton(
                onPressed: onReveal,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.amber,
                  side: const BorderSide(color: AppColors.amber),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('I found it!'),
              ),
            ),
          if (isRevealed) ...[
            Container(
              width: double.infinity,
              padding: AppSpacing.card,
              decoration: BoxDecoration(
                color: AppColors.greenL,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('The error:',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(errorDescription, style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Correct solution:',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.green,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(correctSolution, style: AppTextStyles.body),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChallengeCard extends StatefulWidget {
  const ChallengeCard({
    super.key,
    required this.question,
    required this.explanation,
    required this.isRevealed,
    required this.answer,
    required this.onSubmit,
  });

  final String question;
  final String explanation;
  final bool isRevealed;
  final String answer;
  final void Function(String) onSubmit;

  @override
  State<ChallengeCard> createState() => ChallengeCardState();
}

class ChallengeCardState extends State<ChallengeCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.answer);
    // Rebuild as the student types so the Submit button re-evaluates its enabled
    // state. Without this the button gates on _controller.text read ONCE at first
    // build (empty → disabled) and never re-enables — a student could type a full
    // answer and never be able to submit, so a module ending in a Challenge could
    // never be completed.
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Text('Challenge',
              style: AppTextStyles.label.copyWith(
                  color: AppColors.amber, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          Text(widget.question, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          if (!widget.isRevealed) ...[
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Type your answer...',
                hintStyle:
                    AppTextStyles.body.copyWith(color: AppColors.text3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.amber),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: AppSizing.buttonHeight,
              child: FilledButton(
                onPressed: _controller.text.trim().isEmpty
                    ? null
                    : () => widget.onSubmit(_controller.text.trim()),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
          if (widget.isRevealed) ...[
            Container(
              width: double.infinity,
              padding: AppSpacing.card,
              decoration: BoxDecoration(
                color: AppColors.amberL,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your answer:',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.text2)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(widget.answer, style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Explanation:',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.amber,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(widget.explanation, style: AppTextStyles.body),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GenericTestCard extends StatelessWidget {
  const GenericTestCard({
    super.key,
    required this.content,
    required this.isRevealed,
    required this.onAnswer,
  });

  final Map<String, dynamic> content;
  final bool isRevealed;
  final void Function(String) onAnswer;

  @override
  Widget build(BuildContext context) {
    final question = content['question'] as String? ?? '';
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
          Text(question, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          if (!isRevealed)
            SizedBox(
              width: double.infinity,
              height: AppSizing.buttonHeight,
              child: FilledButton(
                onPressed: () => onAnswer('answered'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Answer'),
              ),
            ),
        ],
      ),
    );
  }
}
