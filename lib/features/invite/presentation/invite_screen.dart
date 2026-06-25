
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/referral/referral_service.dart';

/// Outbound Invite surface: the user's OWN code to give away. Invite a friend
/// (referral) with a benefit-framed share message + a QR for in-person sharing.
class InviteScreen extends ConsumerWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.text1,
        title: Text('Invite & connect',
            style: AppTextStyles.title.copyWith(color: AppColors.text1)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: const [
            _InviteFriendCard(),
          ],
        ),
      ),
    );
  }
}

// ── Invite a friend (referral) ──────────────────────────────────────────────
class _InviteFriendCard extends ConsumerStatefulWidget {
  const _InviteFriendCard();

  @override
  ConsumerState<_InviteFriendCard> createState() => _InviteFriendCardState();
}

class _InviteFriendCardState extends ConsumerState<_InviteFriendCard> {
  bool _showQr = false;

  String _message(String code) =>
      'Join me on Apalchi — the study buddy that learns YOUR notes. '
      'Use my code $code at sign-up and we both earn bonus stars on your first quiz. 🎁';

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(referralSummaryProvider);
    return _CardShell(
      icon: '🎁',
      title: 'Invite a friend',
      subtitle: 'You both get bonus stars when they take their first quiz.',
      child: summaryAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => TextButton(
          onPressed: () => ref.invalidate(referralSummaryProvider),
          child: const Text('Could not load your code — tap to retry'),
        ),
        data: (summary) {
          final code = summary.code;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CodePill(code: code),
              if (_showQr && code.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _QrBox(data: code),
                const SizedBox(height: AppSpacing.xs),
                Text('Friends can scan this to grab your code',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(color: AppColors.text3)),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: code.isEmpty
                        ? null
                        : () => setState(() => _showQr = !_showQr),
                    icon: Icon(_showQr ? Icons.qr_code_2_rounded : Icons.qr_code_rounded,
                        size: 18, color: AppColors.purple),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.purple,
                      side: const BorderSide(color: AppColors.purple),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    label: Text(_showQr ? 'Hide QR' : 'Show QR'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: code.isEmpty
                        ? null
                        : () => share_plus.Share.share(_message(code)),
                    icon: const Icon(Icons.ios_share_rounded, size: 18),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.purple),
                    label: const Text('Share'),
                  ),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }
}

// ── Shared building blocks ──────────────────────────────────────────────────
class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(title,
                style: AppTextStyles.title.copyWith(color: AppColors.text1)),
          ),
        ]),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2)),
        const SizedBox(height: AppSpacing.md),
        child,
      ]),
    );
  }
}

class _CodePill extends StatelessWidget {
  const _CodePill({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        PallyToast.success(context, 'Code copied');
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surf2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            code.isEmpty ? '——————' : code,
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.text1,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.copy_rounded, size: 16, color: AppColors.text3),
        ]),
      ),
    );
  }
}

class _QrBox extends StatelessWidget {
  const _QrBox({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          size: 180,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
