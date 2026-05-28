import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/ui/painters/character_painter.dart';
import 'package:pally/core/ui/pally_relevance_warning_dialog.dart';
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

    // Show upload errors as toast
    ref.listen<UploadState>(uploadViewModelProvider(avatarId), (prev, next) {
      if (next.error != null && prev?.error != next.error && context.mounted) {
        PallyToast.error(context, next.error!);
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
          await vm.uploadFile(next.pendingFile!);
        } else {
          vm.clearPendingRelevance();
        }
      }
    });

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
            ),
            if (state.hasFiles) ...[
              const SizedBox(height: AppSpacing.md),
              _FileList(
                files: state.files,
                onDelete: vm.deleteFile,
              ),
            ],
          ],
        ),
      ),
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
                      ? 'Upload your ${avatar!.subject} notes and I\'ll study them! 📚'
                      : 'Upload your notes and I\'ll study them! 📚',
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
  });

  final bool isUploading;
  final bool isCheckingRelevance;
  final VoidCallback onCamera;
  final VoidCallback onPdf;

  bool get _busy => isUploading || isCheckingRelevance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add files', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.sm),
        if (_busy)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.purple),
            ),
          )
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

  void _showPasteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => const _PasteTextDialog(),
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

  @override
  void dispose() {
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
          onPressed: _controller.text.trim().isNotEmpty
              ? () => Navigator.of(context).pop(_controller.text)
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
