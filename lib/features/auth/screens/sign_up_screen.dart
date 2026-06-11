import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/services/fcm_token_service.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/auth/services/auth_service.dart';
import 'package:pally/features/referral/referral_service.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreed = false;
  bool _loading = false;

  /// Which step of the signup flow: 0 = details, 1 = role selection.
  int _step = 0;

  /// "student" (default) or "parent".
  String _selectedRole = 'student';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _referralCtrl.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _agreed && (_formKey.currentState?.validate() ?? false);

  void _goToRoleStep() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreed) {
      _showError('Please agree to the Terms of Service');
      return;
    }
    setState(() => _step = 1);
  }

  Future<void> _signUp() async {
    setState(() => _loading = true);
    try {
      final result = await AuthService.instance.signUpWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text,
        _nameCtrl.text.trim(),
        role: _selectedRole,
      );
      final accountType =
          _selectedRole == 'parent' ? 'PARENT' : 'STUDENT';
      await AuthNotifier.instance.signIn(
        userId: result.userId,
        token: result.token,
        setupComplete: _selectedRole == 'parent',
        onboardingComplete: _selectedRole == 'parent',
        accountType: result.accountType ?? accountType,
      );
      // Fire-and-forget FCM token registration.
      FcmTokenService(ref.read(dioProvider)).registerToken();
      // Optional referral redeem — best-effort, never blocks signup.
      final referral = _referralCtrl.text.trim();
      if (referral.isNotEmpty) {
        try {
          await ref.read(referralServiceProvider).redeem(referral);
        } catch (_) {
          // ignore — backend rejects self-referral / double-redeem
        }
      }
      if (!mounted) return;
      if (_selectedRole == 'parent') {
        context.go('/parent-onboarding');
      } else {
        context.go('/auth/setup');
      }
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.coral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: _step == 0 ? _buildDetailsStep() : _buildRoleStep(),
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          const _ProgressBar(filled: 1 / 3),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
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
                child: Text(
                  'Create your account',
                  style: AppTextStyles.title.copyWith(fontSize: 20),
                ),
              ),
            ],
          ),
          Text(
            'Step 1 of 3 — Your details',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: AppSpacing.lg),
          Form(
            key: _formKey,
            onChanged: () => setState(() {}),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FormField(
                  label: 'Name',
                  hint: 'Your name',
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _FormField(
                  label: 'Email',
                  hint: 'your@email.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || !v.contains('@') || !v.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _FormField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passCtrl,
                  obscure: _obscurePass,
                  textInputAction: TextInputAction.next,
                  suffix: _EyeToggle(
                    obscure: _obscurePass,
                    onToggle: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!v.contains(RegExp(r'[0-9]'))) {
                      return 'Password must contain at least one number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _FormField(
                  label: 'Confirm Password',
                  hint: '••••••••',
                  controller: _confirmCtrl,
                  obscure: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  suffix: _EyeToggle(
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v != _passCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _FormField(
                  label: 'Referral code (optional)',
                  hint: 'ABCDEF',
                  controller: _referralCtrl,
                  obscure: false,
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    if (v.length != 6) return 'Codes are 6 characters';
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Checkbox(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                activeColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              Expanded(
                child: Wrap(
                  children: [
                    Text('I agree to the ', style: AppTextStyles.bodySmall),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Terms of Service',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.purple),
                      ),
                    ),
                    Text(' and ', style: AppTextStyles.bodySmall),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Privacy Policy',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.purple),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: AppSizing.buttonHeight,
            child: ElevatedButton(
              onPressed: _canContinue ? _goToRoleStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.purple.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Continue',
                  style: AppTextStyles.body.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(foregroundColor: AppColors.text2),
              child: Text('Already have an account? Sign in',
                  style: AppTextStyles.bodySmall),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildRoleStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          const _ProgressBar(filled: 2 / 3),
          const SizedBox(height: AppSpacing.sm),
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
                child: Text(
                  'Who is this account for?',
                  style: AppTextStyles.title.copyWith(fontSize: 20),
                ),
              ),
            ],
          ),
          Text(
            'Step 2 of 3 — Choose your role',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: AppSpacing.xl),
          _RoleCard(
            icon: Icons.school_rounded,
            title: "I'm a student",
            subtitle: 'Create Mochi tutors, study, and earn rewards.',
            isSelected: _selectedRole == 'student',
            onTap: () => setState(() => _selectedRole = 'student'),
          ),
          const SizedBox(height: AppSpacing.md),
          _RoleCard(
            icon: Icons.family_restroom_rounded,
            title: "I'm a parent / guardian",
            subtitle: 'Track your child\'s progress and manage their learning.',
            isSelected: _selectedRole == 'parent',
            onTap: () => setState(() => _selectedRole = 'parent'),
          ),
          const Spacer(),
          SizedBox(
            height: AppSizing.buttonHeight,
            child: ElevatedButton(
              onPressed: _loading ? null : _signUp,
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
                      width: AppSizing.checkboxSize,
                      height: AppSizing.checkboxSize,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Create account',
                      style: AppTextStyles.body.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
          SizedBox(
              height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.filled});
  final double filled;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: filled,
        minHeight: 6,
        backgroundColor: AppColors.outline,
        valueColor:
            const AlwaysStoppedAnimation<Color>(AppColors.purple),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.suffix,
    this.textCapitalization,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final Widget? suffix;
  final TextCapitalization? textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label
              .copyWith(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization:
              textCapitalization ?? TextCapitalization.none,
          validator: validator,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.text3),
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
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.coral, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: suffix,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}

class _EyeToggle extends StatelessWidget {
  const _EyeToggle({required this.obscure, required this.onToggle});
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppColors.text3,
        size: 20,
      ),
      onPressed: onToggle,
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purpleL : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.purple : AppColors.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppSizing.avatarLg,
              height: AppSizing.avatarLg,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.purple.withValues(alpha: 0.15)
                    : AppColors.surf2,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: isSelected ? AppColors.purple : AppColors.text2,
                  size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.purple
                              : AppColors.text1)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.text2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.purple, size: 24),
          ],
        ),
      ),
    );
  }
}

