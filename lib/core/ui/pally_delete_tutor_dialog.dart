import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_button.dart';
import 'package:pally/core/ui/pally_dialog.dart';
import 'package:pally/shared/models/avatar.dart';

class PallyDeleteTutorDialog extends StatelessWidget {
  const PallyDeleteTutorDialog({
    super.key,
    required this.avatar,
    required this.onCancel,
    required this.onDelete,
  });

  final Avatar avatar;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  static Future<bool?> show({
    required BuildContext context,
    required Avatar avatar,
  }) {
    HapticFeedback.mediumImpact();
    return showDialog<bool>(
      context: context,
      barrierColor: const Color(0x7A1F1733),
      builder: (_) => PallyDeleteTutorDialog(
        avatar: avatar,
        onCancel: () => Navigator.of(context).pop(false),
        onDelete: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PallyDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.coralL,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                avatar.character.assetPath,
                width: 56,
                height: 56,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Delete ${avatar.name}?',
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This permanently deletes this tutor and all their knowledge, '
            'chat history, and quiz progress. This cannot be undone.',
            style: AppTextStyles.body.copyWith(color: AppColors.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.coralL.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _StatRow(
                    icon: '📚',
                    label: 'Knowledge pages',
                    value: '${avatar.wikiPageCount}'),
                const SizedBox(height: 4),
                const _StatRow(
                    icon: '💬',
                    label: 'Chat messages',
                    value: 'All will be deleted'),
                const SizedBox(height: 4),
                const _StatRow(
                    icon: '⭐',
                    label: 'Quiz progress',
                    value: 'All will be lost'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PallyDialog.buttonRow(
            secondary: PallyButton(
              label: 'Keep Tutor',
              onPressed: onCancel,
              variant: PallyButtonVariant.outlined,
              fullWidth: true,
            ),
            primary: PallyButton(
              label: 'Delete',
              onPressed: onDelete,
              variant: PallyButtonVariant.destructive,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: AppTextStyles.caption.copyWith(color: AppColors.text2)),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(
                color: AppColors.coral, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
