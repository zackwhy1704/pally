import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/shared/models/photo_question.dart';

class AnswerCard extends StatelessWidget {
  const AnswerCard({
    super.key,
    required this.answer,
    required this.questionNumber,
    required this.color,
    required this.isExpanded,
    required this.onToggle,
  });

  final QuestionAnswer answer;
  final int questionNumber;
  final Color color;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(isExpanded ? 14 : 10),
        border: Border.all(
          color: isExpanded ? color : color.withValues(alpha: 0.4),
          width: isExpanded ? 1.5 : 0.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1F1733),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row — always visible
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Number badge
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isExpanded ? color : color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$questionNumber',
                        style: TextStyle(
                          color: isExpanded ? Colors.white : color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      answer.questionText,
                      style: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Answer pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpanded ? color : color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isExpanded ? '= ${answer.answer}' : 'Show →',
                      style: TextStyle(
                        color: isExpanded ? Colors.white : color,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.text3,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded) ...[
            const Divider(color: AppColors.outline, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step-by-step
                  ...answer.steps.map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4, right: 8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              step,
                              style:
                                  AppTextStyles.bodySmall.copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (answer.explanation.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      answer.explanation,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.text2, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Answer badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.greenL,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '✅  ${answer.answer}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
