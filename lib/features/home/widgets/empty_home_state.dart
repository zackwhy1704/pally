import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';

class EmptyHomeState extends StatefulWidget {
  const EmptyHomeState({super.key, required this.childName});

  final String childName;

  @override
  State<EmptyHomeState> createState() => _EmptyHomeStateState();
}

class _EmptyHomeStateState extends State<EmptyHomeState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Column(
            children: [
              Text(
                'Hi ${widget.childName}! 👋',
                style: AppTextStyles.title.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                "Let's set up your first tutor",
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.text2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.purpleL.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
              ScaleTransition(
                scale: _scaleAnim,
                child: const Text('✨', style: TextStyle(fontSize: 80)),
              ),
              const Positioned(
                  top: 24, left: 24, child: Text('✨', style: TextStyle(fontSize: 20))),
              const Positioned(
                  top: 20, right: 28, child: Text('⭐', style: TextStyle(fontSize: 16))),
              const Positioned(
                  bottom: 28, left: 30, child: Text('✦', style: TextStyle(fontSize: 18))),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              Text(
                'No tutors yet!',
                style: AppTextStyles.heading1.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Create your first Pally tutor and start learning something amazing 🚀',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.text2, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FeatureChip('🧠 Learn from your notes'),
                  _FeatureChip('💬 Ask any question'),
                  _FeatureChip('⭐ Earn XP & rewards'),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/auth/avatar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    '+ Create My First Tutor ✨',
                    style: AppTextStyles.body.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Pick a buddy, teach it your notes, ask it anything!',
                style: AppTextStyles.label.copyWith(color: AppColors.text3),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.purpleL,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.label
            .copyWith(color: AppColors.purple, fontWeight: FontWeight.w600),
      ),
    );
  }
}
