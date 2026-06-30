import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_theme.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';

class PallyApp extends ConsumerStatefulWidget {
  const PallyApp({super.key, GoRouter? router}) : _router = router;

  final GoRouter? _router;

  @override
  ConsumerState<PallyApp> createState() => _PallyAppState();
}

class _PallyAppState extends ConsumerState<PallyApp>
    with WidgetsBindingObserver {
  late final GoRouter _router = widget._router ?? appRouter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Purchasing happens on the web, so a user may upgrade while the app is
    // backgrounded. On resume, silently reconcile entitlement so a web purchase
    // unlocks the app with no manual refresh. reconcile() never flickers and
    // never downgrades on a transient failure.
    if (state == AppLifecycleState.resumed) {
      ref.read(entitlementVmProvider.notifier).reconcile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pally',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
