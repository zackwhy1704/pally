import 'package:flutter/material.dart';
import 'package:pally/l10n/app_localizations.dart';
import 'package:pally/features/account_deletion/presentation/delete_account_error_localizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_button.dart';
import 'package:pally/features/account_deletion/application/delete_account_view_model.dart';
import 'package:pally/features/auth/services/auth_service.dart';

/// Delete-account flow: consequences → re-auth → scheduled. Deletion enters a
/// 14-day restore window (never "deactivate"; it is permanent after the window).
/// iOS anti-steering: no external links, no prices anywhere in this flow.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  DeleteAccountViewModel get _vm =>
      ref.read(deleteAccountViewModelProvider.notifier);

  Future<void> _signOutAndLeave() async {
    await AuthService.instance.signOut();
    if (mounted) context.go('/auth/signin');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(deleteAccountViewModelProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text(l.deleteAccountAppBar, style: AppTextStyles.title),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: switch (state.step) {
                DeleteAccountStep.consequences => _Consequences(
                    onContinue: _vm.proceedToReauth,
                    onCancel: () => context.pop(),
                  ),
                DeleteAccountStep.reauth => _Reauth(
                    state: state,
                    passwordController: _passwordController,
                    codeController: _codeController,
                    onSendCode: _vm.sendCode,
                    onBack: _vm.backToConsequences,
                    onDelete: () => _vm.requestDeletion(
                      password: state.codeSent
                          ? null
                          : _passwordController.text.trim(),
                      code: state.codeSent ? _codeController.text.trim() : null,
                    ),
                  ),
                DeleteAccountStep.scheduled => _Scheduled(
                    state: state,
                    onDone: _signOutAndLeave,
                  ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step 1: consequences ──────────────────────────────────────────────────────

class _Consequences extends StatelessWidget {
  const _Consequences({required this.onContinue, required this.onCancel});

  final VoidCallback onContinue;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.deleteAccountTitle, style: AppTextStyles.heading1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l.deleteAccountIntro,
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l.deleteAccountWhatDeleted, style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.sm),
        ...[
          l.deleteAccountItem1(l.mascotName),
          l.deleteAccountItem2,
          l.deleteAccountItem3,
        ].map((t) => _Bullet(text: t)),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.tealL,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Text(
            l.deleteAccountGrace,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.text1),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        PallyButton(
          label: l.moduleCtaContinue,
          variant: PallyButtonVariant.destructive,
          fullWidth: true,
          onPressed: onContinue,
        ),
        const SizedBox(height: AppSpacing.sm),
        PallyButton(
          label: l.deleteAccountKeep,
          variant: PallyButtonVariant.ghost,
          fullWidth: true,
          onPressed: onCancel,
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.remove_circle_outline_rounded,
                size: 18, color: AppColors.coral),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text,
                style: AppTextStyles.body.copyWith(color: AppColors.text2)),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: re-auth ───────────────────────────────────────────────────────────

class _Reauth extends StatelessWidget {
  const _Reauth({
    required this.state,
    required this.passwordController,
    required this.codeController,
    required this.onSendCode,
    required this.onBack,
    required this.onDelete,
  });

  final DeleteAccountState state;
  final TextEditingController passwordController;
  final TextEditingController codeController;
  final VoidCallback onSendCode;
  final VoidCallback onBack;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.deleteAccountConfirmTitle, style: AppTextStyles.heading1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l.deleteAccountConfirmBody,
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (!state.codeSent) ...[
          TextField(
            controller: passwordController,
            obscureText: true,
            enabled: !state.isLoading,
            decoration: InputDecoration(
              labelText: l.signInPasswordLabel,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: state.isLoading ? null : onSendCode,
            child: Text(l.deleteAccountEmailCode),
          ),
        ] else ...[
          Text(
            l.deleteAccountCodeSent,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: codeController,
            keyboardType: TextInputType.number,
            enabled: !state.isLoading,
            decoration: InputDecoration(
              labelText: l.deleteAccountCodeLabel,
              border: OutlineInputBorder(),
            ),
          ),
        ],
        if (state.error != null) ...[
          const SizedBox(height: AppSpacing.md),
          _InlineError(message: localizedDeleteAccountError(l, state.error!)),
        ],
        const SizedBox(height: AppSpacing.xl),
        PallyButton(
          label: l.deleteAccountConfirmBtn,
          variant: PallyButtonVariant.destructive,
          fullWidth: true,
          loading: state.isLoading,
          onPressed: onDelete,
        ),
        const SizedBox(height: AppSpacing.sm),
        PallyButton(
          label: l.deleteAccountBack,
          variant: PallyButtonVariant.ghost,
          fullWidth: true,
          enabled: !state.isLoading,
          onPressed: onBack,
        ),
      ],
    );
  }
}

// ── Step 3: scheduled ─────────────────────────────────────────────────────────

class _Scheduled extends StatelessWidget {
  const _Scheduled({required this.state, required this.onDone});

  final DeleteAccountState state;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.schedule_rounded, size: 40, color: AppColors.teal),
        const SizedBox(height: AppSpacing.md),
        Text(l.deleteAccountScheduledTitle,
            style: AppTextStyles.heading1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          state.graceEndsAt != null
              ? l.deleteAccountScheduledOn(_formatDate(l, state.graceEndsAt!))
              : l.deleteAccountScheduledGeneric,
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l.deleteAccountChangedMind,
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
        ),
        if (state.needsManualCancellation) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surf2,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Text(
              l.deleteAccountManualCancel,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text1),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        PallyButton(
          label: l.homeConsentSignOut,
          variant: PallyButtonVariant.filled,
          fullWidth: true,
          onPressed: onDone,
        ),
      ],
    );
  }

  static String _formatDate(AppLocalizations l, DateTime d) {
    final months = [
      l.monthJan, l.monthFeb, l.monthMar, l.monthApr, l.monthMay, l.monthJun,
      l.monthJul, l.monthAug, l.monthSep, l.monthOct, l.monthNov, l.monthDec,
    ];
    final local = d.toLocal();
    return l.dateFormatDMY(local.day, months[local.month - 1], local.year);
  }
}

// ── Shared: persistent inline error (never a toast) ───────────────────────────

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.coralL,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: AppColors.coral),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message,
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.text1)),
          ),
        ],
      ),
    );
  }
}
