import 'package:flutter/material.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_colors.dart';
import 'package:pally/core/theme/app_spacing.dart';
import 'package:pally/core/theme/app_text_styles.dart';
import 'package:pally/core/ui/pally_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      emoji: '🌟',
      title: 'Meet your AI tutor!',
      body:
          'Create a cute AI tutor character that learns everything YOUR child knows. No generic answers — just lessons built from their own notes.',
      bgColor: AppColors.purpleL,
      accentColor: AppColors.purple,
    ),
    _OnboardingPage(
      emoji: '📸',
      title: 'Upload & it learns',
      body:
          'Snap a photo of textbooks, upload PDFs, or paste notes. Your tutor reads it all and turns it into a personal knowledge brain.',
      bgColor: AppColors.tealL,
      accentColor: AppColors.teal,
    ),
    _OnboardingPage(
      emoji: '🎯',
      title: 'Chat, quiz, master',
      body:
          'Ask homework questions, take daily quizzes, flip flashcards. Watch your mastery grow — one star at a time! ⭐',
      bgColor: AppColors.amberL,
      accentColor: AppColors.amber,
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) const HomeRoute().go(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      backgroundColor: _pages[_page].bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Skip',
                  style: AppTextStyles.body.copyWith(
                    color: _pages[_page].accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? _pages[_page].accentColor
                        : _pages[_page].accentColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: PallyButton(
                label: isLast ? "Let's go! 🚀" : 'Next →',
                onPressed: isLast
                    ? _finish
                    : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.body,
    required this.bgColor,
    required this.accentColor,
  });

  final String emoji;
  final String title;
  final String body;
  final Color bgColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTextStyles.heading1
                .copyWith(color: accentColor, fontSize: 26),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            body,
            style: AppTextStyles.body.copyWith(
              color: AppColors.text1,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
