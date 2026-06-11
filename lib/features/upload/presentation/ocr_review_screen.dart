import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/upload/presentation/upload_view_model.dart';

/// Review screen shown when an image upload has BORDERLINE OCR quality.
/// The user can approve, edit, re-upload, or switch to typing.
class OcrReviewScreen extends ConsumerStatefulWidget {
  const OcrReviewScreen({
    super.key,
    required this.avatarId,
    required this.fileId,
    required this.qualityReason,
    required this.extractedText,
  });

  final String avatarId;
  final String fileId;
  final String qualityReason;
  final String extractedText;

  @override
  ConsumerState<OcrReviewScreen> createState() => _OcrReviewScreenState();
}

class _OcrReviewScreenState extends ConsumerState<OcrReviewScreen> {
  late final TextEditingController _textCtrl;
  bool _isEdited = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.extractedText);
    _textCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final edited = _textCtrl.text.trim() != widget.extractedText.trim();
    if (edited != _isEdited) setState(() => _isEdited = edited);
  }

  @override
  void dispose() {
    _textCtrl.removeListener(_onTextChanged);
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _approve() async {
    setState(() => _isSubmitting = true);
    final vm = ref.read(uploadViewModelProvider(widget.avatarId).notifier);
    await vm.reviewFile(widget.fileId, action: 'APPROVE');
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _saveEdits() async {
    setState(() => _isSubmitting = true);
    final vm = ref.read(uploadViewModelProvider(widget.avatarId).notifier);
    await vm.reviewFile(
      widget.fileId,
      action: 'EDIT',
      editedText: _textCtrl.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
  }

  void _reUpload() {
    final vm = ref.read(uploadViewModelProvider(widget.avatarId).notifier);
    vm.clearOcrReview();
    Navigator.of(context).pop('reupload');
  }

  void _typeInstead() {
    final vm = ref.read(uploadViewModelProvider(widget.avatarId).notifier);
    vm.clearOcrReview();
    Navigator.of(context).pop('type');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Review extracted text'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            ref
                .read(uploadViewModelProvider(widget.avatarId).notifier)
                .clearOcrReview();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Yellow info banner with quality reason
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.amberL,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.amber.withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 20, color: AppColors.amber),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      widget.qualityReason,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.text1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Editable text field
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: TextField(
                  controller: _textCtrl,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Extracted text...',
                    hintStyle:
                        AppTextStyles.body.copyWith(color: AppColors.text3),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.outline),
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  style: AppTextStyles.body,
                ),
              ),
            ),
            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  if (_isEdited)
                    SizedBox(
                      width: double.infinity,
                      height: AppSizing.buttonHeight,
                      child: FilledButton(
                        onPressed: _isSubmitting ? null : _saveEdits,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: AppSizing.spinnerSm,
                                height: AppSizing.spinnerSm,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text('Save edits',
                                style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: AppSizing.buttonHeight,
                      child: FilledButton(
                        onPressed: _isSubmitting ? null : _approve,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: AppSizing.spinnerSm,
                                height: AppSizing.spinnerSm,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text('Looks good',
                                style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: AppSizing.buttonHeightSm,
                          child: OutlinedButton(
                            onPressed: _isSubmitting ? null : _reUpload,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.outline),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Re-upload',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.text2,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: SizedBox(
                          height: AppSizing.buttonHeightSm,
                          child: OutlinedButton(
                            onPressed: _isSubmitting ? null : _typeInstead,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.outline),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Type instead',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.text2,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height:
                          MediaQuery.of(context).padding.bottom + AppSpacing.xs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
