import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/auth/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _dot1Ctrl;
  late final AnimationController _dot2Ctrl;
  late final AnimationController _dot3Ctrl;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _dot1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _dot2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _dot2Ctrl.repeat(reverse: true);
    });

    _dot3Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _dot3Ctrl.repeat(reverse: true);
    });

    Future.delayed(const Duration(milliseconds: 1800), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    var auth = ref.read(authStateProvider);

    if (!auth.isSignedIn) {
      context.go('/auth/signin');
      return;
    }

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<Map<String, dynamic>>('/api/v1/auth/me');
      final data = response.data;
      if (data != null) {
        final backendSetup = data['setupComplete'] == true;
        if (backendSetup && !auth.isSetupComplete) {
          await AuthNotifier.instance.markSetupComplete();
        }
        if (backendSetup && !auth.isOnboardingComplete) {
          await AuthNotifier.instance.markOnboardingComplete();
        }
        final childName = data['childName'] as String?;
        if (childName != null && childName.isNotEmpty && childName != auth.childName) {
          await AuthNotifier.instance.setChildName(childName);
        }
        if (!mounted) return;
        auth = ref.read(authStateProvider);
      }
    } on DioException {
      // ignore
    }

    if (!mounted) return;

    if (!auth.isSetupComplete) {
      context.go('/auth/setup');
      return;
    }

    if (!auth.isOnboardingComplete) {
      context.go('/auth/avatar');
      return;
    }

    context.go('/');
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _dot1Ctrl.dispose();
    _dot2Ctrl.dispose();
    _dot3Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7042ED),
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: Stack(
          children: [
            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              right: -100,
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('✨', style: TextStyle(fontSize: 58)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pally',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your pocket tutor, just for you ✨',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AnimDot(_dot1Ctrl),
                      const SizedBox(width: 8),
                      _AnimDot(_dot2Ctrl),
                      const SizedBox(width: 8),
                      _AnimDot(_dot3Ctrl),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 80,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimDot extends StatelessWidget {
  const _AnimDot(this.controller);
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white.withValues(
              alpha: 0.4 + (controller.value * 0.6)),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
