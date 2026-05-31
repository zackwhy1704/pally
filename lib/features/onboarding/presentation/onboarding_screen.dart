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
  static const _total = 3;

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

// ── Page 1 — Trained on your material ────────────────────────────────────────

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'I learn from your material — not the whole internet.',
                  style: AppTextStyles.heading1.copyWith(fontSize: 21),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Upload your notes, slides, or lecture decks and I build a brain around exactly what you\'re studying — for a quiz, a final, a module, or just to get it.',
                  style: AppTextStyles.body.copyWith(color: AppColors.text2),
                ),
                const SizedBox(height: AppSpacing.lg),
                const _ContrastRow(
                  ok: true,
                  title: 'Your notes & slides',
                  sub: 'I learn exactly what you\'re covering',
                ),
                const SizedBox(height: 8),
                const _ContrastRow(
                  ok: true,
                  title: 'Your lecture decks & readings',
                  sub: 'Same source material, sharper answers',
                ),
                const SizedBox(height: 8),
                const _ContrastRow(
                  ok: false,
                  title: 'Random internet articles',
                  sub: 'Generic info that might not match your course',
                ),
                const SizedBox(height: AppSpacing.xl),
                _NextButton(label: 'Next →', onPressed: onNext),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 2 — One focused brain per subject ────────────────────────────────────

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
            color: AppColors.tealL,
            child: const Center(
              child: Text('\u{1F9E0}', style: TextStyle(fontSize: 80)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Give me one subject at a time — I go deep.',
                  style: AppTextStyles.heading1.copyWith(fontSize: 21),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Make a separate Mochi for each subject or module. Each one only knows its stuff, so the answers stay sharp — whether it\'s Sec 3 Chemistry or a uni economics module.',
                  style: AppTextStyles.body.copyWith(color: AppColors.text2),
                ),
                const SizedBox(height: AppSpacing.lg),
                const _FocusCard(
                  ok: true,
                  title: 'One subject per Mochi',
                  sub: 'Deep, accurate answers for that course',
                ),
                const SizedBox(height: 8),
                const _FocusCard(
                  ok: false,
                  title: 'Everything in one Mochi',
                  sub: 'Mixed knowledge = muddled answers',
                ),
                const SizedBox(height: AppSpacing.xl),
                _NextButton(label: 'Next →', onPressed: onNext),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 3 — I remember how you learn + thesis ────────────────────────────────

class _PageThree extends StatelessWidget {
  const _PageThree({required this.onFinish});
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 200,
            color: AppColors.amberL,
            child: const Center(
              child: Text('\u{1F4CA}', style: TextStyle(fontSize: 80)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('I remember how you learn.',
                    style: AppTextStyles.heading1.copyWith(fontSize: 21)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'When you get something wrong, I notice — and I bring it back until it clicks. The more we study, the better I fit you.',
                  style: AppTextStyles.body.copyWith(color: AppColors.text2),
                ),
                const SizedBox(height: AppSpacing.lg),
                const _MemoryBeat(
                    emoji: '\u{1F501}',
                    text: 'Tricky topics come back until they stick',
                    color: AppColors.amberL, border: AppColors.amber),
                const SizedBox(height: 8),
                const _MemoryBeat(
                    emoji: '\u{1F3AF}',
                    text: 'Easy things get spaced out — no time wasted',
                    color: AppColors.tealL, border: AppColors.teal),
                const SizedBox(height: 8),
                const _MemoryBeat(
                    emoji: '\u{1F4C8}',
                    text: 'The more you study, the better it fits you',
                    color: AppColors.greenL, border: AppColors.green),
                const SizedBox(height: AppSpacing.xl),
                // Thesis — the positioning close
                Container(
                  padding: AppSpacing.card,
                  decoration: BoxDecoration(
                    color: AppColors.purpleL,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.purple.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '“Not a tutor that knows the textbook — a study partner that knows yours.”',
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.purple,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _NextButton(
                    label: "Let's go →",
                    onPressed: onFinish,
                    color: AppColors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _ContrastRow extends StatelessWidget {
  const _ContrastRow({required this.ok, required this.title, required this.sub});
  final bool ok;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ok ? AppColors.greenL : AppColors.coralL,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: ok ? AppColors.green.withValues(alpha: 0.3)
                : AppColors.coral.withValues(alpha: 0.3)),
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

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.ok, required this.title, required this.sub});
  final bool ok;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ok ? AppColors.greenL : AppColors.coralL,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: ok ? AppColors.green.withValues(alpha: 0.3)
                : AppColors.coral.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ok ? '✅' : '❌', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(title, style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: ok ? AppColors.green : AppColors.coral)),
          const SizedBox(height: 2),
          Text(sub, style: AppTextStyles.bodySmall.copyWith(color: AppColors.text2)),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
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
