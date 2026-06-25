import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_sizing.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/auth/auth_state.dart';

class ChildSetupScreen extends ConsumerStatefulWidget {
  const ChildSetupScreen({super.key});

  @override
  ConsumerState<ChildSetupScreen> createState() => _ChildSetupScreenState();
}

class _ChildSetupScreenState extends ConsumerState<ChildSetupScreen> {
  final _nameCtrl = TextEditingController();
  String? _selectedExamSystem;
  bool _loading = false;

  // 13+-only app: no age is collected here. Age is self-attested at the
  // self-consent gate that follows this screen.

  static const _examSystems = [
    ('📝', 'Examination Preparation', 'EXAM_PREP', 'O-Level, A-Level, IB, SPM, GCSE, AP…'),
    ('🎓', 'University — Midterms / Finals', 'UNIVERSITY', 'Undergraduate courses & exams'),
    ('💻', 'Coding Interview Preparation', 'CODING_INTERVIEW', 'LeetCode, system design, tech interviews'),
    ('📊', 'Professional Examinations', 'PROFESSIONAL', 'CFA, ACCA, CPA, bar exam & professional certs'),
    ('🌐', 'Others', 'OTHER', 'Something else entirely'),
  ];

  bool get _canContinue =>
      _nameCtrl.text.trim().isNotEmpty && _selectedExamSystem != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    setState(() => _loading = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post<void>(
        '/api/v1/auth/setup',
        data: {
          'childName': _nameCtrl.text.trim(),
          'curriculum': _selectedExamSystem,
        },
      );
      await AuthNotifier.instance.setChildName(_nameCtrl.text.trim());
      await AuthNotifier.instance.markSetupComplete();
      if (!mounted) return;
      // 13+-only: everyone goes to the single self-consent gate (age 13+
      // affirmation + recorded consent).
      context.go('/consent/self');
    } on DioException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save — check your connection',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: AppColors.coral,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              const _ProgressBar(filled: 2 / 3),
              const SizedBox(height: AppSpacing.md),
              Text('About you 🙋',
                  style: AppTextStyles.title.copyWith(fontSize: 20)),
              Text('Step 2 of 3',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2)),
              const SizedBox(height: AppSpacing.lg),

              const _SectionLabel('Your name'),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                style: AppTextStyles.body,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'e.g. Alex',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.text3),
                  filled: true,
                  fillColor: const Color(0xFFEDE8F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              const _SectionLabel('What do you wish Mochi to help you with?'),
              const SizedBox(height: 4),
              Text(
                'Pick what best describes your goal',
                style: AppTextStyles.caption.copyWith(color: AppColors.text3),
              ),
              const SizedBox(height: 8),
              ..._examSystems.map(
                (e) {
                  final (icon, name, id, region) = e;
                  final selected = _selectedExamSystem == id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedExamSystem = id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              selected ? AppColors.purpleL : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.purple
                                : AppColors.outline,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: AppTextStyles.body.copyWith(
                                      color: selected
                                          ? AppColors.purple
                                          : AppColors.text1,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    region,
                                    style: AppTextStyles.caption.copyWith(
                                      color: selected
                                          ? AppColors.purple
                                              .withValues(alpha: 0.7)
                                          : AppColors.text3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.purple, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                height: AppSizing.buttonHeight,
                child: ElevatedButton(
                  onPressed: (_canContinue && !_loading) ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.purple.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: AppSizing.checkboxSize,
                          height: AppSizing.checkboxSize,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Continue',
                          style: AppTextStyles.body.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTextStyles.label.copyWith(
            fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text2));
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.filled});
  final double filled;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: filled,
        minHeight: 6,
        backgroundColor: AppColors.outline,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.purple),
      ),
    );
  }
}
