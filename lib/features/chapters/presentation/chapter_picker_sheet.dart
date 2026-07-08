import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/chapters/domain/chapter.dart';
import 'package:pally/features/chapters/presentation/chapter_picker_view_model.dart';

/// Opens the chapter picker — the ONE place chunk-picking lives (shown after a large
/// upload AND from the locked-chapter surface). Interaction design mirrors the memoly
/// web picker screenshot-for-screenshot: chapter list, page counts, none pre-selected,
/// a live "N of M compiles left this month" counter, compile-selected + compile-all.
Future<void> showChapterPicker(
  BuildContext context, {
  required String avatarId,
  VoidCallback? onCompiled,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ChapterPickerSheet(avatarId: avatarId, onCompiled: onCompiled),
  );
}

class ChapterPickerSheet extends ConsumerStatefulWidget {
  const ChapterPickerSheet({super.key, required this.avatarId, this.onCompiled});

  final String avatarId;
  final VoidCallback? onCompiled;

  @override
  ConsumerState<ChapterPickerSheet> createState() => _ChapterPickerSheetState();
}

class _ChapterPickerSheetState extends ConsumerState<ChapterPickerSheet> {
  final Set<String> _selected = {};
  String? _error;

  void _toggle(String id) {
    setState(() {
      if (!_selected.remove(id)) _selected.add(id);
    });
  }

  Future<void> _compile(List<String> ids) async {
    setState(() => _error = null);
    try {
      await ref
          .read(chapterPickerViewModelProvider(widget.avatarId).notifier)
          .compileSelected(ids);
      if (!mounted) return;
      setState(_selected.clear);
      widget.onCompiled?.call();
    } catch (_) {
      if (mounted) {
        setState(() => _error = "Couldn't compile — please try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(chapterPickerViewModelProvider(widget.avatarId));
    final vm = ref.read(chapterPickerViewModelProvider(widget.avatarId).notifier);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        // ONE scroll view wraps every state (loading / error / data) so a large
        // text scale, a narrow device, or the keyboard can never overflow the sheet.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: async.when(
            loading: () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
            error: (_, __) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(
                    child: Text("Couldn't load chapters. Please close and try again.",
                        style: AppTextStyles.body.copyWith(color: AppColors.coral)),
                  ),
                ),
              ],
            ),
            data: (result) => _loaded(context, result, vm),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose chapters to compile', style: AppTextStyles.title),
                const SizedBox(height: 2),
                Text(
                  'Mochi only reads the chapters you pick — start with what you’re studying now.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.text3),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close, color: AppColors.text3),
            splashRadius: 20,
          ),
        ],
      );

  Widget _loaded(BuildContext context, ChaptersResult result, ChapterPickerViewModel vm) {
    final chapters = result.chapters;
    final locked = result.locked;
    final remaining = result.remaining;
    final selectedCount = _selected.length;
    final overLimit = !result.unlimited && selectedCount > remaining;
    final canCompile = selectedCount > 0 && !overLimit && !vm.isCompiling;
    final showCompileAll = locked.length >= 2 &&
        (result.unlimited || remaining >= locked.length) &&
        !vm.isCompiling;

    // Plain Column — the parent SingleChildScrollView provides the scroll, so a tall
    // list / large text scale scrolls instead of overflowing.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        const SizedBox(height: AppSpacing.sm),
        _counter(result),
        const SizedBox(height: AppSpacing.sm),
        if (chapters.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text('No chapters to compile.',
                  style: AppTextStyles.body.copyWith(color: AppColors.text3)),
            ),
          )
        else
          for (final c in chapters)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: _row(c),
            ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.coral)),
        ],
        const SizedBox(height: AppSpacing.md),
        _footer(context, result, locked, showCompileAll, canCompile, overLimit, remaining, vm),
      ],
    );
  }

  Widget _counter(ChaptersResult result) {
    final unlimited = result.unlimited;
    final remaining = result.remaining;
    final none = !unlimited && remaining == 0;
    final bg = none ? AppColors.coralL : (unlimited ? AppColors.purpleL : AppColors.surf2);
    final fg = none ? AppColors.coral : (unlimited ? AppColors.purple : AppColors.text2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        unlimited
            ? 'Unlimited chapter compiles'
            : '$remaining of ${result.allowanceLimit} compiles left this month',
        style: AppTextStyles.label.copyWith(color: fg),
      ),
    );
  }

  Widget _row(Chapter c) {
    final isLocked = c.isLocked;
    final checked = _selected.contains(c.chunkId);
    return Opacity(
      opacity: isLocked ? 1 : 0.7,
      child: InkWell(
        onTap: isLocked ? () => _toggle(c.chunkId) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surf2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              if (isLocked)
                Checkbox(
                  value: checked,
                  onChanged: (_) => _toggle(c.chunkId),
                  activeColor: AppColors.purple,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )
              else
                const SizedBox(width: 24),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    Text('Pages ${c.pageFrom}–${c.pageTo} · ${c.pageCount} '
                        '${c.pageCount == 1 ? "page" : "pages"}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.text3)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _StateBadge(state: c.state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footer(
    BuildContext context,
    ChaptersResult result,
    List<Chapter> locked,
    bool showCompileAll,
    bool canCompile,
    bool overLimit,
    int remaining,
    ChapterPickerViewModel vm,
  ) {
    final selectedCount = _selected.length;
    // Hint on its own line, buttons in a Wrap — so a narrow screen or a large text
    // scale wraps the CTAs instead of overflowing the Row (the recurring bug class).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          overLimit
              ? 'Only $remaining left this month — deselect ${selectedCount - remaining}.'
              : selectedCount > 0
                  ? '$selectedCount selected'
                  : 'Select one or more chapters',
          style: AppTextStyles.caption.copyWith(color: AppColors.text3),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            if (showCompileAll)
              OutlinedButton(
                onPressed: () => _compile(locked.map((c) => c.chunkId).toList()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.purple,
                  side: const BorderSide(color: AppColors.purpleC),
                ),
                child: Text('Compile all (${locked.length})'),
              ),
            ElevatedButton(
              onPressed: canCompile ? () => _compile(_selected.toList()) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: AppColors.surface,
                disabledBackgroundColor: AppColors.outline,
              ),
              child: vm.isCompiling
                  ? const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(selectedCount > 0 ? 'Compile ($selectedCount)' : 'Compile'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.state});
  final ChapterState state;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      ChapterState.compiled => ('✓ Compiled', AppColors.green),
      ChapterState.compiling => ('Compiling…', AppColors.purple),
      ChapterState.locked => ('Not compiled', AppColors.text3),
    };
    return Text(label,
        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600));
  }
}
