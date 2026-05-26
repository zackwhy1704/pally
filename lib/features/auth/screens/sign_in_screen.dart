import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/auth/services/auth_service.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter your email and password');
      return;
    }
    setState(() => _loading = true);
    try {
      final result =
          await AuthService.instance.signInWithEmail(email, password);
      await AuthNotifier.instance.signIn(
        userId: result.userId,
        token: result.token,
        setupComplete: result.setupComplete,
        onboardingComplete: result.setupComplete,
      );
      if (mounted) {
        if (!result.setupComplete) {
          context.go('/auth/setup');
        } else {
          context.go('/');
        }
      }
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    try {
      final result = await AuthService.instance.signInWithGoogle();
      await AuthNotifier.instance.signIn(
        userId: result.userId,
        token: result.token,
        setupComplete: result.setupComplete,
        onboardingComplete: result.setupComplete,
      );
      if (mounted) {
        if (result.isNewUser || !result.setupComplete) {
          context.go('/auth/setup');
        } else {
          context.go('/');
        }
      }
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _appleSignIn() async {
    setState(() => _loading = true);
    try {
      final result = await AuthService.instance.signInWithApple();
      await AuthNotifier.instance.signIn(
        userId: result.userId,
        token: result.token,
        setupComplete: result.setupComplete,
        onboardingComplete: result.setupComplete,
      );
      if (mounted) {
        if (result.isNewUser || !result.setupComplete) {
          context.go('/auth/setup');
        } else {
          context.go('/');
        }
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeaderBand(),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome back! 👋',
                    style: AppTextStyles.title.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _FieldLabel('Email'),
                  const SizedBox(height: 6),
                  _TextField(
                    controller: _emailCtrl,
                    focusNode: _emailFocus,
                    hint: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _passFocus.requestFocus(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _FieldLabel('Password'),
                  const SizedBox(height: 6),
                  _TextField(
                    controller: _passCtrl,
                    focusNode: _passFocus,
                    hint: '••••••••',
                    obscure: _obscure,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _signIn(),
                    suffix: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.text3,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.purple,
                          padding: EdgeInsets.zero),
                      child: Text('Forgot password?',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.purple)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PrimaryButton(
                    label: 'Sign In',
                    loading: _loading,
                    onPressed: _signIn,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Divider(),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          label: 'Google',
                          icon: '🔵',
                          dark: false,
                          onPressed: _googleSignIn,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      if (Platform.isIOS)
                        Expanded(
                          child: _SocialButton(
                            label: 'Apple',
                            icon: '🍎',
                            dark: true,
                            onPressed: _appleSignIn,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?",
                          style: AppTextStyles.bodySmall),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => context.push('/auth/signup'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.purpleL,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Create Account ✨',
                            style: AppTextStyles.label.copyWith(
                                color: AppColors.purple,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      color: AppColors.purpleL,
      child: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.purple.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🐷', style: TextStyle(fontSize: 56)),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.text2,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.suffix,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        suffixIcon: suffix,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(label,
                style: AppTextStyles.body
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.outline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text('or continue with',
              style: AppTextStyles.caption.copyWith(color: AppColors.text3)),
        ),
        const Expanded(child: Divider(color: AppColors.outline)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.dark,
    required this.onPressed,
  });

  final String label;
  final String icon;
  final bool dark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: dark ? Colors.black : Colors.white,
          foregroundColor: dark ? Colors.white : AppColors.text1,
          side: BorderSide(
            color: dark ? Colors.black : Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
