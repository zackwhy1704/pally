import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/family/family_service.dart';

/// Bottom sheet for parents to assign revision modules to a child.
class AssignRevisionSheet extends ConsumerStatefulWidget {
  const AssignRevisionSheet({
    super.key,
    required this.childId,
    required this.weakAreas,
  });

  final String childId;
  final List<String> weakAreas;

  @override
  ConsumerState<AssignRevisionSheet> createState() =>
      _AssignRevisionSheetState();
}

class _AssignRevisionSheetState extends ConsumerState<AssignRevisionSheet> {
  final _titleCtrl = TextEditingController();
  final _selectedConcepts = <String>{};
  final DateTime _dueDate = DateTime.now().add(const Duration(days: 3));
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _assign() async {
    if (_selectedConcepts.isEmpty) {
      PallyToast.error(context, 'Select at least one concept');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(familyServiceProvider).assignRevision(
            widget.childId,
            _selectedConcepts.toList(),
            _dueDate.toIso8601String().substring(0, 10),
            _titleCtrl.text.trim().isEmpty
                ? 'Revision'
                : _titleCtrl.text.trim(),
          );
      if (mounted) {
        PallyToast.success(context, 'Revision assigned!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) PallyToast.error(context, 'Could not assign revision');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: AppSizing.handleBarWidth,
              height: AppSizing.handleBarHeight,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Assign Revision', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              hintText: 'Title (optional)',
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.text3),
              filled: true,
              fillColor: AppColors.surf2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 12),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Select concepts', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: widget.weakAreas.isEmpty
                ? Center(
                    child: Text('No weak areas found',
                        style: AppTextStyles.bodySmall))
                : ListView(
                    children: widget.weakAreas.map((area) {
                      final selected = _selectedConcepts.contains(area);
                      return CheckboxListTile(
                        value: selected,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _selectedConcepts.add(area);
                            } else {
                              _selectedConcepts.remove(area);
                            }
                          });
                        },
                        title: Text(area,
                            style: AppTextStyles.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        activeColor: AppColors.purple,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: AppSizing.buttonHeight,
            child: FilledButton(
              onPressed: _loading ? null : _assign,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: AppSizing.spinnerSm,
                      height: AppSizing.spinnerSm,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Assign'),
            ),
          ),
        ],
      ),
    );
  }
}
