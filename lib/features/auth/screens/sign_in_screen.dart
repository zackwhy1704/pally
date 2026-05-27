import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/utils/device_info.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/auth/services/auth_service.dart';

enum _BiometricState { scanning, success, failed }

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
  bool _biometricAvailable = false;
  final _localAuth = LocalAuthentication();
  final _bioStateCtrl = StreamController<_BiometricState>.broadcast();

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final registered = await AuthNotifier.instance.isBiometricRegistered();
    final lastUser = await AuthNotifier.instance.getLastUserId();
    final canAuth = await _canUseBiometrics();
    if (mounted) {
      setState(() => _biometricAvailable = registered && lastUser != null && canAuth);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _bioStateCtrl.close();
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
        context.go(result.setupComplete ? '/' : '/auth/setup');
      }
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _biometricSignIn() async {
    final canAuth = await _canUseBiometrics();
    if (!canAuth) {
      _showError('Biometrics not set up on this device');
      return;
    }
    final isRegistered = await AuthNotifier.instance.isBiometricRegistered();
    if (!isRegistered) return;

    final userId = await AuthNotifier.instance.getLastUserId();
    if (userId == null) {
      _showError('Please sign in with your password first');
      return;
    }

    _showBiometricSheet();

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Sign in to Pally',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (!authenticated) {
        _bioStateCtrl.add(_BiometricState.failed);
        return;
      }

      final deviceId = await DeviceInfo.getStableDeviceId();
      final result = await AuthService.instance.verifyBiometric(
        userId: userId,
        deviceId: deviceId,
      );
      await AuthNotifier.instance.signIn(
        userId: result.userId,
        token: result.token,
        setupComplete: result.setupComplete,
        onboardingComplete: result.setupComplete,
      );
      _bioStateCtrl.add(_BiometricState.success);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        Navigator.of(context).pop();
        context.go(result.setupComplete ? '/' : '/auth/setup');
      }
    } on AuthException catch (e) {
      _bioStateCtrl.add(_BiometricState.failed);
      if (mounted) _showError(e.message);
    } catch (_) {
      _bioStateCtrl.add(_BiometricState.failed);
    }
  }

  Future<bool> _canUseBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics &&
          await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  void _showBiometricSheet() {
    _bioStateCtrl.add(_BiometricState.scanning);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF0F0A1A).withValues(alpha: 0.55),
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _BiometricSheet(
        stateStream: _bioStateCtrl.stream,
        onCancel: () {
          _localAuth.stopAuthentication();
          Navigator.of(context).pop();
        },
        onRetry: () {
          Navigator.of(context).pop();
          _biometricSignIn();
        },
        onUsePassword: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    showDialog<void>(
      context: context,
      builder: (ctx) {
        var sending = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: const Text('Reset Password'),
            content: TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'your@email.com',
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.text3),
                filled: true,
                fillColor: const Color(0xFFEDE8F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 14),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: sending
                    ? null
                    : () async {
                        final email = emailCtrl.text.trim();
                        if (email.isEmpty) return;
                        setDialogState(() => sending = true);
                        try {
                          await AuthService.instance.forgotPassword(email);
                          if (ctx.mounted) Navigator.of(ctx).pop();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Check your email for a reset link'),
                                backgroundColor: AppColors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        } on AuthException catch (e) {
                          if (ctx.mounted) Navigator.of(ctx).pop();
                          if (mounted) _showError(e.message);
                        } finally {
                          if (ctx.mounted) {
                            setDialogState(() => sending = false);
                          }
                        }
                      },
                child: sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Send Reset Link'),
              ),
            ],
          ),
        );
      },
    );
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
                      onPressed: _showForgotPasswordDialog,
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
                  if (_biometricAvailable) ...[
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(color: AppColors.outline)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.text3)),
                        ),
                        const Expanded(
                            child: Divider(color: AppColors.outline)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: _biometricSignIn,
                        child: Container(
                          width: 176,
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF7FF),
                            borderRadius: BorderRadius.circular(27),
                            border: Border.all(
                                color: AppColors.teal, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.teal.withValues(alpha: 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _BiometricIcon(),
                              const SizedBox(width: 10),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Use Biometrics',
                                      style: AppTextStyles.label.copyWith(
                                          color: AppColors.teal,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12)),
                                  Text('Face ID / Touch ID',
                                      style: AppTextStyles.caption.copyWith(
                                          color: AppColors.text2,
                                          fontSize: 9)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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

class _BiometricIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal.withValues(alpha: 0.12),
              border: Border.all(
                  color: AppColors.teal.withValues(alpha: 0.9), width: 1.5),
            ),
          ),
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.teal.withValues(alpha: 0.7), width: 1.5),
            ),
          ),
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal.withValues(alpha: 0.25),
              border: Border.all(
                  color: AppColors.teal.withValues(alpha: 0.9), width: 1.5),
            ),
          ),
          Container(
            width: 4, height: 4,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.teal),
          ),
        ],
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
            child: Text('✨', style: TextStyle(fontSize: 56)),
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
    return Text(text,
        style: AppTextStyles.label.copyWith(
            fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text2));
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
            horizontal: AppSpacing.md, vertical: 14),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label,
                style: AppTextStyles.body
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _BiometricSheet extends StatelessWidget {
  const _BiometricSheet({
    required this.stateStream,
    required this.onCancel,
    required this.onRetry,
    required this.onUsePassword,
  });

  final Stream<_BiometricState> stateStream;
  final VoidCallback onCancel;
  final VoidCallback onRetry;
  final VoidCallback onUsePassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 434,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: StreamBuilder<_BiometricState>(
        stream: stateStream,
        initialData: _BiometricState.scanning,
        builder: (context, snapshot) {
          final state = snapshot.data ?? _BiometricState.scanning;
          return _buildContent(context, state);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, _BiometricState state) {
    final Color ringColor = switch (state) {
      _BiometricState.scanning => AppColors.teal,
      _BiometricState.success => AppColors.green,
      _BiometricState.failed => AppColors.coral,
    };

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 54, height: 5,
          decoration: BoxDecoration(
              color: AppColors.outline, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 152, height: 152,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _Ring(size: 152, color: ringColor, opacity: 0.1),
              _Ring(size: 120, color: ringColor, opacity: 0.2),
              _Ring(size: 88, color: ringColor, opacity: 0.35),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ringColor.withValues(alpha: 0.2),
                  border: Border.all(
                      color: ringColor.withValues(alpha: 0.8), width: 2),
                ),
              ),
              if (state == _BiometricState.scanning)
                Icon(Icons.fingerprint_rounded, color: ringColor, size: 28)
              else if (state == _BiometricState.success)
                Icon(Icons.check_rounded, color: ringColor, size: 28)
              else
                Icon(Icons.close_rounded, color: ringColor, size: 28),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          switch (state) {
            _BiometricState.scanning => 'Scanning...',
            _BiometricState.success => 'Verified! ✨',
            _BiometricState.failed => "Couldn't verify",
          },
          style: AppTextStyles.title.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Text(
          switch (state) {
            _BiometricState.scanning =>
              'Place your finger or look at your camera',
            _BiometricState.success => 'Signing you in...',
            _BiometricState.failed => 'Face or fingerprint not recognised',
          },
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
          textAlign: TextAlign.center,
        ),
        if (state == _BiometricState.success) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: const LinearProgressIndicator(
                value: null,
                backgroundColor: AppColors.outline,
                valueColor: AlwaysStoppedAnimation(AppColors.green),
                minHeight: 4,
              ),
            ),
          ),
        ],
        if (state == _BiometricState.failed) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Try Again',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity, height: 44,
                  child: OutlinedButton(
                    onPressed: onUsePassword,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.outline),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Use password instead',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.text2)),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (state == _BiometricState.scanning) ...[
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 112),
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(166, 44),
                side: const BorderSide(color: AppColors.outline),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22)),
              ),
              child: Text('Cancel',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.text2)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.color, required this.opacity});
  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: color.withValues(alpha: opacity), width: 1.5),
        ),
      );
}
