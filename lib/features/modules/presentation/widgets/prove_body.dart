import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/shared/models/learning_module.dart';

// ── PROVE stage: all short-answer questions ─────────────────────────────────

class ProveBody extends StatelessWidget {
  const ProveBody({
    super.key,
    required this.items,
    required this.answers,
    required this.onAnswerChanged,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final List<ModuleContentItem> items;
  final Map<String, String> answers;
  final void Function(String itemId, String response) onAnswerChanged;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final allAnswered = items.every(
        (item) => (answers[item.id] ?? '').trim().isNotEmpty);

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = items[index];
              final question =
                  item.contentJson['question'] as String? ?? '';
              return ProveQuestion(
                questionNumber: index + 1,
                question: question,
                answer: answers[item.id] ?? '',
                onChanged: (value) => onAnswerChanged(item.id, value),
              );
            },
          ),
        ),
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
              onPressed: isSubmitting || !allAnswered ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
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
                  : const Text('Submit all answers'),
            ),
          ),
        ),
      ],
    );
  }
}

class ProveQuestion extends StatefulWidget {
  const ProveQuestion({
    super.key,
    required this.questionNumber,
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  final int questionNumber;
  final String question;
  final String answer;
  final ValueChanged<String> onChanged;

  @override
  State<ProveQuestion> createState() => ProveQuestionState();
}

class ProveQuestionState extends State<ProveQuestion> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.answer);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${widget.questionNumber}',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.purple, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(widget.question, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            maxLines: 3,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: 'Write your answer (1-3 sentences)...',
              hintStyle:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.text3),
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
                borderSide: const BorderSide(color: AppColors.purple),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
