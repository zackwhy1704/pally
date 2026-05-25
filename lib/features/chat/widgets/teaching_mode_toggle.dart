import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';

enum TeachingMode { teaching, direct }

class TeachingModeToggle extends StatelessWidget {
  const TeachingModeToggle({
    super.key,
    required this.mode,
    required this.onToggle,
    this.enabled = true,
  });

  final TeachingMode mode;
  final VoidCallback onToggle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isSocratic = mode == TeachingMode.teaching;

    return GestureDetector(
      onTap: enabled ? onToggle : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSocratic
              ? AppColors.purpleL
              : AppColors.surf2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSocratic ? AppColors.purple : AppColors.outline,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isSocratic ? '🧠' : '⚡',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 5),
            Text(
              isSocratic ? 'Guide me' : 'Just tell me',
              style: AppTextStyles.label.copyWith(
                color: isSocratic ? AppColors.purple : AppColors.text2,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
