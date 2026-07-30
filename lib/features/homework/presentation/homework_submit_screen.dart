import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/adaptive_content_width.dart';
import 'package:pally/features/homework/presentation/homework_submit_view_model.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Capture + upload the student's own homework artifact (photos / PDF) to a
/// centre class. Follows the API-call UX contract: the Submit button shows a
/// spinner and is disabled while in flight; failures surface as a persistent
/// inline error with retry (never a toast); the re-entry guard lives in the VM.
class HomeworkSubmitScreen extends ConsumerStatefulWidget {
  const HomeworkSubmitScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  ConsumerState<HomeworkSubmitScreen> createState() =>
      _HomeworkSubmitScreenState();
}

class _HomeworkSubmitScreenState extends ConsumerState<HomeworkSubmitScreen> {
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  HomeworkSubmitViewModel get _vm =>
      ref.read(homeworkSubmitViewModelProvider(widget.avatarId).notifier);

  Future<void> _submit() async {
    await _vm.submit(
      title: _titleController.text,
      subject: _subjectController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(homeworkSubmitViewModelProvider(widget.avatarId));

    // On success, pop back to the list (which refreshes on return).
    ref.listen(homeworkSubmitViewModelProvider(widget.avatarId),
        (prev, next) {
      if (next.submitted && (prev == null || !prev.submitted)) {
        if (context.mounted) context.pop();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: const BackButton(),
        title: Text(l10n.hwSubmit, style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AdaptiveContentWidth(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.hwFieldTitle,
                    style: AppTextStyles.label.copyWith(color: AppColors.text2)),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDecoration(l10n.hwFieldTitleHint),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.hwFieldSubject,
                    style: AppTextStyles.label.copyWith(color: AppColors.text2)),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _subjectController,
                  decoration: _fieldDecoration(l10n.hwFieldSubjectHint),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.hwYourWork,
                    style: AppTextStyles.label.copyWith(color: AppColors.text2)),
                const SizedBox(height: AppSpacing.sm),
                _AddButtons(
                  onScan: _vm.pickFromCamera,
                  onPhoto: _vm.pickPhoto,
                  onPdf: _vm.pickPdf,
                  enabled: !state.isSubmitting,
                ),
                if (state.files.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  ...List.generate(state.files.length, (i) {
                    final f = state.files[i];
                    return _AttachedFileRow(
                      name: f.name,
                      onRemove: state.isSubmitting
                          ? null
                          : () => _vm.removeFile(i),
                    );
                  }),
                ],
                if (state.error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _InlineError(message: state.error!),
                ],
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state.canSubmit ? _submit : null,
                    icon: state.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(state.isSubmitting
                        ? l10n.hwSubmitting
                        : l10n.hwSubmitToTeacher),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      disabledBackgroundColor: AppColors.outline,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.hwReviewNote,
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.text3),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.text3),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
          borderSide: const BorderSide(color: AppColors.purple, width: 1.5),
        ),
      );
}

class _AddButtons extends StatelessWidget {
  const _AddButtons({
    required this.onScan,
    required this.onPhoto,
    required this.onPdf,
    required this.enabled,
  });

  final VoidCallback onScan;
  final VoidCallback onPhoto;
  final VoidCallback onPdf;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _AddChip(
            icon: Icons.document_scanner_rounded,
            label: l10n.hwChipScan,
            onTap: enabled ? onScan : null),
        _AddChip(
            icon: Icons.photo_library_rounded,
            label: l10n.hwChipPhoto,
            onTap: enabled ? onPhoto : null),
        _AddChip(
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF',
            onTap: enabled ? onPdf : null),
      ],
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.purpleL,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.purple),
              const SizedBox(width: AppSpacing.xs),
              Text(label,
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.purple, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachedFileRow extends StatelessWidget {
  const _AttachedFileRow({required this.name, this.onRemove});
  final String name;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surf2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            name.toLowerCase().endsWith('.pdf')
                ? Icons.picture_as_pdf_rounded
                : Icons.image_rounded,
            size: 18,
            color: AppColors.text2,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(name,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.text1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppColors.text3,
              visualDensity: VisualDensity.compact,
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.coralL,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: AppColors.coral),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message,
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.text1)),
          ),
        ],
      ),
    );
  }
}
