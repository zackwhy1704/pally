import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/family/family_service.dart';
import 'package:pally/features/referral/referral_service.dart';

/// Outbound Invite surface: the user's OWN codes to give away. Two cards —
/// invite a friend (referral) and connect a parent (family link) — each with a
/// QR for in-person sharing. Both are benefit-framed and confirm by code/expiry.
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
            SizedBox(height: AppSpacing.lg),
            _ConnectParentCard(),
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

// ── Connect a parent (one-time, expiring family link) ───────────────────────
class _ConnectParentCard extends ConsumerStatefulWidget {
  const _ConnectParentCard();

  @override
  ConsumerState<_ConnectParentCard> createState() => _ConnectParentCardState();
}

class _ConnectParentCardState extends ConsumerState<_ConnectParentCard> {
  FamilyLinkCode? _code;
  Duration _remaining = Duration.zero;
  Timer? _timer;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _issue() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final c = await ref.read(familyServiceProvider).issueLinkCode();
      final expires = DateTime.parse(c.expiresAt).toLocal();
      _timer?.cancel();
      setState(() {
        _code = c;
        _remaining = expires.difference(DateTime.now());
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final left = expires.difference(DateTime.now());
        if (!mounted) return;
        setState(() => _remaining = left.isNegative ? Duration.zero : left);
        if (left.isNegative) _timer?.cancel();
      });
    } catch (e) {
      appLog.w('[Invite] issueLinkCode failed: $e');
      if (mounted) setState(() => _error = 'Could not create a link code — try again');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _countdown {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final expired = _code != null && _remaining == Duration.zero;
    return _CardShell(
      icon: '👨‍👩‍👧',
      title: 'Connect a parent',
      subtitle: 'Let a parent see your progress. The code is one-time and expires.',
      child: _code == null
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (_error != null) ...[
                Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.coral)),
                const SizedBox(height: AppSpacing.sm),
              ],
              FilledButton(
                onPressed: _loading ? null : _issue,
                style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                child: _loading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create a parent link code'),
              ),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _CodePill(code: _code!.code, dimmed: expired),
              const SizedBox(height: AppSpacing.md),
              if (!expired) ...[
                _QrBox(data: 'APX:PARENTCLAIM:${_code!.code}'),
                const SizedBox(height: AppSpacing.xs),
                Text('Your parent scans this in their Apalchi app',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(color: AppColors.text3)),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text('Expires in $_countdown',
                      style: AppTextStyles.label.copyWith(
                          color: _remaining.inSeconds < 60 ? AppColors.coral : AppColors.text2)),
                ),
              ] else
                Center(
                  child: Text('This code expired — create a new one',
                      style: AppTextStyles.label.copyWith(color: AppColors.coral)),
                ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _loading ? null : _issue,
                icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.teal),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  side: const BorderSide(color: AppColors.teal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                label: Text(expired ? 'New code' : 'Refresh code'),
              ),
            ]),
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
  const _CodePill({required this.code, this.dimmed = false});

  final String code;
  final bool dimmed;

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
              color: dimmed ? AppColors.text3 : AppColors.text1,
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
