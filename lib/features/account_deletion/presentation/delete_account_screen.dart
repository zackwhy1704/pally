import 'package:flutter/material.dart';
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
    final state = ref.watch(deleteAccountViewModelProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Delete account', style: AppTextStyles.title),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delete your account?', style: AppTextStyles.heading1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'This permanently deletes your account. It cannot be undone after the '
          'restore window closes.',
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('What gets deleted', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.sm),
        ...const [
          'Your Mochis and everything they learned from your notes',
          'Your uploaded notes, lessons, quizzes and flashcards',
          'Your progress, streaks, stars and chat history',
        ].map((t) => _Bullet(text: t)),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.tealL,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Text(
            'You have 14 days to change your mind. Sign back in during that time '
            'to restore your account and all your data. After 14 days it is gone '
            'for good.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.text1),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        PallyButton(
          label: 'Continue',
          variant: PallyButtonVariant.destructive,
          fullWidth: true,
          onPressed: onContinue,
        ),
        const SizedBox(height: AppSpacing.sm),
        PallyButton(
          label: 'Keep my account',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm it\'s you', style: AppTextStyles.heading1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'For your security, confirm your identity before we schedule the '
          'deletion.',
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (!state.codeSent) ...[
          TextField(
            controller: passwordController,
            obscureText: true,
            enabled: !state.isLoading,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: state.isLoading ? null : onSendCode,
            child: const Text('Email me a code instead'),
          ),
        ] else ...[
          Text(
            'We emailed you a 6-digit code. Enter it below to confirm.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: codeController,
            keyboardType: TextInputType.number,
            enabled: !state.isLoading,
            decoration: const InputDecoration(
              labelText: '6-digit code',
              border: OutlineInputBorder(),
            ),
          ),
        ],
        if (state.error != null) ...[
          const SizedBox(height: AppSpacing.md),
          _InlineError(message: state.error!),
        ],
        const SizedBox(height: AppSpacing.xl),
        PallyButton(
          label: 'Delete my account',
          variant: PallyButtonVariant.destructive,
          fullWidth: true,
          loading: state.isLoading,
          onPressed: onDelete,
        ),
        const SizedBox(height: AppSpacing.sm),
        PallyButton(
          label: 'Back',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.schedule_rounded, size: 40, color: AppColors.teal),
        const SizedBox(height: AppSpacing.md),
        Text('Your account is scheduled for deletion',
            style: AppTextStyles.heading1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          state.graceEndsAt != null
              ? 'It will be permanently deleted on ${_formatDate(state.graceEndsAt!)}.'
              : 'It will be permanently deleted after the 14-day restore window.',
          style: AppTextStyles.body.copyWith(color: AppColors.text2),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Changed your mind? Sign back in before then to restore your account '
          'and all your data.',
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
              'If you subscribed through the App Store or Google Play, remember '
              'to cancel your subscription in your device\'s subscription '
              'settings — deleting your account here does not cancel it.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.text1),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        PallyButton(
          label: 'Sign out',
          variant: PallyButtonVariant.filled,
          fullWidth: true,
          onPressed: onDone,
        ),
      ],
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
