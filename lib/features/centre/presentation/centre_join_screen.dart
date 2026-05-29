import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';

/// Student-side enrollment-code entry — mirrors the P4 family claim
/// layout so the UX is consistent across "claim a person" vs
/// "join a class" flows.
class CentreJoinScreen extends ConsumerStatefulWidget {
  const CentreJoinScreen({super.key});

  @override
  ConsumerState<CentreJoinScreen> createState() => _CentreJoinScreenState();
}

class _CentreJoinScreenState extends ConsumerState<CentreJoinScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;

  String get _code => _controllers.map((c) => c.text).join().toUpperCase();

  Future<void> _submit() async {
    if (_code.length != 6) {
      PallyToast.error(context, 'Enter all 6 characters');
      return;
    }
    setState(() => _loading = true);
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post<dynamic>(
        '/api/v1/centre/redeem-enroll-code',
        data: {'code': _code},
      );
      final data = res.data;
      final body = (data is Map && data['data'] is Map)
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data as Map);
      final cohort = body['cohortLabel'] as String? ?? 'your class';
      if (!mounted) return;
      PallyToast.success(context, 'Joined $cohort 🎉');
      context.pop();
    } on DioException catch (e) {
      final raw = e.response?.data;
      String msg = 'Could not join — try again';
      if (raw is Map && raw['error'] != null) {
        msg = raw['error'].toString();
      }
      if (mounted) PallyToast.error(context, msg);
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
        title: Text('Join a class', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'Ask your teacher or tuition centre for the 6-character class '
                'code, then enter it below.',
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
                      : const Text('Join class'),
                ),
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
