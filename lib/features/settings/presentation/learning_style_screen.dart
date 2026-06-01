import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_toast.dart';
import 'package:pally/features/chat/widgets/teaching_mode_toggle.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDefaultModeKey = 'pref_default_answer_mode';

/// GM5 — Settings → Learning style.
/// Lets the user set their default answer mode (GUIDE recommended / ANSWER).
class LearningStyleScreen extends ConsumerStatefulWidget {
  const LearningStyleScreen({super.key});

  @override
  ConsumerState<LearningStyleScreen> createState() =>
      _LearningStyleScreenState();
}

class _LearningStyleScreenState extends ConsumerState<LearningStyleScreen> {
  TeachingMode _selected = TeachingMode.teaching;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kDefaultModeKey) ?? 'GUIDE';
    if (mounted) {
      setState(() => _selected =
          stored == 'ANSWER' ? TeachingMode.direct : TeachingMode.teaching);
    }
  }

  Future<void> _save(TeachingMode mode) async {
    setState(() { _selected = mode; _saving = true; });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kDefaultModeKey, mode.isGuide ? 'GUIDE' : 'ANSWER');
      final dio = ref.read(dioProvider);
      await dio.patch<void>(
        '/api/v1/auth/settings/answer-mode',
        data: {'defaultAnswerMode': mode.isGuide ? 'GUIDE' : 'ANSWER'},
      );
      if (mounted) PallyToast.success(context, 'Default saved!');
    } on DioException {
      if (mounted) {
        PallyToast.error(context, 'Could not save — check your connection');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Learning style', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Default answer mode',
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Guide Me builds understanding — you figure it out, '
              'you remember more. You can switch per question with the '
              'toggle in chat.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.text2),
            ),
            const SizedBox(height: AppSpacing.lg),

            _ModeCard(
              mode: TeachingMode.teaching,
              selected: _selected == TeachingMode.teaching,
              onTap: _saving ? null : () => _save(TeachingMode.teaching),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ModeCard(
              mode: TeachingMode.direct,
              selected: _selected == TeachingMode.direct,
              onTap: _saving ? null : () => _save(TeachingMode.direct),
            ),
            const SizedBox(height: AppSpacing.xl),

          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final TeachingMode mode;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isGuide = mode.isGuide;
    final accent = isGuide ? AppColors.purple : AppColors.amber;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          color: selected
              ? (isGuide ? AppColors.purpleL : AppColors.amberL)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? accent : AppColors.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(mode.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        mode.label,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: selected ? accent : AppColors.text1,
                        ),
                      ),
                      if (isGuide) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('RECOMMENDED',
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isGuide
                        ? 'Mochi guides you to the answer — builds real retention.'
                        : 'Mochi gives the worked solution — great for checking your work.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.text2),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: accent, size: 22),
          ],
        ),
      ),
    );
  }
}
