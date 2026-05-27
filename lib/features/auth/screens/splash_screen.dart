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
      backgroundColor: const Color(0xFFFFFBF0),
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4B5).withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9F6F1).withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBE0FF).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB81A).withValues(alpha: 0.20),
                          offset: const Offset(0, 12),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/mochi.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mochi',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1733),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your study buddy ✨',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: Color(0xFF6B618A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 80,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBE0FF),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '小伴',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7042ED),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AnimDot(_dot1Ctrl, isFirst: true),
                      const SizedBox(width: 8),
                      _AnimDot(_dot2Ctrl),
                      const SizedBox(width: 8),
                      _AnimDot(_dot3Ctrl),
                    ],
                  ),
                  const SizedBox(height: 40),
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
  const _AnimDot(this.controller, {this.isFirst = false});
  final AnimationController controller;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final size = isFirst ? 12.0 : 9.0;
        final color = isFirst
            ? const Color(0xFF7042ED)
            : const Color(0xFFD4CFEA);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
