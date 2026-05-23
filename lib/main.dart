import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/app/pally_app.dart';
import 'package:pally/app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;
  final router = buildAppRouter(onboardingDone: onboardingDone);
  runApp(
    ProviderScope(
      child: PallyApp(router: router),
    ),
  );
}
