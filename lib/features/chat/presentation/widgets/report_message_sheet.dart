import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_button.dart';
import 'package:pally/features/chat/presentation/chat_view_model.dart';
import 'package:pally/shared/models/chat_message.dart';

/// Child-safety report sheet: lets a student/parent flag an assistant chat
/// message as unsafe/wrong/other. Discoverable via long-press on the
/// assistant bubble — never on the student's own messages.
Future<void> showReportMessageSheet(
  BuildContext context, {
  required String avatarId,
  required String messageId,
  required String messageText,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
    ),
    builder: (_) => ReportMessageSheet(
      avatarId: avatarId,
      messageId: messageId,
      messageText: messageText,
    ),
  );
}

class ReportMessageSheet extends ConsumerStatefulWidget {
  const ReportMessageSheet({
    super.key,
    required this.avatarId,
    required this.messageId,
    required this.messageText,
  });

  final String avatarId;
  final String messageId;
  final String messageText;

  @override
  ConsumerState<ReportMessageSheet> createState() =>
      _ReportMessageSheetState();
}

class _ReportMessageSheetState extends ConsumerState<ReportMessageSheet> {
  ReportReason? _selectedReason;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _selectedReason;
    if (reason == null) return;
    await ref
        .read(chatViewModelProvider(widget.avatarId).notifier)
        .reportMessage(
          messageId: widget.messageId,
          messageText: widget.messageText,
          reason: reason,
          comment: _commentController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider(widget.avatarId));
    final isReported =
        chatState.reportedMessageIds.contains(widget.messageId);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: isReported
              ? const _ReportedConfirmation()
              : _ReportForm(
                  selectedReason: _selectedReason,
                  commentController: _commentController,
                  isSubmitting: chatState.isSubmittingReport,
                  error: chatState.reportError,
                  onSelectReason: (r) => setState(() => _selectedReason = r),
                  onSubmit: _submit,
                ),
        ),
      ),
    );
  }
}

class _ReportForm extends StatelessWidget {
  const _ReportForm({
    required this.selectedReason,
    required this.commentController,
    required this.isSubmitting,
    required this.error,
    required this.onSelectReason,
    required this.onSubmit,
  });

  final ReportReason? selectedReason;
  final TextEditingController commentController;
  final bool isSubmitting;
  final String? error;
  final ValueChanged<ReportReason> onSelectReason;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const Icon(Icons.flag_outlined, color: AppColors.coral, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text('Report this message', style: AppTextStyles.title),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "Help us keep Mochi safe and helpful. We'll look into it.",
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        _ReasonTile(
          emoji: '😟',
          label: 'Something Mochi said was not safe or upsetting',
          selected: selectedReason == ReportReason.unsafe,
          enabled: !isSubmitting,
          onTap: () => onSelectReason(ReportReason.unsafe),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ReasonTile(
          emoji: '🤔',
          label: 'Mochi got it wrong or was confusing',
          selected: selectedReason == ReportReason.wrongOrMisleading,
          enabled: !isSubmitting,
          onTap: () => onSelectReason(ReportReason.wrongOrMisleading),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ReasonTile(
          emoji: '💬',
          label: 'Something else',
          selected: selectedReason == ReportReason.other,
          enabled: !isSubmitting,
          onTap: () => onSelectReason(ReportReason.other),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Want to tell us more? (optional)',
          style: AppTextStyles.label,
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: commentController,
          enabled: !isSubmitting,
          maxLines: 3,
          maxLength: 500,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Type here…',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.text3),
            filled: true,
            fillColor: AppColors.surf2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.coralL,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Text(
              error!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text1),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        PallyButton(
          label: error != null ? 'Retry' : 'Send report',
          variant: PallyButtonVariant.filled,
          fullWidth: true,
          loading: isSubmitting,
          enabled: selectedReason != null,
          onPressed: onSubmit,
        ),
        const SizedBox(height: AppSpacing.sm),
        PallyButton(
          label: 'Cancel',
          variant: PallyButtonVariant.ghost,
          fullWidth: true,
          enabled: !isSubmitting,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.purpleL : AppColors.surf2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.purple : AppColors.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.purple : AppColors.text3,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportedConfirmation extends StatelessWidget {
  const _ReportedConfirmation();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.sm),
          const Icon(Icons.check_circle_rounded,
              color: AppColors.green, size: 40),
          const SizedBox(height: AppSpacing.md),
          Text(
            "Thanks — we'll take a look",
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your report helps keep Mochi safe.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          PallyButton(
            label: 'Done',
            variant: PallyButtonVariant.filled,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
