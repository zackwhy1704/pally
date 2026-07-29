import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pally/core/i18n/app_languages.dart';
import 'package:pally/core/i18n/locale_controller.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Bottom-sheet UI-language picker.
///
/// Renders EVERY [AppLanguages.all] entry — never a hand-written option list —
/// so adding a language to the registry surfaces it here with no edit to this
/// file (B-EXT.1/B-EXT.2). Selecting applies immediately (live `MaterialApp`
/// rebuild) and persists via [LocaleController]. The subtitle states the
/// two-axes rule: this is the app's UI language, not the Mochi's teaching
/// language, so switching it does not re-translate existing lessons.
class LanguagePickerSheet extends ConsumerWidget {
  const LanguagePickerSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => const LanguagePickerSheet(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final currentCode = ref.watch(localeControllerProvider).languageCode;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.language, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l.languagePickerSubtitle(l.mascotName),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final lang in AppLanguages.all)
              _LanguageOption(
                lang: lang,
                selected: lang.code == currentCode,
                // Plain (non-async) callback: setLanguage flips state
                // synchronously (UI already updates) and can never throw, so
                // fire-and-forget + immediate dismiss is safe.
                onTap: () {
                  ref.read(localeControllerProvider.notifier).setLanguage(lang);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.lang,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage lang;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.purple : AppColors.text1;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                lang.endonym,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_rounded,
                  color: AppColors.purple, size: 20),
          ],
        ),
      ),
    );
  }
}
