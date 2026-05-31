import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/theme/app_colors.dart';
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
  // Age as integer (13–22; 22 represents "21+").
  // Defaulting to 13+ path — under-13 parent-email flow kept dormant.
  int? _selectedAge;
  String? _selectedExamSystem;
  bool _loading = false;

  // Age options for the dropdown: 13 … 21, 21+.
  // "21+" maps to integer 22 so the backend receives a numeric yearLevel.
  static const _ageOptions = [
    (label: '13', value: 13),
    (label: '14', value: 14),
    (label: '15', value: 15),
    (label: '16', value: 16),
    (label: '17', value: 17),
    (label: '18', value: 18),
    (label: '19', value: 19),
    (label: '20', value: 20),
    (label: '21', value: 21),
    (label: '21+', value: 22),
  ];

  // Under-13 consent infrastructure kept present but dormant.
  // The current default always routes to 13+ self-consent.
  bool get _isUnder13 => (_selectedAge ?? 99) < 13;

  static const _examSystems = [
    ('📐', 'Cambridge (IGCSE / O-Level / A-Level)', 'CAMBRIDGE', 'SG, MY, SEA, 145+ countries'),
    ('🌍', 'IB (PYP / MYP / Diploma)', 'IB', 'International schools worldwide'),
    ('🇸🇬', 'Singapore PSLE', 'SG_PSLE', 'Singapore national primary'),
    ('🇲🇾', 'Malaysia SPM / KSSM', 'MY_SPM', 'Malaysia national curriculum'),
    ('🇬🇧', 'UK GCSE / A-Level', 'UK_GCSE', 'UK & British international schools'),
    ('🇺🇸', 'US Common Core / AP', 'US_AP', 'US & American international schools'),
    ('🇦🇺', 'Australian Curriculum (ATAR)', 'AU_ATAR', 'Australia & Australian intl schools'),
    ('🎓', 'University / Self-directed', 'UNIVERSITY', 'Higher education & independent learning'),
    ('🌐', 'Other / Not sure', 'OTHER', 'Custom or home curriculum'),
  ];

  bool get _canContinue =>
      _nameCtrl.text.trim().isNotEmpty &&
      _selectedAge != null &&
      _selectedExamSystem != null;

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
          'yearLevel': _selectedAge,
          'curriculum': _selectedExamSystem,
        },
      );
      await AuthNotifier.instance.setChildName(_nameCtrl.text.trim());
      await AuthNotifier.instance.markSetupComplete();
      if (!mounted) return;
      // Default: 13+ self-consent path.
      // Under-13 parent-email flow remains in code but is not the default route.
      if (_isUnder13) {
        context.go('/consent/parent-email'); // dormant — age dropdown starts at 13
      } else {
        context.go('/consent/self');
      }
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

              const _SectionLabel('How old are you?'),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedAge,
                hint: Text('Select your age',
                    style: AppTextStyles.body.copyWith(color: AppColors.text3)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFEDE8F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: _ageOptions
                    .map((opt) => DropdownMenuItem<int>(
                          value: opt.value,
                          child: Text(opt.label, style: AppTextStyles.body),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedAge = v),
              ),
              const SizedBox(height: AppSpacing.lg),

              const _SectionLabel('Exam system / Curriculum'),
              const SizedBox(height: 4),
              Text(
                'Choose what matches your studies',
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
                          width: 22, height: 22,
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
