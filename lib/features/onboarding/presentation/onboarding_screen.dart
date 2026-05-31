import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/features/auth/auth_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  static const _total = 4;

  Future<void> _finish() async {
    await AuthNotifier.instance.markOnboardingComplete();
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
              _DotsBar(page: _page, total: _total),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _PageOne(onNext: _next),
                    _PageTwo(onNext: _next),
                    _PageThree(onNext: _next),
                    _PageFour(onFinish: _finish),
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
  const _DotsBar({required this.page, required this.total});
  final int page;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(total, (i) {
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
          Text('${page + 1} of $total',
              style: AppTextStyles.caption.copyWith(color: AppColors.text2)),
        ],
      ),
    );
  }
}

// Screen 1 — Trained on YOUR material
class _PageOne extends StatelessWidget {
  const _PageOne({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 220,
            color: AppColors.purpleL,
            child: Center(
              child: Image.asset('assets/images/mochi.png',
                  width: 140, height: 140, fit: BoxFit.contain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Container(
                  padding: AppSpacing.card,
                  decoration: BoxDecoration(
                    color: AppColors.purpleL,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'I learn from YOUR notes,\nnot random internet stuff 🧠',
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'So I know exactly your syllabus — not a generic textbook.',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.purple),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const _InfoRow(ok: true, title: 'Your textbook pages',
                    sub: 'Same book your teacher uses'),
                const SizedBox(height: 8),
                const _InfoRow(ok: true, title: 'Your class notes',
                    sub: 'Handwritten or printed — I can read both!'),
                const SizedBox(height: 8),
                const _InfoRow(ok: false, title: 'Random internet articles',
                    sub: 'They might not match your curriculum'),
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

// Screen 2 — One Topic at a Time
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
            child: const Center(child: Text('🍕', style: TextStyle(fontSize: 80))),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Text('Think of me like a pizza 🍕', style: AppTextStyles.title,
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text('Each slice = one topic!',
                    style: AppTextStyles.body.copyWith(color: AppColors.text2),
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
                const Row(
                  children: [
                    Expanded(child: _PizzaCard(ok: true,
                        title: 'Maths Chapter 4\n5 pages of fractions',
                        sub: 'One topic = great answers!')),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(child: _PizzaCard(ok: false,
                        title: 'Maths + History\n+ English mixed',
                        sub: 'Mixed topics = confused Mochi')),
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

// Screen 3 — You're the Teacher
class _PageThree extends StatelessWidget {
  const _PageThree({required this.onNext});
  final VoidCallback onNext;

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
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('✏️', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 8),
                  const Text('→', style: TextStyle(fontSize: 24, color: AppColors.text2)),
                  const SizedBox(width: 8),
                  Image.asset('assets/images/mochi.png', width: 80, height: 80,
                      fit: BoxFit.contain),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Text("You're the teacher now! ✏️", style: AppTextStyles.title,
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text('Upload your notes → I learn → you ask anything!',
                    style: AppTextStyles.body.copyWith(color: AppColors.text2),
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
                ..._rules.map((r) {
                  final (emoji, text) = r;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Text(emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(text, style: AppTextStyles.body)),
                    ]),
                  );
                }),
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

// Screen 4 — I Remember How You Learn
class _PageFour extends StatelessWidget {
  const _PageFour({required this.onFinish});
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 200,
            color: AppColors.amberL,
            child: const Center(child: Text('🧠', style: TextStyle(fontSize: 80))),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('I remember how you learn.',
                    style: AppTextStyles.heading1.copyWith(fontSize: 22),
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(
                  'When you get something wrong, I notice — and I bring it back until it clicks.',
                  style: AppTextStyles.body.copyWith(color: AppColors.text2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                const _MemoryBeat(emoji: '📊',
                    text: 'I track which topics trip you up',
                    color: AppColors.amberL, border: AppColors.amber),
                const SizedBox(height: 8),
                const _MemoryBeat(emoji: '🔁',
                    text: 'Hard topics come back until they stick',
                    color: AppColors.tealL, border: AppColors.teal),
                const SizedBox(height: 8),
                const _MemoryBeat(emoji: '📈',
                    text: 'Easy things get spaced out — no time wasted',
                    color: AppColors.greenL, border: AppColors.green),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: AppSpacing.card,
                  decoration: BoxDecoration(
                    color: AppColors.purpleL,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '"Not a tutor that knows the textbook.\nA tutor that knows yours."',
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.purple,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _NextButton(label: "Let's start! 🎉", onPressed: onFinish,
                    color: AppColors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryBeat extends StatelessWidget {
  const _MemoryBeat({required this.emoji, required this.text,
      required this.color, required this.border});
  final String emoji;
  final String text;
  final Color color;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

// Shared widgets
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
          color: ok ? AppColors.green.withValues(alpha: 0.3)
              : AppColors.coral.withValues(alpha: 0.3),
        ),
      ),
      child: Row(children: [
        Text(ok ? '✅' : '❌', style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: ok ? AppColors.green : AppColors.coral)),
            Text(sub, style: AppTextStyles.bodySmall),
          ],
        )),
      ]),
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
          color: ok ? AppColors.green.withValues(alpha: 0.3)
              : AppColors.coral.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ok ? '✅' : '❌', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(title, style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600, height: 1.4)),
          const SizedBox(height: 4),
          Text(sub, style: AppTextStyles.caption.copyWith(color: AppColors.text2)),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.label, required this.onPressed,
      this.color = AppColors.purple});
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(label, style: AppTextStyles.body.copyWith(
            color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
