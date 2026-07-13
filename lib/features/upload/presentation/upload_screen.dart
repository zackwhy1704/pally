import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/adaptive_center.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_relevance_warning_dialog.dart';
import 'package:pally/core/widgets/loading/mochi_generating.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/upload/presentation/upload_view_model.dart';
import 'package:pally/features/upload/presentation/ocr_review_screen.dart';
import 'package:pally/features/upload/presentation/widgets/upload_tips_banner.dart';
import 'package:pally/features/centre/centre_mode.dart';
import 'package:pally/features/chapters/presentation/chapter_picker_sheet.dart';

class UploadScreen extends ConsumerWidget {
  const UploadScreen({super.key, required this.avatarId});

  final String avatarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadViewModelProvider(avatarId));
    final vm = ref.read(uploadViewModelProvider(avatarId).notifier);

    // Defence-in-depth: if this avatar is centre-managed, uploads are not
    // allowed. Redirect back immediately — the calling screens already hide
    // the entry point, so this only fires if someone navigates directly.
    final centreConfig = state.avatar != null
        ? resolveCentreMode(ref, state.avatar!)
        : CentreModeConfig.inactive;
    if (centreConfig.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }

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

    // Show OCR review screen when quality is BORDERLINE
    ref.listen<UploadState>(uploadViewModelProvider(avatarId), (prev, next) {
      if (next.needsOcrReview &&
          next.reviewFileId != null &&
          prev?.reviewFileId != next.reviewFileId &&
          context.mounted) {
        Navigator.of(context)
            .push<String>(
          MaterialPageRoute(
            builder: (_) => OcrReviewScreen(
              avatarId: avatarId,
              fileId: next.reviewFileId!,
              qualityReason: next.uploadQualityReason ?? 'Some text may need review.',
              extractedText: next.uploadExtractedText ?? '',
            ),
          ),
        )
            .then((result) {
          if (!context.mounted) return;
          if (result == 'reupload') {
            vm.pickFromCamera();
          } else if (result == 'type') {
            // Pre-fill with extracted text and show paste dialog
            final extracted = next.uploadExtractedText ?? '';
            if (extracted.isNotEmpty) {
              vm.pasteText(extracted);
            }
          }
        });
      }
    });

    // Show relevance warning when check completes and result is not relevant
    ref.listen(uploadViewModelProvider(avatarId), (prev, next) async {
      if (next.pendingRelevance != null &&
          (!next.pendingRelevance!.isRelevant ||
              !next.pendingRelevance!.studyMaterial) &&
          next.pendingFile != null &&
          context.mounted) {
        final subject = next.avatar?.subject ?? 'this subject';
        // A2 (origin-aware / gentle): a "not study material" verdict gets a soft,
        // non-judgemental message rather than the off-topic one.
        final reason = !next.pendingRelevance!.studyMaterial
            ? "This doesn't look like study material. Add it anyway?"
            : next.pendingRelevance!.reason;
        final addAnyway = await PallyRelevanceWarningDialog.show(
          context: context,
          subject: subject,
          reason: reason,
        );
        if (addAnyway == true && next.pendingFile != null) {
          await vm.uploadFile(next.pendingFile!, skipRelevance: true);
        } else {
          vm.clearPendingRelevance();
        }
      }
    });

    // Large-file PREFLIGHT: pre-empt the (genuinely slow) compile by setting
    // expectations before the user commits. Mirrors the relevance-dialog idiom.
    ref.listen(uploadViewModelProvider(avatarId), (prev, next) async {
      if (next.uploadStage == UploadStage.awaitingLargeFileConfirm &&
          prev?.uploadStage != UploadStage.awaitingLargeFileConfirm &&
          next.pendingFile != null &&
          context.mounted) {
        final mb = (next.pendingFileSizeBytes / (1024 * 1024)).toStringAsFixed(1);
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Large file — this takes a few minutes'),
            content: Text(
              'This is a large file (${mb}MB). Building your brain from it can '
              'take about ${next.estimatedCompileTime}. You can leave this screen — '
              'Mochi keeps building in the background and updates automatically '
              'when it\'s ready.',
              style: AppTextStyles.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Build my brain'),
              ),
            ],
          ),
        );
        if (proceed == true) {
          await vm.confirmLargeFileUpload();
        } else {
          vm.cancelLargeFileUpload();
        }
      }
    });

    // Chapter picker: a large doc was segmented into chapters. Show the picker (the
    // SAME UX the locked-chapter surface opens); nothing compiled until a pick.
    ref.listen(uploadViewModelProvider(avatarId), (prev, next) async {
      if (next.uploadStage == UploadStage.awaitingChapterPick &&
          prev?.uploadStage != UploadStage.awaitingChapterPick &&
          context.mounted) {
        await showChapterPicker(context,
            avatarId: avatarId, pointToLibraryOnSuccess: true, ref: ref);
        // Return the screen to idle whether they picked, compiled, or dismissed —
        // the locked chapters live on the brain surface for the return loop.
        if (context.mounted) vm.resetToIdle();
      }
    });

    // Full-screen loading overlay: blocks navigation during upload + compile.
    // Terminal states (success / failed / timeout) also show full-screen so
    // the user gets a clear outcome before continuing.
    if (state.showsLoadingOverlay || state.isTerminalState) {
      return _UploadLoadingScreen(state: state, avatarId: avatarId);
    }

    return _UploadScreenContent(avatarId: avatarId, state: state);
  }
}

