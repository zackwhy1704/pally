import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/family/family_service.dart';
import 'package:pally/features/family/family_status_provider.dart';

/// P4 — parent enters the 6-character code their child generated.
class FamilyClaimScreen extends ConsumerStatefulWidget {
  const FamilyClaimScreen({super.key});

  @override
  ConsumerState<FamilyClaimScreen> createState() => _FamilyClaimScreenState();
}

class _FamilyClaimScreenState extends ConsumerState<FamilyClaimScreen> {
  final _controllers =
      List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;

  String get _code =>
      _controllers.map((c) => c.text).join().toUpperCase();

  Future<void> _submit() async {
    if (_code.length != 6) {
      PallyToast.error(context, 'Enter all 6 characters');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(familyServiceProvider).claim(_code);
      if (!mounted) return;
      // Refresh family status so Parent Mode becomes visible immediately.
      ref.invalidate(familyStatusProvider);
      if (!mounted) return;
      PallyToast.success(context, 'Linked! 🎉 Parent Mode is now enabled.');
      context.go('/family');
    } on FamilyError catch (e) {
      if (mounted) PallyToast.error(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Add your child', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'Ask your child to open Memoly → Me tab → "Link a grown-up" '
                'and read you their code.',
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  return Padding(
                    padding: EdgeInsets.only(right: i == 5 ? 0 : 8),
                    child: _CodeBox(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      onFilled: () {
                        if (i < 5) {
                          _focusNodes[i + 1].requestFocus();
                        } else {
                          _focusNodes[i].unfocus();
                        }
                      },
                      onCleared: () {
                        if (i > 0) _focusNodes[i - 1].requestFocus();
                      },
                    ),
                  );
                }),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Link account'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  // Fallback for parents creating without an existing child
                  // account — for now route back to child setup.
                  context.go('/child-setup');
                },
                child: const Text('Create a child profile myself'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.controller,
    required this.focusNode,
    required this.onFilled,
    required this.onCleared,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onFilled;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.characters,
        keyboardType: TextInputType.visiblePassword,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        ],
        style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.purple, width: 2),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty) {
            controller.text = v.toUpperCase();
            controller.selection = TextSelection.fromPosition(
                const TextPosition(offset: 1));
            onFilled();
          } else {
            onCleared();
          }
        },
      ),
    );
  }
}
