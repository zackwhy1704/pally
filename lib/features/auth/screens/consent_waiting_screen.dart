import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';

/// C3 — "Waiting for approval"
/// Polls the consent status every 15 seconds. When approved, advances to
/// onboarding. Shows "Try a demo while waiting" so the funnel never dead-ends.
class ConsentWaitingScreen extends ConsumerStatefulWidget {
  const ConsentWaitingScreen({super.key});

  @override
  ConsumerState<ConsentWaitingScreen> createState() =>
      _ConsentWaitingScreenState();
}

class _ConsentWaitingScreenState extends ConsumerState<ConsentWaitingScreen> {
  Timer? _pollTimer;
  bool _approved = false;
  bool _resending = false;
  String? _parentEmail;

  @override
  void initState() {
    super.initState();
    _loadStatus();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _poll());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    try {
      final dio = ref.read(dioProvider);
      final res =
          await dio.get<Map<String, dynamic>>('/api/v1/consent/status');
      final data = (res.data?['data'] is Map
              ? res.data!['data']
              : res.data) as Map<String, dynamic>;
      final email =
          (data['pendingRequest'] as Map<String, dynamic>?)?['parentEmail'];
      if (mounted) {
        setState(() => _parentEmail = email as String?);
      }
      if (data['accountStatus'] == 'ACTIVE') _onApproved();
    } catch (_) {}
  }

  Future<void> _poll() async {
    if (_approved) return;
    try {
      final dio = ref.read(dioProvider);
      final res =
          await dio.get<Map<String, dynamic>>('/api/v1/consent/status');
      final data = (res.data?['data'] is Map
              ? res.data!['data']
              : res.data) as Map<String, dynamic>;
      if (data['accountStatus'] == 'ACTIVE' && mounted) {
        _onApproved();
      }
    } catch (_) {}
  }

  void _onApproved() {
    _pollTimer?.cancel();
    setState(() => _approved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/onboarding');
    });
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post<void>('/api/v1/consent/resend');
      if (mounted) PallyToast.success(context, 'Reminder sent!');
    } on DioException {
      if (mounted) PallyToast.error(context, 'Could not resend — try again');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_approved) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: AppSpacing.md),
                Text("You're approved!",
                    style: AppTextStyles.heading1,
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Now you can share your own notes and save your progress.',
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.text2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                const CircularProgressIndicator(color: AppColors.purple),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              const Text('📬', style: TextStyle(fontSize: 56)),
              const SizedBox(height: AppSpacing.md),
              Text('Waiting for your grown-up!',
                  style: AppTextStyles.heading1),
              const SizedBox(height: AppSpacing.sm),
              if (_parentEmail != null)
                Text(
                  'We emailed $_parentEmail — they just need to tap one button to approve.',
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.text2),
                )
              else
                Text(
                  'We emailed your parent or guardian. They just need to tap one button.',
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.text2),
                ),
              const SizedBox(height: AppSpacing.lg),

              // Status indicator
              Container(
                padding: AppSpacing.card,
                decoration: BoxDecoration(
                  color: AppColors.amberL,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.amber.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: AppSizing.spinnerSm,
                      height: AppSizing.spinnerSm,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.amber),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Waiting for approval… checking every 15 seconds.',
                        style:
                            AppTextStyles.bodySmall.copyWith(color: AppColors.amber),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Resend
              OutlinedButton.icon(
                onPressed: _resending ? null : _resend,
                icon: _resending
                    ? const SizedBox(
                        width: AppSizing.iconSm,
                        height: AppSizing.iconSm,
                        child:
                            CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded, size: 16),
                label: const Text('Remind my grown-up'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.purple,
                  side: const BorderSide(color: AppColors.purple),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const Spacer(),

              // Demo CTA — funnel doesn't dead-end
              FilledButton.icon(
                onPressed: () => context.go('/onboarding'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.auto_stories_rounded, size: 18),
                label: const Text('Try a demo while waiting →'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You can explore Memoly now. Your progress saves once approved.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