// ── Main content with tab bar ────────────────────────────────────────────────

class _UploadScreenContent extends ConsumerStatefulWidget {
  const _UploadScreenContent({
    required this.avatarId,
    required this.state,
  });

  final String avatarId;
  final UploadState state;

  @override
  ConsumerState<_UploadScreenContent> createState() =>
      _UploadScreenContentState();
}

class _UploadScreenContentState extends ConsumerState<_UploadScreenContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final vm = ref.read(uploadViewModelProvider(widget.avatarId).notifier);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_canPop(context)) {
              Navigator.of(context).pop();
            } else {
              const HomeRoute().go(context);
            }
          },
        ),
        title: const Text('Add Knowledge'),
        actions: [
          TextButton(
            onPressed: () {
              if (_canPop(context)) {
                Navigator.of(context).pop();
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
        child: Column(
          children: [
            _HeroPanel(avatar: state.avatar),
            const SizedBox(height: AppSpacing.sm),
            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surf2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withValues(alpha: 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(3),
                dividerColor: Colors.transparent,
                labelColor: AppColors.purple,
                unselectedLabelColor: AppColors.text3,
                labelStyle: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: const [
                  Tab(text: 'Type'),
                  Tab(text: 'Photo'),
                  Tab(text: 'File'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _TypeTab(
                    avatarId: widget.avatarId,
                    subject: state.avatar?.subject,
                    isBusy: state.isBusy,
                  ),
                  _PhotoTab(
                    isUploading: state.isUploading,
                    isCheckingRelevance: state.isCheckingRelevance,
                    onCamera: vm.pickFromCamera,
                    topicTag: state.topicTag,
                    sourceType: state.sourceType,
                    onTopicChanged: vm.setTopicTag,
                    onSourceChanged: vm.setSourceType,
                  ),
                  _FileTab(
                    isUploading: state.isUploading,
                    isCheckingRelevance: state.isCheckingRelevance,
                    onPdf: vm.pickPdf,
                    topicTag: state.topicTag,
                    sourceType: state.sourceType,
                    onTopicChanged: vm.setTopicTag,
                    onSourceChanged: vm.setSourceType,
                  ),
                ],
              ),
            ),
            // Shared sections below tabs: file list, errors, warnings
            if (state.compilingFileCount > 0 &&
                (state.uploadStage == UploadStage.compilingBrain ||
                    state.uploadStage == UploadStage.chunkedCompile))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _BrainCompilingBanner(state: state),
              ),
            if (state.hasFiles)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                child: _CollapsedFileCount(count: state.totalFiles),
              ),
            if (state.fileWarnings.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                child: _FileWarningList(warnings: state.fileWarnings),
              ),
            if (state.fileErrors.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                child: _FileErrorList(
                  errors: state.fileErrors,
                  onDismiss: vm.clearErrors,
                  avatarId: widget.avatarId,
                ),
              ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.xs),
          ],
        ),
      ),
    );
  }

  bool _canPop(BuildContext context) => Navigator.of(context).canPop();
}

// ── Type tab ─────────────────────────────────────────────────────────────────

class _TypeTab extends ConsumerStatefulWidget {
  const _TypeTab({
    required this.avatarId,
    required this.subject,
    required this.isBusy,
  });

  final String avatarId;
  final String? subject;
  final bool isBusy;

  @override
  ConsumerState<_TypeTab> createState() => _TypeTabState();
}

