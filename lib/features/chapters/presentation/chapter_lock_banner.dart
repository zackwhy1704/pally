import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/chapters/domain/chapter.dart';
import 'package:pally/features/chapters/presentation/chapter_picker_sheet.dart';
import 'package:pally/features/chapters/presentation/chapter_picker_view_model.dart';

/// The return-loop surface on the brain screen: uploaded-but-uncompiled chapters,
/// tappable → the chapter picker. Renders nothing when there are none.
class ChapterLockBanner extends ConsumerWidget {
  const ChapterLockBanner({super.key, required this.avatarId});

  final String avatarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(chapterPickerViewModelProvider(avatarId));

    // ── Beta-period skew armor (REMOVABLE once the fleet + server verifiably ship
    // the /chapters endpoint together) ─────────────────────────────────────────
    // On an OLD backend that predates /chapters, the query lands in error (404).
    // Render NOTHING — never an error dialog, never a dead-end. A visible
    // "updating" note is deliberately AVOIDED: /chapters 404s UNCONDITIONALLY on an
    // old backend, so a note would show for every user (even those with no large
    // upload) — noisier than a clean hide. The picker sheet has its own honest
    // error state for the matched-backend case.
    if (async.hasError) return const SizedBox.shrink();

    final locked = async.maybeWhen(
      data: (r) => r.locked,
      orElse: () => const <Chapter>[],
    );
    if (locked.isEmpty) return const SizedBox.shrink();

    final n = locked.length;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.purpleL,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$n chapter${n == 1 ? '' : 's'} not compiled yet',
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  "Mochi hasn't read ${n == 1 ? 'this chapter' : 'these chapters'} yet "
                  '— pick which to compile.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ElevatedButton(
            onPressed: () => showChapterPicker(context, avatarId: avatarId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: AppColors.surface,
            ),
            child: const Text('Choose'),
          ),
        ],
      ),
    );
  }
}
