import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/router.dart';
import 'package:pally/core/theme/app_theme.dart';

class PallyApp extends StatelessWidget {
  PallyApp({super.key, GoRouter? router}) : _router = router ?? appRouter;

  final GoRouter _router;

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
