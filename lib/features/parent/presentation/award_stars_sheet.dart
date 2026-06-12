import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/family/family_service.dart';

/// Bottom sheet for parents to award bonus stars to a child.
class AwardStarsSheet extends ConsumerStatefulWidget {
  const AwardStarsSheet({super.key, required this.childId});
  final String childId;

  @override
  ConsumerState<AwardStarsSheet> createState() => _AwardStarsSheetState();
}

class _AwardStarsSheetState extends ConsumerState<AwardStarsSheet> {
  int _amount = 10;
  final _noteCtrl = TextEditingController();
  bool _loading = false;

  static const _quickAmounts = [10, 25, 50];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _award() async {
    setState(() => _loading = true);
    try {
      final note = _noteCtrl.text.trim();
      await ref.read(familyServiceProvider).awardStars(
            widget.childId,
            _amount,
            note.isEmpty ? null : note,
          );
      if (mounted) {
        PallyToast.success(context, '$_amount stars awarded!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) PallyToast.error(context, 'Could not award stars');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
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
          Text('Award Stars', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: _quickAmounts.map((amt) {
              final selected = _amount == amt;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: amt == _quickAmounts.last ? 0 : AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => setState(() => _amount = amt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.amberL : AppColors.surf2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppColors.amber : AppColors.outline,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '+$amt',
                          style: AppTextStyles.title.copyWith(
                            color: selected ? AppColors.amber : AppColors.text2,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _noteCtrl,
            decoration: InputDecoration(
              hintText: 'Note (optional, e.g. "Great homework!")',
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
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: AppSizing.buttonHeight,
            child: FilledButton(
              onPressed: _loading ? null : _award,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: Colors.white,
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
                  : Text('Award $_amount stars'),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
