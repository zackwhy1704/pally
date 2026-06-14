import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/features/library/presentation/library_view_model.dart';

/// Student-side class-join entry. The single code printed on a class card
/// (e.g. "PFDM4CYB") joins the class AND its centre, then provisions the
/// student's class avatar (which carries the class's custom Mochi look).
class CentreJoinScreen extends ConsumerStatefulWidget {
  const CentreJoinScreen({super.key});

  @override
  ConsumerState<CentreJoinScreen> createState() => _CentreJoinScreenState();
}

class _CentreJoinScreenState extends ConsumerState<CentreJoinScreen> {
  final _controller = TextEditingController();
  bool _loading = false;

  String get _code => _controller.text.trim().toUpperCase();

  Future<void> _submit() async {
    if (_code.length < 6) {
      PallyToast.error(context, 'Enter the full class code');
      return;
    }
    setState(() => _loading = true);
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post<dynamic>(
        '/api/v1/centre/redeem-class-code',
        data: {'code': _code},
      );
      final data = res.data;
      final body = (data is Map && data['data'] is Map)
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data as Map);
      final className = body['className'] as String? ?? 'your class';
      if (!mounted) return;
      // Refresh the avatar surfaces so the new class Mochi appears right away.
      ref.invalidate(homeViewModelProvider);
      ref.invalidate(libraryViewModelProvider);
      PallyToast.success(context, 'Joined $className 🎉');
      context.pop();
    } on DioException catch (e) {
      final raw = e.response?.data;
      String msg = 'Could not join — check the code and try again';
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
    _controller.dispose();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              const Center(
                child: Text('🏫', style: TextStyle(fontSize: 56)),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Enter the class code',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Ask your teacher or tuition centre for the class code on their '
                'dashboard, then type it in below.',
                style: AppTextStyles.body.copyWith(color: AppColors.text2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                autofocus: true,
                keyboardType: TextInputType.visiblePassword,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  TextInputFormatter.withFunction((oldV, newV) =>
                      newV.copyWith(text: newV.text.toUpperCase())),
                ],
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 6,
                ),
                decoration: InputDecoration(
                  hintText: 'PFDM4CYB',
                  hintStyle: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 6,
                    color: AppColors.text3,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: AppColors.purple, width: 2),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: AppSizing.spinnerSm,
                          width: AppSizing.spinnerSm,
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
