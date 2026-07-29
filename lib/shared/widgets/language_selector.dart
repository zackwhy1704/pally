import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pally/core/i18n/app_languages.dart';
import 'package:pally/core/i18n/locale_controller.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// Inline UI-language selector — a compact pill group, one pill per
/// [AppLanguages.all] entry (registry-driven, never a hand-written list). Meant
/// for the pre-auth entry surfaces (sign-in / onboarding) so language is the
/// FIRST thing a user can set, before an account exists (B4). Device locale is
/// already pre-selected by bootstrap resolution; tapping a pill applies live and
/// persists via [LocaleController]. Wraps, so it stays overflow-safe on a 320dp
/// screen and grows cleanly as languages are added.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCode = ref.watch(localeControllerProvider).languageCode;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      alignment: WrapAlignment.center,
      children: [
        for (final lang in AppLanguages.all)
          _LangPill(
            label: lang.endonym,
            selected: lang.code == currentCode,
            onTap: () =>
                ref.read(localeControllerProvider.notifier).setLanguage(lang),
          ),
      ],
    );
  }
}

class _LangPill extends StatelessWidget {
  const _LangPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.purple : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.purple : AppColors.outline,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: selected ? Colors.white : AppColors.text2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
