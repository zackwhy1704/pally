import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';

/// C2 — "Let's ask a grown-up"
/// Collects a parent/guardian email for under-13 parental consent flow.
/// One field, friendly copy. No identity documents, no NRIC (PDPA data-minimisation).
class ParentConsentScreen extends ConsumerStatefulWidget {
  const ParentConsentScreen({super.key});

  @override
  ConsumerState<ParentConsentScreen> createState() =>
      _ParentConsentScreenState();
}

class _ParentConsentScreenState extends ConsumerState<ParentConsentScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _emailCtrl.text.trim().contains('@') && !_loading;

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      final dio = ref.read(dioProvider);
      await dio.post<void>(
        '/api/v1/consent/request-parent',
        data: {'parentEmail': _emailCtrl.text.trim().toLowerCase()},
      );
      if (mounted) context.go('/consent/waiting');
    } on DioException catch (e) {
      final respData = e.response?.data;
      final msg = (respData is Map ? respData['error'] : null) as String?
          ?? 'Could not send the email — check your connection';
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              const Text('👨‍👩‍👧', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppSpacing.md),
              Text("Let's ask a grown-up first",
                  style: AppTextStyles.heading1),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Because you\'re in primary school, we need a parent or guardian to approve your account — it\'s just one quick email! They tap one button, and you\'re in.',
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text("Parent or guardian's email",
                  style: AppTextStyles.label),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) { if (_canSubmit) _submit(); },
                decoration: InputDecoration(
                  hintText: 'parent@example.com',
                  filled: true,
                  fillColor: const Color(0xFFEDE8F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  errorText: _error,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.purpleL,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded,
                        size: 14, color: AppColors.purple),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'We only use this email to send the approval. We never sell or share it.',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.purple),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Send to my grown-up →'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
