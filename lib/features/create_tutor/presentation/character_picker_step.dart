import 'package:flutter/material.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_button.dart';
import 'package:pally/shared/models/avatar.dart';

class CharacterPickerStep extends StatelessWidget {
  const CharacterPickerStep({
    super.key,
    required this.selectedCharacter,
    required this.onSelect,
    required this.onNext,
  });

  final AvatarCharacter? selectedCharacter;
  final ValueChanged<AvatarCharacter> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose your tutor', style: AppTextStyles.heading1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Pick a character that matches your personality!',
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 112 / 130,
            ),
            itemCount: AvatarCharacter.values.length,
            itemBuilder: (context, index) {
              final character = AvatarCharacter.values[index];
              return CharacterCard(
                character: character,
                isSelected: character == selectedCharacter,
                onTap: () => onSelect(character),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: PallyButton(
            label: 'Next',
            onPressed: selectedCharacter != null ? onNext : null,
            fullWidth: true,
          ),
        ),
      ],
    );
  }
}

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    super.key,
    required this.character,
    required this.isSelected,
    required this.onTap,
  });

  final AvatarCharacter character;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: character.bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.purple : AppColors.outline,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CharacterWidget(character: character, size: 52),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  character.displayName,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.text2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
