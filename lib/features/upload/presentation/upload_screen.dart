import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_relevance_warning_dialog.dart';
import 'package:pally/core/widgets/loading/mochi_generating.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/upload_result.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/upload/presentation/upload_view_model.dart';

class UploadScreen extends ConsumerWidget {
  const UploadScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadViewModelProvider(avatarId));
    final vm = ref.read(uploadViewModelProvider(avatarId).notifier);

    // Toast single-file errors; multi-file errors are shown inline via
    // _FileErrorList so each file gets its own message.
    ref.listen<UploadState>(uploadViewModelProvider(avatarId), (prev, next) {
      final newError = next.error != null && prev?.error != next.error;
      if (!newError || !context.mounted) return;
      // Only toast if there's a single error (no per-file errors list yet).
      // When there are per-file errors the UI card is more informative.
      if (next.fileErrors.length <= 1) {
        PallyToast.error(context, next.error ?? 'Upload failed — try again.');
      }
    });

    // Show relevance warning when check completes and result is not relevant
    ref.listen(uploadViewModelProvider(avatarId), (prev, next) async {
      if (next.pendingRelevance != null &&
          !next.pendingRelevance!.isRelevant &&
          next.pendingFile != null &&
          context.mounted) {
        final subject = next.avatar?.subject ?? 'this subject';
        final addAnyway = await PallyRelevanceWarningDialog.show(
          context: context,
          subject: subject,
          reason: next.pendingRelevance!.reason,
        );
        if (addAnyway == true && next.pendingFile != null) {
          await vm.uploadFile(next.pendingFile!, skipRelevance: true);
        } else {
          vm.clearPendingRelevance();
        }
      }
    });

    // Full-screen Mochi generating overlay while upload/process is in progress.
    final bool uploading = state.isUploading || state.isCheckingRelevance;
    if (uploading) {
      return _UploadLoadingScreen(state: state);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              const HomeRoute().go(context);
            }
          },
        ),
        title: const Text('Add Knowledge'),
        actions: [
          TextButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                const HomeRoute().go(context);
              }
            },
            child: Text('Done',
                style: AppTextStyles.body.copyWith(
                    color: AppColors.purple, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _HeroPanel(avatar: state.avatar),
            const SizedBox(height: AppSpacing.md),
            const _TipBanner(),
            const SizedBox(height: AppSpacing.sm),
            _ContextTagBar(
              topicTag: state.topicTag,
              sourceType: state.sourceType,
              onTopicChanged: vm.setTopicTag,
              onSourceChanged: vm.setSourceType,
            ),
            const SizedBox(height: AppSpacing.md),
            _UploadOptions(
              isUploading: state.isUploading,
              isCheckingRelevance: state.isCheckingRelevance,
              onCamera: vm.pickFromCamera,
              onPdf: vm.pickPdf,
              onPasteText: vm.pasteText,
            ),
            // Brain compiling banner — shown after upload while Gemini compiles
            if (state.compilingFileCount > 0 &&
                (state.uploadStage == UploadStage.compilingBrain ||
                    state.uploadStage == UploadStage.chunkedCompile)) ...[
              const SizedBox(height: AppSpacing.md),
              _BrainCompilingBanner(state: state),
            ],
            if (state.hasFiles) ...[
              const SizedBox(height: AppSpacing.md),
              _FileList(
                files: state.files,
                onDelete: vm.deleteFile,
              ),
            ],
            // Per-file error cards shown after upload batch completes
            if (state.fileErrors.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _FileErrorList(
                errors: state.fileErrors,
                onDismiss: vm.clearErrors,
                avatarId: avatarId,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Per-file error list ───────────────────────────────────────────────────────

class _FileErrorList extends ConsumerWidget {
  const _FileErrorList({
    required this.errors,
    required this.onDismiss,
    required this.avatarId,
  });
  final List<FileUploadError> errors;
  final VoidCallback onDismiss;
  final String avatarId;

  static bool _isOcrError(String message) =>
      message.contains('photo') ||
      message.contains('retake') ||
      message.contains('dark') ||
      message.contains('blurry') ||
      message.contains('scanned image');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(uploadViewModelProvider(avatarId).notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 16, color: AppColors.amber),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                errors.length == 1
                    ? '1 file couldn\'t be uploaded'
                    : '${errors.length} files couldn\'t be uploaded',
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close_rounded,
                  size: 16, color: AppColors.text3),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ...errors.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.coralL,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.coral.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.fileName,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(e.message,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.coral)),
                    // Show a "Retake photo" button for OCR/photo failures
                    if (_isOcrError(e.message)) ...[
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            onDismiss();
                            vm.pickFromCamera();
                          },
                          icon: const Icon(Icons.camera_alt_rounded,
                              size: 16, color: AppColors.coral),
                          label: const Text('Retake photo',
                              style: TextStyle(color: AppColors.coral)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.coral),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.avatar});
  final Avatar? avatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      decoration: BoxDecoration(
        color: AppColors.purpleL,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.md),
          if (avatar != null)
            CharacterWidget(character: avatar!.character, size: 80)
          else
            const SizedBox(
              width: 80,
              height: 80,
              child: Icon(Icons.smart_toy_outlined,
                  size: 60, color: AppColors.text3),
            ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SpeechBubble(
                  text: avatar != null
                      ? 'Teach me your ${avatar!.subject} material — your notes become my brain! 🧠'
                      : 'Teach me your material — I only learn from what you give me! 🧠',
                ),
                const SizedBox(height: 4),
                Text(
                  'Your notes become my brain.',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.text2),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.text1),
      ),
    );
  }
}

