import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/i18n/app_languages.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_button.dart';
import 'package:pally/core/ui/pally_dialog.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/shared/models/avatar.dart';

/// Change the language this avatar generates NEW content in — the mobile
/// equivalent of memoly's EditClassModal language control, applied to a
/// single avatar's `contentLanguage` (V124, PATCH /avatars/{id}/content-
/// language). NO-RETAG semantics stated explicitly: existing pages/modules/
/// flashcards keep the language they were compiled in.
///
/// Follows the app's mandatory API-call UX contract: the Save button disables
/// while in flight (re-entry guard via [_saving]), a failure surfaces as a
/// persistent inline error with Retry (never toast-only for this primary
/// action), and success closes the sheet — the caller shows the success toast
/// on its own (still-mounted) context.
class PallyAvatarLanguageSheet extends ConsumerStatefulWidget {
  const PallyAvatarLanguageSheet({super.key, required this.avatar});

  final Avatar avatar;

  static Future<bool?> show({
    required BuildContext context,
    required Avatar avatar,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PallyAvatarLanguageSheet(avatar: avatar),
    );
  }

  @override
  ConsumerState<PallyAvatarLanguageSheet> createState() =>
      _PallyAvatarLanguageSheetState();
}

class _PallyAvatarLanguageSheetState
    extends ConsumerState<PallyAvatarLanguageSheet> {
  late String _selected;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Absent (older payload) means the backend default, 'en' — the same
    // fallback the server itself applies when the field is omitted.
    _selected = AppLanguages.byCode(widget.avatar.contentLanguage)?.code ??
        AppLanguages.fallback.code;
  }

  bool get _changed => _selected != (widget.avatar.contentLanguage ?? 'en');

  Future<void> _save() async {
    if (_saving) return; // re-entry guard
    setState(() {
      _saving = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    final updated = await ref
        .read(homeViewModelProvider.notifier)
        .setContentLanguage(widget.avatar.id, _selected);
    if (!mounted) return;
    if (updated != null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _error = l10n.avatarLanguageSaveError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PallyDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.avatarLanguageTitle, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.avatarLanguageBody(l10n.mascotName),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final lang in AppLanguages.all)
                ChoiceChip(
                  label: Text(lang.endonym),
                  selected: _selected == lang.code,
                  onSelected: _saving
                      ? null
                      : (_) => setState(() => _selected = lang.code),
                  selectedColor: AppColors.purpleL,
                  labelStyle: AppTextStyles.body.copyWith(
                    color: _selected == lang.code
                        ? AppColors.purple
                        : AppColors.text1,
                    fontWeight: _selected == lang.code
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                  side: BorderSide(
                      color: _selected == lang.code
                          ? AppColors.purple
                          : AppColors.outline),
                ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!, style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.coral)),
          ],
          const SizedBox(height: AppSpacing.lg),
          PallyDialog.buttonRow(
            secondary: PallyButton(
              label: l10n.commonCancel,
              onPressed:
                  _saving ? null : () => Navigator.of(context).pop(false),
              variant: PallyButtonVariant.outlined,
              fullWidth: true,
            ),
            primary: PallyButton(
              label: _error != null
                  ? l10n.commonRetry
                  : l10n.avatarLanguageSave,
              onPressed: (_saving || !_changed) ? null : _save,
              loading: _saving,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
