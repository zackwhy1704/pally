import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/groups/presentation/groups_view_model.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/core/ui/pally_toast.dart';

/// Report / block controls for user-generated content in Study Groups.
///
/// App Store Guideline 1.2 requires BOTH a way to report objectionable content
/// and a way to block the user who posted it. They are deliberately offered as
/// TWO SEPARATE actions here, not one combined "report and block" button:
/// Apple's requirement is that each mechanism exists, and bundling them would
/// force a student who only wants something reviewed to also stop seeing a
/// classmate they may still need to study with. Blocking is offered next to
/// reporting as a convenience, and is also reachable on its own.
///
/// Blocking is enforced SERVER-SIDE — the group-detail response omits a blocked
/// user's notes and member entry entirely. This sheet only asks; it never
/// filters locally, because a local filter would still have shipped the content
/// to the device.
Future<void> showModerationSheet(
  BuildContext context,
  WidgetRef ref, {
  required String groupId,
  /// Null when reporting the GROUP ITSELF (its name) rather than a person.
  /// group_reports allows both targets to be null, which is exactly a
  /// group-level report — and there is no user to block in that case.
  String? targetUserId,
  required String targetName,
  String? targetNoteId,
}) async {
  final l = AppLocalizations.of(context);
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(l.moderationSheetTitle,
                  style: AppTextStyles.title, textAlign: TextAlign.center),
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: AppColors.coral),
              title: Text(l.moderationReport, style: AppTextStyles.body),
              subtitle: Text(l.moderationReportHint, style: AppTextStyles.bodySmall),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await ref.read(groupDetailViewModelProvider(groupId).notifier).report(
                      targetUserId: targetNoteId == null ? targetUserId : null,
                      targetNoteId: targetNoteId,
                    );
                if (context.mounted) {
                  PallyToast.success(context, l.moderationReportSent);
                }
              },
            ),
            if (targetUserId != null)
              ListTile(
              leading: const Icon(Icons.block, color: AppColors.text2),
              title: Text(l.moderationBlock(targetName), style: AppTextStyles.body),
              subtitle: Text(l.moderationBlockHint, style: AppTextStyles.bodySmall),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await ref
                    .read(groupDetailViewModelProvider(groupId).notifier)
                    .block(targetUserId!);
                if (context.mounted) {
                  PallyToast.success(context, l.moderationBlocked(targetName));
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}
