import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/family/family_service.dart';
import 'package:pally/features/family/family_status_provider.dart';

/// Parent onboarding flow shown after a parent account is created.
/// Step 1: Welcome + display name confirmation.
/// Step 2: Link a child via claim code (skippable).
class ParentOnboardingScreen extends ConsumerStatefulWidget {
  const ParentOnboardingScreen({super.key});

  @override
  ConsumerState<ParentOnboardingScreen> createState() =>
      _ParentOnboardingScreenState();
}

class _ParentOnboardingScreenState
    extends ConsumerState<ParentOnboardingScreen> {
  int _step = 0;
  bool _loading = false;

  final _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final _codeFocusNodes = List.generate(6, (_) => FocusNode());

  String get _code =>
      _codeControllers.map((c) => c.text).join().toUpperCase();

  @override
  void dispose() {
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _codeFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _linkChild() async {
    if (_code.length != 6) {
      PallyToast.error(context, 'Enter all 6 characters');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(familyServiceProvider).claim(_code);
      ref.invalidate(familyStatusProvider);
      if (mounted) {
        PallyToast.success(context, 'Child linked!');
        context.go('/parent-home');
      }
    } on FamilyError catch (e) {
      if (mounted) PallyToast.error(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final childName = ref.watch(authStateProvider).childName;
    final displayName = childName ??
        ref.watch(authStateProvider).userId?.substring(0, 6) ??
        'there';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _step == 0
              ? _buildWelcomeStep(displayName)
              : _buildLinkStep(),
        ),
      ),
    );
  }

  Widget _buildWelcomeStep(String displayName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Container(
          width: AppSizing.iconContainer,
          height: AppSizing.iconContainer,
          decoration: const BoxDecoration(
            color: AppColors.purpleL,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.family_restroom_rounded,
              color: AppColors.purple, size: 32),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Welcome, parent!',
          style: AppTextStyles.heading1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your parent account is ready. Next, link your child so '
          'you can track their learning progress.',
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        SizedBox(
          height: AppSizing.buttonHeight,
          child: ElevatedButton(
            onPressed: () => setState(() => _step = 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text('Link your child',
                style: AppTextStyles.body.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: TextButton(
            onPressed: () => context.go('/parent-home'),
            style: TextButton.styleFrom(foregroundColor: AppColors.text2),
            child: Text('Link later', style: AppTextStyles.bodySmall),
          ),
        ),
        SizedBox(
            height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
      ],
    );
  }

  Widget _buildLinkStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _step = 0),
              child: Container(
                width: AppSizing.avatarMd,
                height: AppSizing.avatarMd,
                decoration: const BoxDecoration(
                  color: AppColors.purpleL,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: AppColors.purple),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Link your child',
                  style: AppTextStyles.title.copyWith(fontSize: 20)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Ask your child to open Apalchi, go to Me tab, '
          'tap "Link a grown-up", and read you their 6-character code.',
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            return Padding(
              padding: EdgeInsets.only(right: i == 5 ? 0 : 8),
              child: _OnboardingCodeBox(
                controller: _codeControllers[i],
                focusNode: _codeFocusNodes[i],
                onFilled: () {
                  if (i < 5) {
                    _codeFocusNodes[i + 1].requestFocus();
                  } else {
                    _codeFocusNodes[i].unfocus();
                  }
                },
                onCleared: () {
                  if (i > 0) _codeFocusNodes[i - 1].requestFocus();
                },
              ),
            );
          }),
        ),
        const Spacer(),
        SizedBox(
          height: AppSizing.buttonHeight,
          child: ElevatedButton(
            onPressed: _loading ? null : _linkChild,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  AppColors.purple.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    width: AppSizing.spinnerSm,
                    height: AppSizing.spinnerSm,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text('Link account',
                    style: AppTextStyles.body.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: TextButton(
            onPressed: () => context.go('/parent-home'),
            style: TextButton.styleFrom(foregroundColor: AppColors.text2),
            child: Text('Skip for now', style: AppTextStyles.bodySmall),
          ),
        ),
        SizedBox(
            height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
      ],
    );
  }
}

class _OnboardingCodeBox extends StatelessWidget {
  const _OnboardingCodeBox({
    required this.controller,
    required this.focusNode,
    required this.onFilled,
    required this.onCleared,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onFilled;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizing.buttonHeightSm,
      height: AppSizing.buttonHeight,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.characters,
        keyboardType: TextInputType.visiblePassword,
        maxLength: 1,
        style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.purple, width: 2),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty) {
            controller.text = v.toUpperCase();
            controller.selection =
                const TextSelection.collapsed(offset: 1);
            onFilled();
          } else {
            onCleared();
          }
        },
      ),
    );
  }
}
