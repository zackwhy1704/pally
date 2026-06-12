import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_loading_spinner.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/family/family_service.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

/// P3 — child generates a one-shot code that a parent can claim.
class FamilyLinkCodeScreen extends ConsumerStatefulWidget {
  const FamilyLinkCodeScreen({super.key, this.clock = DateTime.now});

  /// Wall-clock source. Injectable so tests can drive the countdown
  /// deterministically; defaults to [DateTime.now] in production.
  final DateTime Function() clock;

  @override
  ConsumerState<FamilyLinkCodeScreen> createState() =>
      _FamilyLinkCodeScreenState();
}

class _FamilyLinkCodeScreenState
    extends ConsumerState<FamilyLinkCodeScreen> {
  FamilyLinkCode? _code;
  String? _error;
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _issue();
  }

  Future<void> _issue() async {
    setState(() {
      _code = null;
      _error = null;
    });
    try {
      final svc = ref.read(familyServiceProvider);
      final c = await svc.issueLinkCode();
      // Read the real expiry from the server — never hardcode the TTL. The
      // backend is the source of truth for how long the code is valid.
      final expires = DateTime.parse(c.expiresAt).toLocal();
      void recompute() {
        var left = expires.difference(widget.clock());
        if (left.isNegative) left = Duration.zero;
        setState(() => _remaining = left);
        // Stop ticking the moment the code expires — no point spinning a
        // timer once we've flipped to the expired state.
        if (left == Duration.zero) _timer?.cancel();
      }

      setState(() => _code = c);
      _timer?.cancel();
      recompute();
      // Tick every second so the countdown visibly decrements (mm:ss).
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) {
          _timer?.cancel();
          return;
        }
        recompute();
      });
    } catch (e) {
      setState(() => _error = 'Could not generate a code — try again');
    }
  }

  /// Formats a remaining duration as mm:ss (e.g. 9m 5s -> "09:05").
  static String _formatRemaining(Duration d) {
    final totalSeconds = d.inSeconds;
    final mm = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final ss = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Link a grown-up', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'Share this code with a parent or guardian. They\'ll enter '
                'it in their Apalchi app to connect to your account.',
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_code != null) ...[
                _CodeDisplay(code: _code!.code),
                const SizedBox(height: AppSpacing.sm),
                // Plain, kid-readable TTL near the code.
                Text(
                  'This code works for 15 minutes.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.text2),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _remaining == Duration.zero
                      ? 'Code expired — tap refresh below'
                      : 'Expires in ${_formatRemaining(_remaining)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _remaining == Duration.zero
                        ? AppColors.coral
                        : AppColors.text1,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: _code!.code));
                          HapticFeedback.lightImpact();
                          PallyToast.success(context, 'Code copied');
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Copy'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => share_plus.Share.share(
                            'Connect to my Apalchi account with code: ${_code!.code}'),
                        icon: const Icon(Icons.ios_share_rounded, size: 16),
                        label: const Text('Share'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton.icon(
                  onPressed: _issue,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Get a new code'),
                ),
              ] else if (_error != null) ...[
                Text(_error!,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.coral)),
                const SizedBox(height: AppSpacing.md),
                FilledButton(onPressed: _issue, child: const Text('Retry')),
              ] else
                const PallyLoadingSpinner(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeDisplay extends StatelessWidget {
  const _CodeDisplay({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.purpleL,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.4)),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: AppColors.purple,
          letterSpacing: 8,
        ),
      ),
    );
  }
}
