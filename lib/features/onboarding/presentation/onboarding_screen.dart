import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  String _avatarName = 'Mochi';

  @override
  void initState() {
    super.initState();
    _loadAvatarName();
  }

  Future<void> _loadAvatarName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(
        () => _avatarName = prefs.getString('child_avatar_name') ?? 'Mochi',
      );
    }
  }

  Future<void> _finish() async {
    await AuthNotifier.instance.markOnboardingComplete();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go('/');
  }

  void _next() => _controller.nextPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              _DotsBar(page: _page),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _PageOne(avatarName: _avatarName, onNext: _next),
                    _PageTwo(onNext: _next),
                    _PageThree(onFinish: _finish),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotsBar extends StatelessWidget {
  const _DotsBar({required this.page});
  final int page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final active = i == page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.purple
                      : AppColors.purple.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Text('${page + 1} of 3',
              style: AppTextStyles.caption.copyWith(color: AppColors.text2)),
        ],
      ),
    );
  }
}

// ── P1a — What is Pally? ─────────────────────────────────────────────────────

class _PageOne extends StatelessWidget {
  const _PageOne({required this.avatarName, required this.onNext});
  final String avatarName;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 280,
            color: AppColors.purpleL,
            child: Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('✨', style: TextStyle(fontSize: 68)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.purpleL,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "I'm $avatarName! I learn from YOUR notes,\nnot random internet stuff 🧠",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const _InfoRow(
                  ok: true,
                  title: 'Your textbook pages',
                  sub: 'Same book your teacher uses',
                ),
                const SizedBox(height: 8),
                const _InfoRow(
                  ok: true,
                  title: 'Your class notes',
                  sub: 'Handwritten or printed — I can read both!',
                ),
                const SizedBox(height: 8),
                const _InfoRow(
                  ok: false,
                  title: 'Random internet articles',
                  sub: 'They might not match your curriculum',
                ),
                const SizedBox(height: AppSpacing.lg),
                _NextButton(label: 'Next →', onPressed: onNext),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.ok, required this.title, required this.sub});
  final bool ok;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ok ? AppColors.greenL : AppColors.coralL,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ok
              ? AppColors.green.withValues(alpha: 0.3)
              : AppColors.coral.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Text(ok ? '✅' : '❌', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ok ? AppColors.green : AppColors.coral,
                  ),
                ),
                Text(sub, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── P1b — One Topic at a Time ─────────────────────────────────────────────────

class _PageTwo extends StatelessWidget {
  const _PageTwo({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 200,
            color: AppColors.purpleL,
            child: const Center(
              child: Text('🍕', style: TextStyle(fontSize: 80)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Text(
                  'Think of me like a pizza 🍕',
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Each slice = one topic!',
                  style: AppTextStyles.body.copyWith(color: AppColors.text2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                const Row(
                  children: [
                    Expanded(
                      child: _PizzaCard(
                        ok: true,
                        title: 'Maths Chapter 4\n5 pages of fractions',
                        sub: 'One topic = great answers!',
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _PizzaCard(
                        ok: false,
                        title: 'Maths + History\n+ English mixed',
                        sub: 'Mixed topics = confused Pally',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _NextButton(label: 'Next →', onPressed: onNext),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PizzaCard extends StatelessWidget {
  const _PizzaCard({required this.ok, required this.title, required this.sub});
  final bool ok;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ok ? AppColors.greenL : AppColors.coralL,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ok
              ? AppColors.green.withValues(alpha: 0.3)
              : AppColors.coral.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ok ? '✅' : '❌', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppTextStyles.bodySmall
                .copyWith(fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: AppTextStyles.caption.copyWith(color: AppColors.text2),
          ),
        ],
      ),
    );
  }
}

// ── P1c — You're the Teacher ──────────────────────────────────────────────────

class _PageThree extends StatelessWidget {
  const _PageThree({required this.onFinish});
  final VoidCallback onFinish;

  static const _rules = [
    ('🎯', 'Upload one topic at a time'),
    ('📖', 'Your textbook beats random articles'),
    ('🏷️', "Add context: 'Chapter 3, Year 5 Maths'"),
    ('✏️', 'Fix me if I get something wrong'),
    ('🚀', 'Keep feeding me — I get smarter!'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 160,
            color: AppColors.purpleL,
            child: const Center(
              child: Text('✏️', style: TextStyle(fontSize: 64)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Text(
                  "You're the teacher now! ✏️",
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Upload your notes → I learn → you ask anything!',
                  style: AppTextStyles.body.copyWith(color: AppColors.text2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ..._rules.map(
                  (r) {
                    final (emoji, text) = r;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Text(emoji,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(text, style: AppTextStyles.body),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _NextButton(
                  label: "Let's start! 🎉",
                  onPressed: onFinish,
                  color: AppColors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.label,
    required this.onPressed,
    this.color = AppColors.purple,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: AppTextStyles.body
              .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