class _TypeTabState extends ConsumerState<_TypeTab>
    with AutomaticKeepAliveClientMixin {
  final _textCtrl = TextEditingController();
  int _charCount = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(_onChanged);
  }

  void _onChanged() {
    final len = _textCtrl.text.length;
    if (len != _charCount) setState(() => _charCount = len);
  }

  @override
  void dispose() {
    _textCtrl.removeListener(_onChanged);
    _textCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _charCount >= 50 && !widget.isBusy;

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _textCtrl.text = data.text!;
      _textCtrl.selection =
          TextSelection.collapsed(offset: _textCtrl.text.length);
    }
  }

  void _submit() {
    if (!_canSubmit) return;
    final vm = ref.read(uploadViewModelProvider(widget.avatarId).notifier);
    vm.uploadTypedText(_textCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final charColor = _charCount > 5000 ? AppColors.coral : AppColors.text3;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      children: [
        const SizedBox(height: AppSpacing.sm),
        if (widget.subject != null)
          Text(
            'Adding notes to ${widget.subject}',
            style: AppTextStyles.label.copyWith(color: AppColors.text2),
          ),
        const SizedBox(height: AppSpacing.sm),
        // Tip
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.tealL,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Typed notes give the best results. Paste from Google Docs or type from your textbook.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.teal),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Text field
        TextField(
          controller: _textCtrl,
          maxLines: 10,
          minLines: 6,
          textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(
            hintText: 'Paste or type your notes here...',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.text3),
            filled: true,
            fillColor: AppColors.surface,
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
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
          style: AppTextStyles.body,
        ),
        const SizedBox(height: AppSpacing.xs),
        // Character count + paste button row
        Row(
          children: [
            TextButton.icon(
              onPressed: _pasteFromClipboard,
              icon: const Icon(Icons.content_paste_rounded,
                  size: 16, color: AppColors.purple),
              label: Text('Paste from clipboard',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.purple)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const Spacer(),
            Text(
              '$_charCount chars${_charCount < 50 ? ' (min 50)' : ''}',
              style: AppTextStyles.caption.copyWith(color: charColor),
            ),
          ],
        ),
        if (_charCount > 5000)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              'Consider splitting long notes into separate uploads for better accuracy.',
              style: AppTextStyles.caption.copyWith(color: AppColors.amber),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        // Submit button
        SizedBox(
          width: double.infinity,
          height: AppSizing.buttonHeight,
          child: FilledButton(
            onPressed: _canSubmit ? _submit : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: widget.isBusy
                ? const SizedBox(
                    width: AppSizing.spinnerSm,
                    height: AppSizing.spinnerSm,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text('Add to Mochi',
                    style: AppTextStyles.body.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

// ── Photo tab ────────────────────────────────────────────────────────────────

class _PhotoTab extends StatelessWidget {
  const _PhotoTab({
    required this.isUploading,
    required this.isCheckingRelevance,
    required this.onCamera,
    required this.topicTag,
    required this.sourceType,
    required this.onTopicChanged,
    required this.onSourceChanged,
  });

  final bool isUploading;
  final bool isCheckingRelevance;
  final VoidCallback onCamera;
  final String? topicTag;
  final String? sourceType;
  final ValueChanged<String?> onTopicChanged;
  final ValueChanged<String?> onSourceChanged;

  bool get _busy => isUploading || isCheckingRelevance;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      children: [
        const SizedBox(height: AppSpacing.sm),
        const UploadTipsBanner(),
        const SizedBox(height: AppSpacing.sm),
        _ContextTagBar(
          topicTag: topicTag,
          sourceType: sourceType,
          onTopicChanged: onTopicChanged,
          onSourceChanged: onSourceChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        if (!_busy) ...[
          _UploadTile(
            icon: Icons.camera_alt_outlined,
            title: 'Take a photo',
            subtitle: 'Snap your notes or textbook',
            onTap: onCamera,
          ),
        ],
      ],
    );
  }
}

// ── File tab ─────────────────────────────────────────────────────────────────

class _FileTab extends StatelessWidget {
  const _FileTab({
    required this.isUploading,
    required this.isCheckingRelevance,
    required this.onPdf,
    required this.topicTag,
    required this.sourceType,
    required this.onTopicChanged,
    required this.onSourceChanged,
  });

  final bool isUploading;
  final bool isCheckingRelevance;
  final VoidCallback onPdf;
  final String? topicTag;
  final String? sourceType;
  final ValueChanged<String?> onTopicChanged;
  final ValueChanged<String?> onSourceChanged;

  bool get _busy => isUploading || isCheckingRelevance;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      children: [
        const SizedBox(height: AppSpacing.sm),
        const UploadTipsBanner(),
        const SizedBox(height: AppSpacing.sm),
        _ContextTagBar(
          topicTag: topicTag,
          sourceType: sourceType,
          onTopicChanged: onTopicChanged,
          onSourceChanged: onSourceChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        if (!_busy) ...[
          _UploadTile(
            icon: Icons.picture_as_pdf_outlined,
            title: 'Upload PDF',
            subtitle: 'Choose a PDF from your device',
            onTap: onPdf,
          ),
        ],
      ],
    );
  }
}

// ── Per-file warning notes (non-error) ───────────────────────────────────────

class _FileWarningList extends StatelessWidget {
  const _FileWarningList({required this.warnings});
  final List<FileUploadWarning> warnings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: warnings.map((w) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.amberL,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppColors.amber.withValues(alpha: 0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.amber),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w.fileName,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.amber,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(w.message,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.text2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      )).toList(),
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
      height: AppSizing.heroPanelHeight,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.purpleL,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.md),
          if (avatar != null)
            CharacterWidget.forAvatar(avatar!, AppSizing.heroMochiSize)
          else
            const SizedBox(
              width: AppSizing.heroMochiSize,
              height: AppSizing.heroMochiSize,
              child: Icon(Icons.smart_toy_outlined,
                  size: AppSizing.iconContainer, color: AppColors.text3),
            ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SpeechBubble(
                  text: avatar != null
                      ? 'Teach me your ${avatar!.subject} material — your notes become my brain!'
                      : 'Teach me your material — I only learn from what you give me!',
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: AppSizing.buttonHeightSm,
                height: AppSizing.buttonHeightSm,
                decoration: BoxDecoration(
                  color: AppColors.purpleL,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.purple, size: AppSizing.icon18),
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

// ── Collapsed file count (compact summary for below tabs) ────────────────────

class _CollapsedFileCount extends StatelessWidget {
  const _CollapsedFileCount({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.tealL,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 16, color: AppColors.teal),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              '$count file${count != 1 ? 's' : ''} uploaded',
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
                height: AppSizing.fieldHeightSm,
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
  const _UploadLoadingScreen({required this.state, required this.avatarId});
  final UploadState state;
  final String avatarId;

  @override
  Widget build(BuildContext context) {
    final stage = state.uploadStage;

    // ── Terminal states: success / failed / timeout ───────────────────────
    if (stage == UploadStage.compileSuccess) {
      return _TerminalScreen(
        icon: Icons.check_circle_rounded,
        iconColor: AppColors.green,
        title: 'Brain updated!',
        message: 'Mochi has read your notes and added them to the brain. '
            'You can now chat, quiz, and review your notes.',
        primaryLabel: 'Start chatting',
        onPrimary: () => const HomeRoute().go(context),
        secondaryLabel: 'Add more notes',
        onSecondary: () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
      );
    }

    if (stage == UploadStage.compileFailed ||
        stage == UploadStage.compileTimeout) {
      final isTimeout = stage == UploadStage.compileTimeout;
      // A large-file timeout is EXPECTED (big docs are slow), so frame it as
      // reassuring progress, not a problem — distinct from a real failure.
      final isLargeTimeout = isTimeout && state.isLargeFile;
      return _TerminalScreen(
        icon: isTimeout
            ? Icons.hourglass_disabled_rounded
            : Icons.error_outline_rounded,
        iconColor: AppColors.amber,
        title: isLargeTimeout
            ? 'Still building your brain'
            : isTimeout
                ? 'Taking longer than expected...'
                : 'Something went wrong',
        message: state.error ??
            (isLargeTimeout
                ? 'Large files take a few minutes to compile. Mochi is still '
                    'working on it in the background and will update your brain '
                    'automatically when it\'s ready — no need to re-upload.'
                : isTimeout
                    ? 'Mochi is still working on your notes in the background. '
                        'Check back in a few minutes — the brain will update automatically.'
                    : 'Mochi couldn\'t process your notes. '
                        'Try uploading again with a smaller file or different format.'),
        primaryLabel: 'Return to home',
        onPrimary: () => const HomeRoute().go(context),
        secondaryLabel: isTimeout ? 'Check brain later' : 'Try again',
        onSecondary: isTimeout
            ? () => const HomeRoute().go(context)
            : () {
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              },
      );
    }

    // ── Active loading: upload + compile ─────────────────────────────────
    final isLarge = state.isLargeFile;
    final isCompiling = stage == UploadStage.compilingBrain ||
        stage == UploadStage.chunkedCompile;
    final fileName = state.pendingFile?.name ?? '';

    final stepLabels = switch (stage) {
      UploadStage.checkingRelevance => const [
          'Step 1 of 3 — Reviewing content...',
          'Step 1 of 3 — Checking relevance...',
        ],
      UploadStage.uploading when isLarge => const [
          'Step 2 of 3 — Sending to server...',
          'Step 2 of 3 — Processing document...',
          'Step 2 of 3 — Extracting text...',
          'Step 2 of 3 — Almost there...',
        ],
      UploadStage.compilingBrain || UploadStage.chunkedCompile => [
          'Step 3 of 3 — Reading your notes...',
          'Step 3 of 3 — Finding key concepts...',
          'Step 3 of 3 — Building brain pages...',
          if (isLarge) 'Step 3 of 3 — Processing sections...',
          'Step 3 of 3 — Almost ready...',
        ],
      _ => const ['Step 2 of 3 — Sending...', 'Step 2 of 3 — Processing...'],
    };

    final stepDuration = isCompiling
        ? const Duration(seconds: 6)
        : (isLarge ? const Duration(seconds: 5) : const Duration(seconds: 3));

    final lines = <String>[];
    if (isCompiling && state.compileProgress != null) {
      lines.add(state.compileProgress!);
    } else if (isCompiling && isLarge) {
      lines.add('Large document — splitting into sections (~${state.estimatedCompileTime})');
    } else if (isCompiling) {
      lines.add('This usually takes 30-60 seconds');
    } else if (stage == UploadStage.uploading && isLarge) {
      lines.add('File: ${_sizeLabel(state.pendingFileSizeBytes)}${fileName.isNotEmpty ? " · $fileName" : ""}');
    } else if (stage == UploadStage.uploading && fileName.isNotEmpty) {
      lines.add(fileName);
    } else if (stage == UploadStage.checkingRelevance) {
      lines.add('Making sure this fits the subject...');
    }

    final combinedLabel = [
      switch (stage) {
        UploadStage.checkingRelevance => 'Checking your notes...',
        UploadStage.uploading when isLarge => 'Uploading large document...',
        UploadStage.uploading => 'Uploading...',
        UploadStage.compilingBrain => 'Mochi is reading your notes...',
        UploadStage.chunkedCompile => 'Building brain in sections...',
        _ => 'Processing...',
      },
      ...lines,
    ].join('\n');

    return MochiGenerating(
      stepLabels: stepLabels,
      stepDuration: stepDuration,
      stepLabel: combinedLabel,
    );
  }

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
                width: AppSizing.iconSm,
                height: AppSizing.iconSm,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isChunked ? AppColors.amber : AppColors.teal,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  isChunked
                      ? 'Building brain in sections...'
                      : 'Mochi is reading your notes...',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isChunked ? AppColors.amber : AppColors.teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (state.compileProgress != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              state.compileProgress!,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: isChunked ? AppColors.amber : AppColors.teal,
              ),
            ),
          ],
          Text(
            isChunked
                ? 'Your document is large — Mochi splits it into sections for better accuracy. Expected: $eta. You can close this screen; the brain updates automatically.'
                : 'New pages will appear in your library shortly. Expected: $eta.',
            style: AppTextStyles.bodySmall.copyWith(
              color: isChunked ? AppColors.amber : AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Terminal result screen (success / failed / timeout) ───────────────────────

class _TerminalScreen extends StatelessWidget {
  const _TerminalScreen({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AdaptiveCenter(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppSizing.iconContainer, color: iconColor),
                const SizedBox(height: AppSpacing.lg),
                Text(title,
                    style: AppTextStyles.heading1, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                Text(
                  message,
                  style: AppTextStyles.body.copyWith(color: AppColors.text2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onPrimary,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(primaryLabel),
                  ),
                ),
                if (secondaryLabel != null && onSecondary != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onSecondary,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(secondaryLabel!),
                    ),
                  ),
                ],
              ],
            ),
      ),
    );
  }
}
