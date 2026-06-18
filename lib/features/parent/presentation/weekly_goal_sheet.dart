import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/family/family_service.dart';

/// Bottom sheet for parents to set weekly learning goals for a child.
class WeeklyGoalSheet extends ConsumerStatefulWidget {
  const WeeklyGoalSheet({super.key, required this.childId});
  final String childId;

  @override
  ConsumerState<WeeklyGoalSheet> createState() => _WeeklyGoalSheetState();
}

class _WeeklyGoalSheetState extends ConsumerState<WeeklyGoalSheet> {
  double _minutes = 60;
  double _modules = 5;
  bool _loading = false;

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await ref.read(familyServiceProvider).setGoal(
            widget.childId,
            _minutes.round(),
            _modules.round(),
          );
      if (mounted) {
        PallyToast.success(context, 'Weekly goal saved!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) PallyToast.error(context, 'Could not save goal');
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
          Text('Set Weekly Goal', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Minutes per week: ${_minutes.round()}',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          Slider(
            value: _minutes,
            min: 15,
            max: 120,
            divisions: 21,
            activeColor: AppColors.teal,
            label: '${_minutes.round()} min',
            onChanged: (v) => setState(() => _minutes = v),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Modules per week: ${_modules.round()}',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          Slider(
            value: _modules,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: AppColors.purple,
            label: '${_modules.round()}',
            onChanged: (v) => setState(() => _modules = v),
          ),
          const Spacer(),
          SizedBox(
            height: AppSizing.buttonHeight,
            child: FilledButton(
              onPressed: _loading ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
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
                  : const Text('Set goal'),
            ),
          ),
        ],
      ),
    );
  }
}