class _TipBanner extends StatelessWidget {
  const _TipBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.amberL,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded,
              color: AppColors.amber, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Tip: Upload clear photos of your notes or textbook pages for the best results!',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.text1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadOptions extends StatelessWidget {
  const _UploadOptions({
    required this.isUploading,
    required this.isCheckingRelevance,
    required this.onCamera,
    required this.onPdf,
    required this.onPasteText,
  });

  final bool isUploading;
  final bool isCheckingRelevance;
  final VoidCallback onCamera;
  final VoidCallback onPdf;
  final ValueChanged<String> onPasteText;

  bool get _busy => isUploading || isCheckingRelevance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add files', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.sm),
        // MochiGenerating overlay is shown at the UploadScreen level —
        // this fallback should never be visible, but kept for safety.
        if (_busy)
          const SizedBox.shrink()
        else ...[
          _UploadTile(
            icon: Icons.camera_alt_outlined,
            title: 'Take a photo',
            subtitle: 'Snap your notes or textbook',
            onTap: onCamera,
          ),
          const Divider(height: 1),
          _UploadTile(
            icon: Icons.picture_as_pdf_outlined,
            title: 'Upload PDF',
            subtitle: 'Choose a PDF from your device',
            onTap: onPdf,
          ),
          const Divider(height: 1),
          _UploadTile(
            icon: Icons.text_snippet_outlined,
            title: 'Paste text',
            subtitle: 'Copy-paste notes directly',
            onTap: () => _showPasteDialog(context),
          ),
        ],
      ],
    );
  }

  void _showPasteDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => const _PasteTextDialog(),
    );
    if (result != null && result.trim().isNotEmpty) {
      onPasteText(result);
    }
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.purpleL,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.purple, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileList extends StatelessWidget {
  const _FileList({required this.files, required this.onDelete});

  final List<UploadResult> files;
  final ValueChanged<String> onDelete;

  String _statusIcon(UploadStatus status) {
    switch (status) {
      case UploadStatus.pending:
        return '⏳';
      case UploadStatus.processing:
        return '⚙️';
      case UploadStatus.ready:
        return '✅';
      case UploadStatus.failed:
        return '❌';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploaded files (${files.length})',
          style: AppTextStyles.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: files.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final file = files[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.tealL,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _statusIcon(file.status),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              title: Text(
                file.fileName,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: file.pageCount > 0
                  ? Text(
                      '${file.pageCount} page${file.pageCount != 1 ? 's' : ''}',
                      style: AppTextStyles.caption,
                    )
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.coral),
                onPressed: () => onDelete(file.id),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PasteTextDialog extends StatefulWidget {
  const _PasteTextDialog();

  @override
  State<_PasteTextDialog> createState() => _PasteTextDialogState();
}

class _PasteTextDialogState extends State<_PasteTextDialog> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    final has = _controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text('Paste your notes', style: AppTextStyles.title),
      content: TextField(
        controller: _controller,
        maxLines: 8,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Paste or type your notes here…',
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.text3),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel',
              style: AppTextStyles.body.copyWith(color: AppColors.text2)),
        ),
        FilledButton(
          onPressed: _hasText
              ? () => Navigator.of(context).pop(_controller.text.trim())
              : null,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

extension on BuildContext {
  bool canPop() => Navigator.of(this).canPop();
  void pop() => Navigator.of(this).pop();
}

// ── P7: Context tag bar ───────────────────────────────────────────────────────

class _ContextTagBar extends StatelessWidget {
  const _ContextTagBar({
    required this.topicTag,
    required this.sourceType,
    required this.onTopicChanged,
    required this.onSourceChanged,
  });

  final String? topicTag;
  final String? sourceType;
  final ValueChanged<String?> onTopicChanged;
  final ValueChanged<String?> onSourceChanged;

  static const _sourceTypes = ['Textbook', 'Notes', 'Website', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tag this upload (optional)',
            style: AppTextStyles.label.copyWith(color: AppColors.text2)),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            // Topic tag text field
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextField(
                  onChanged: (v) => onTopicChanged(v.isEmpty ? null : v),
                  decoration: InputDecoration(
                    hintText: 'Topic (e.g. Algebra)',
                    hintStyle:
                        AppTextStyles.caption.copyWith(color: AppColors.text3),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.outline),
                    ),
                  ),
                  style: AppTextStyles.caption.copyWith(color: AppColors.text1),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Source type dropdown
            DropdownButton<String>(
              value: sourceType,
              hint: Text('Source',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.text3)),
              underline: const SizedBox(),
              style: AppTextStyles.caption.copyWith(color: AppColors.text1),
              items: _sourceTypes
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: onSourceChanged,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Rich loading overlay with stage-aware copy ────────────────────────────────

class _UploadLoadingScreen extends StatelessWidget {
  const _UploadLoadingScreen({required this.state});
  final UploadState state;

  @override
  Widget build(BuildContext context) {
    final stage = state.uploadStage;
    final isLarge = state.isLargeFile;
    final sizeLabel = _sizeLabel(state.pendingFileSizeBytes);
    final fileName = state.pendingFile?.name ?? '';

    final (stepLabels, stepDuration) = switch (stage) {
      UploadStage.checkingRelevance => (
          const ['Reviewing content…', 'Checking relevance…'],
          const Duration(seconds: 3),
        ),
      UploadStage.uploading when isLarge => (
          const [
            'Sending to server…',
            'Processing document…',
            'Extracting text…',
            'Almost there…',
          ],
          const Duration(seconds: 5),
        ),
      _ => (
          const ['Sending…', 'Processing…'],
          const Duration(seconds: 3),
        ),
    };

    final title = switch (stage) {
      UploadStage.checkingRelevance => 'Checking your notes…',
      UploadStage.uploading when isLarge => 'Uploading large document…',
      UploadStage.uploading => 'Uploading…',
      _ => 'Processing…',
    };

    final subtitle = switch (stage) {
      UploadStage.checkingRelevance =>
        'Making sure this fits Mochi\'s subject',
      UploadStage.uploading when isLarge =>
        'File: $sizeLabel${fileName.isNotEmpty ? " · $fileName" : ""}',
      UploadStage.uploading => fileName.isNotEmpty ? fileName : 'Sending your notes',
      _ => '',
    };

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Step indicator pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.purpleL,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.purple),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _stageLabel(stage),
                      style:
                          AppTextStyles.label.copyWith(color: AppColors.purple),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              MochiGenerating(
                stepLabels: stepLabels,
                stepDuration: stepDuration,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title,
                  style: AppTextStyles.title, textAlign: TextAlign.center),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle,
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.text2),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              // Large-file warning card
              if (isLarge && stage == UploadStage.uploading) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.amberL,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.amber),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.amber, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Large document detected',
                                style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.amber)),
                            const SizedBox(height: 4),
                            Text(
                              'Mochi will split this into sections for better accuracy. '
                              'The brain will take ${state.estimatedCompileTime} to update after upload.',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.amber),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _stageLabel(UploadStage stage) => switch (stage) {
        UploadStage.checkingRelevance => 'Step 1 of 3 — Relevance check',
        UploadStage.uploading => 'Step 2 of 3 — Uploading',
        UploadStage.extractingText => 'Step 3 of 3 — Reading text',
        _ => 'Processing',
      };

  String _sizeLabel(int bytes) {
    if (bytes == 0) return 'large file';
    final mb = bytes / (1024 * 1024);
    return mb >= 1 ? '${mb.toStringAsFixed(1)} MB' : '${(bytes / 1024).round()} KB';
  }
}

// ── Brain compiling banner (shown after upload, while Gemini compiles) ────────

class _BrainCompilingBanner extends StatelessWidget {
  const _BrainCompilingBanner({required this.state});
  final UploadState state;

  @override
  Widget build(BuildContext context) {
    final isChunked = state.uploadStage == UploadStage.chunkedCompile;
    final eta = state.estimatedCompileTime;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isChunked ? AppColors.amberL : AppColors.tealL,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isChunked ? AppColors.amber : AppColors.teal,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isChunked ? AppColors.amber : AppColors.teal,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  isChunked
                      ? '🧩 Building brain in sections…'
                      : '🧠 Mochi is reading your notes…',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isChunked ? AppColors.amber : AppColors.teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isChunked
                ? 'Your document is large — Mochi splits it into sections for better accuracy. Expected: $eta. You can close this screen; the brain updates automatically.'
                : 'New pages will appear in your brain map shortly. Expected: $eta.',
            style: AppTextStyles.bodySmall.copyWith(
              color: isChunked ? AppColors.amber : AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }
}
