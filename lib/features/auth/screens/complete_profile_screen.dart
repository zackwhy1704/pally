import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/adaptive_content_width.dart';
import 'package:pally/features/auth/screens/complete_profile_view_model.dart';

// Requires TLD ≥ 2 chars; rejects single-char TLDs like .c
final _kEmailRegex =
    RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');

/// Collects a missing birth year (backend 403 `PROFILE_COMPLETION_REQUIRED`).
/// Reuses the direct-onboarding age-group + parent-email pattern, then hands the
/// derived birth year to the view model which stores the refreshed token.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _parentEmailCtrl = TextEditingController();

  @override
  void dispose() {
    _parentEmailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final vm = ref.read(completeProfileViewModelProvider);
    final notifier = ref.read(completeProfileViewModelProvider.notifier);
    // Parent-email field is only validated (and rendered) for under-13.
    if (vm.isUnder13 == true &&
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    notifier.submit(parentEmail: _parentEmailCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(completeProfileViewModelProvider);
    final notifier = ref.read(completeProfileViewModelProvider.notifier);

    ref.listen<CompleteProfileState>(completeProfileViewModelProvider,
        (prev, next) {
      if (next.done && !(prev?.done ?? false)) {
        context.go('/');
      }
    });

    final isUnder13 = vm.isUnder13;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: AdaptiveContentWidth(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Image.asset(
                      'assets/images/mochi.png',
                      width: AppSizing.heroMochiSize,
                      height: AppSizing.heroMochiSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'One quick thing',
                    style: AppTextStyles.heading1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Tell us your age group so we can set up your account safely.',
                    style: AppTextStyles.body.copyWith(color: AppColors.text2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Age group',
                    style: AppTextStyles.label
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _AgeGroupTile(
                    label: 'I am 13 or older',
                    selected: isUnder13 == false,
                    onTap: () => notifier.setAgeGroup(isUnder13: false),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _AgeGroupTile(
                    label: 'I am under 13',
                    selected: isUnder13 == true,
                    onTap: () => notifier.setAgeGroup(isUnder13: true),
                  ),
                  if (isUnder13 == true) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "Parent's email address",
                      style: AppTextStyles.label
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _parentEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      style: AppTextStyles.body,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: 'parent@example.com',
                        hintStyle: AppTextStyles.body
                            .copyWith(color: AppColors.text3),
                        filled: true,
                        fillColor: const Color(0xFFEDE8F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.coral),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Please enter your parent's email";
                        }
                        if (!_kEmailRegex.hasMatch(v.trim())) {
                          return "Please enter your parent's valid email (e.g. parent@example.com)";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      "We'll email your parent to approve your account before you can use AI features.",
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.text2),
                    ),
                  ],
                  // Persistent inline error (never toast-only for a primary
                  // action) — the submit button below doubles as Retry.
                  if (vm.error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: AppSpacing.card,
                      decoration: BoxDecoration(
                        color: AppColors.coralL,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.coral, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              vm.error!,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.coral),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    height: AppSizing.buttonHeight,
                    child: FilledButton(
                      onPressed: vm.isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: vm.isLoading
                          ? const SizedBox(
                              width: AppSizing.spinnerSm,
                              height: AppSizing.spinnerSm,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              vm.error != null ? 'Try again' : 'Continue',
                              style: AppTextStyles.body.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AgeGroupTile extends StatelessWidget {
  const _AgeGroupTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.purpleL : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.purple : AppColors.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.purple : AppColors.text3,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: selected ? AppColors.purple : AppColors.text1,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
