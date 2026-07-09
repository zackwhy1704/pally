import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_button.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/auth/services/auth_service.dart';

/// Shown when a sign-in is blocked because the account is in the deletion grace
/// window (backend `ACCOUNT_SCHEDULED_FOR_DELETION`). The restore surface — never
/// a generic error, never a dead-end. Restoring cancels the deletion and signs
/// the user straight in.
Future<void> showRestoreAccountSheet(
  BuildContext context, {
  required String email,
  required String password,
  DateTime? graceEndsAt,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
    ),
    builder: (_) => _RestoreAccountSheet(
      email: email,
      password: password,
      graceEndsAt: graceEndsAt,
    ),
  );
}

class _RestoreAccountSheet extends StatefulWidget {
  const _RestoreAccountSheet({
    required this.email,
    required this.password,
    this.graceEndsAt,
  });

  final String email;
  final String password;
  final DateTime? graceEndsAt;

  @override
  State<_RestoreAccountSheet> createState() => _RestoreAccountSheetState();
}

class _RestoreAccountSheetState extends State<_RestoreAccountSheet> {
  bool _loading = false;
  String? _error;

  Future<void> _restore() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.instance
          .restoreAccount(email: widget.email, password: widget.password);
      // Account is ACTIVE again — sign straight in with a fresh session.
      final result = await AuthService.instance
          .signInWithEmail(widget.email, widget.password);
      await AuthNotifier.instance.signIn(
        userId: result.userId,
        token: result.token,
        setupComplete: result.setupComplete,
        onboardingComplete: result.setupComplete,
        accountType: result.accountType,
      );
      if (mounted) {
        Navigator.of(context).pop();
        context.go(result.setupComplete ? '/' : '/onboarding/direct');
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.restore_rounded, size: 36, color: AppColors.teal),
            const SizedBox(height: AppSpacing.md),
            Text('This account is scheduled for deletion',
                style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.graceEndsAt != null
                  ? 'It will be permanently deleted on ${_formatDate(widget.graceEndsAt!)}. '
                      'Restore it now to keep your account and all your data.'
                  : 'Restore it now to keep your account and all your data.',
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.coralL,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Text(_error!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.text1)),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            PallyButton(
              label: 'Restore my account',
              variant: PallyButtonVariant.filled,
              fullWidth: true,
              loading: _loading,
              onPressed: _restore,
            ),
            const SizedBox(height: AppSpacing.sm),
            PallyButton(
              label: 'Not now',
              variant: PallyButtonVariant.ghost,
              fullWidth: true,
              enabled: !_loading,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final local = d.toLocal();
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }
}
