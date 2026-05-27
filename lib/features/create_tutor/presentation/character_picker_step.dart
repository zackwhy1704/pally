import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/pally_button.dart';
import 'package:pally/features/shop/providers/unlocked_characters_provider.dart';
import 'package:pally/shared/models/mochi_character.dart';

class CharacterPickerStep extends ConsumerWidget {
  const CharacterPickerStep({
    super.key,
    required this.selectedCharacter,
    required this.onSelect,
    required this.onNext,
  });

  final MochiCharacter? selectedCharacter;
  final ValueChanged<MochiCharacter> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedAsync = ref.watch(unlockedCharactersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose Your Mochi', style: AppTextStyles.heading1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Pick a Mochi that matches your vibe! 🎉',
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
              ),
            ],
          ),
        ),
        Expanded(
          child: unlockedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
            data: (unlocked) => GridView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 181 / 178,
              ),
              itemCount: MochiCharacter.values.length,
              itemBuilder: (context, index) {
                final character = MochiCharacter.values[index];
                final isUnlocked = unlocked.contains(character) ||
                    !character.isLockedByDefault;
                return _MochiCard(
                  character: character,
                  isSelected: character == selectedCharacter,
                  isUnlocked: isUnlocked,
                  onTap: isUnlocked
                      ? () => onSelect(character)
                      : () => context.push('/shop'),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: PallyButton(
            label: 'Next →',
            onPressed: selectedCharacter != null ? onNext : null,
            fullWidth: true,
          ),
        ),
      ],
    );
  }
}

class _MochiCard extends StatelessWidget {
  const _MochiCard({
    required this.character,
    required this.isSelected,
    required this.isUnlocked,
    required this.onTap,
  });

  final MochiCharacter character;
  final bool isSelected;
  final bool isUnlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: character.bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.purple
                : character.accentColor.withValues(alpha: 0.35),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Image.asset(character.assetPath,
                    width: 88, height: 88, fit: BoxFit.contain),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    character.displayName,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.text1,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (character.rarity != MochiRarity.standard)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: character.rarity.badgeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        character.rarity.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                if (!isUnlocked)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      '600 ⭐ to unlock',
                      style: TextStyle(color: AppColors.text3, fontSize: 9),
                    ),
                  ),
              ],
            ),
            if (!isUnlocked) ...[
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const Positioned(
                top: 28,
                left: 0,
                right: 0,
                child:
                    Center(child: Text('🔒', style: TextStyle(fontSize: 28))),
              ),
            ],
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.purple,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
