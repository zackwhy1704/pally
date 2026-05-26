import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildSetupScreen extends ConsumerStatefulWidget {
  const ChildSetupScreen({super.key});

  @override
  ConsumerState<ChildSetupScreen> createState() => _ChildSetupScreenState();
}

class _ChildSetupScreenState extends ConsumerState<ChildSetupScreen> {
  final _nameCtrl = TextEditingController();
  String? _selectedYear;
  String? _selectedCurriculum;
  bool _loading = false;

  static const _years = ['Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8'];

  static const _curricula = [
    ('🇸🇬', 'Singapore MOE', 'SINGAPORE_MOE'),
    ('🇦🇺', 'Australian', 'AUSTRALIAN'),
    ('🇬🇧', 'UK National', 'UK_NATIONAL'),
    ('🇺🇸', 'US Common Core', 'US_COMMON_CORE'),
    ('🌐', 'Other', 'OTHER'),
  ];

  bool get _canContinue =>
      _nameCtrl.text.trim().isNotEmpty &&
      _selectedYear != null &&
      _selectedCurriculum != null;

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
          'yearLevel': int.tryParse(_selectedYear!.replaceAll('Y', '')) ?? 1,
          'curriculum': _selectedCurriculum,
        },
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('child_name', _nameCtrl.text.trim());
      AuthNotifier.instance.markSetupComplete();
      if (mounted) context.go('/auth/avatar');
    } on DioException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save setup — check your connection',
                style: AppTextStyles.bodySmall
                    .copyWith(color: Colors.white)),
            backgroundColor: AppColors.coral,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
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
              Text("Who's learning? 🎒",
                  style: AppTextStyles.title.copyWith(fontSize: 20)),
              Text('Step 2 of 3',
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.text2)),
              const SizedBox(height: AppSpacing.lg),

              // Child name
              const _SectionLabel("Child's name"),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                style: AppTextStyles.body,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'e.g. Alex',
                  hintStyle:
                      AppTextStyles.body.copyWith(color: AppColors.text3),
                  filled: true,
                  fillColor: const Color(0xFFEDE8F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Year selector
              const _SectionLabel('What year are they in?'),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _years.map((y) {
                    final selected = _selectedYear == y;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedYear = y),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.purple
                                : const Color(0xFFEDE8F5),
                            borderRadius: BorderRadius.circular(20),
                            border: selected
                                ? null
                                : Border.all(
                                    color: AppColors.outline,
                                    width: 1,
                                  ),
                          ),
                          child: Text(
                            y,
                            style: AppTextStyles.label.copyWith(
                              color:
                                  selected ? Colors.white : AppColors.text2,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Curriculum selector
              const _SectionLabel('Curriculum'),
              const SizedBox(height: 8),
              ..._curricula.map(
                (c) {
                  final (flag, name, id) = c;
                  final selected = _selectedCurriculum == id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCurriculum = id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 42,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.purpleL
                              : AppColors.surface,
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
                            Text(flag,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                name,
                                style: AppTextStyles.body.copyWith(
                                  color: selected
                                      ? AppColors.purple
                                      : AppColors.text1,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (selected)
                              const Icon(Icons.check_rounded,
                                  color: AppColors.purple, size: 18),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                height: 52,
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
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Continue',
                          style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
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
    return Text(
      text,
      style: AppTextStyles.label.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.text2),
    );
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
        valueColor:
            const AlwaysStoppedAnimation<Color>(AppColors.purple),
      ),
    );
  }
}
