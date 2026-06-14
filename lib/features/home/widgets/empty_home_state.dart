import 'package:flutter/material.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/adaptive_layout.dart';

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
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height
              - MediaQuery.of(context).padding.top
              - MediaQuery.of(context).padding.bottom
              - 120,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    Text('Hi ${widget.childName}! 👋',
                        style: AppTextStyles.title.copyWith(fontSize: 18),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text("Let's set up your first Mochi",
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              const Spacer(),
              Builder(builder: (context) {
                final outer = Adaptive.width(context, 0.62, max: 240);
                final mochi = Adaptive.width(context, 0.46, max: 180);
                return SizedBox(
                  width: outer,
                  height: outer,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: Image.asset('assets/images/mochi.png',
                            width: mochi, height: mochi, fit: BoxFit.contain),
                      ),
                    const Positioned(top: 20, left: 20,
                          child: Text('✨', style: TextStyle(fontSize: 22))),
                      const Positioned(top: 16, right: 24,
                          child: Text('⭐', style: TextStyle(fontSize: 18))),
                      const Positioned(bottom: 24, left: 28,
                          child: Text('✦', style: TextStyle(fontSize: 20))),
                    ],
                  ),
                );
              }),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    Text('No Mochis yet!',
                        style: AppTextStyles.heading1.copyWith(fontSize: 22),
                        textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Create your first Mochi and start learning something amazing 🚀',
                        style: AppTextStyles.body.copyWith(color: AppColors.text2, height: 1.5),
                        textAlign: TextAlign.center),
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
                        onPressed: () => const CreateTutorRoute().go(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text('+ Create My First Mochi ✨',
                            style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Pick a buddy, teach it your notes, ask it anything!',
                        style: AppTextStyles.label.copyWith(color: AppColors.text3),
                        textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () => const CentreJoinRoute().push(context),
                      child: Text('🏫  Got a class code? Join your class',
                          style: AppTextStyles.body.copyWith(
                              color: AppColors.purple,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
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
