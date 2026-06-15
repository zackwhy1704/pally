import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/widgets/loading/splash_lines.dart';
import 'package:pally/features/auth/screens/splash_view_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  SplashLine? _line;

  static const _minDisplay = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _start();
  }

  Future<void> _start() async {
    try {
      // Pick the catchphrase and run app-init in parallel; enforce minimum display.
      final results = await Future.wait([
        pickSplashLine(),
        _resolveRoute(),
        Future.delayed(_minDisplay),
      ]);

      if (!mounted) return;
      // Defensive casts — Future.wait preserves order so [0] is pickSplashLine
      // and [1] is _resolveRoute(); both always return their typed values.
      final line = results[0] is SplashLine
          ? results[0] as SplashLine
          : kSplashLines[1]; // fallback to product-truth line
      final route = results[1] is String ? results[1] as String : '/';

      setState(() => _line = line);
      await _fadeCtrl.forward();
      if (mounted) context.go(route);
    } catch (e, st) {
      // Any startup error (SharedPreferences, network, null deref) — never
      // leave the user on a blank splash. Fall back to sign-in.
      debugPrint('[Splash] Startup failed, falling back to signin: $e\n$st');
      if (mounted) context.go('/auth/signin');
    }
  }

  Future<String> _resolveRoute() =>
      ref.read(resolveStartRouteProvider.future);

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7042ED),
      body: Stack(
        children: [
          // Subtle background circles for depth
          Positioned(
            top: -60,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Mochi mascot
                Builder(builder: (context) {
                  final mochiSize = MediaQuery.of(context).size.shortestSide * 0.45;
                  return Image.asset(
                    'assets/images/mochi.png',
                    width: mochiSize,
                    height: mochiSize,
                    fit: BoxFit.contain,
                  );
                }),
                const SizedBox(height: 32),
                // Catchphrase — fades in once _line is ready
                FadeTransition(
                  opacity: _fadeCtrl,
                  child: _line == null
                      ? const SizedBox(height: 72)
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              Text(
                                _line!.hero,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _line!.sub,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFE4DBFF),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                ),
                const Spacer(flex: 3),
                // Wordmark
                const Text(
                  'Mochi',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD4CBFF),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
