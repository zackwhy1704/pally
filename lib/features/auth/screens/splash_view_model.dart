import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/auth/auth_state.dart';

part 'splash_view_model.g.dart';

/// Resolves the route the app should navigate to after the splash screen:
/// runs the /auth/me check, syncs any missing auth flags, and returns the
/// appropriate deep-link string.  The splash screen owns animation timing and
/// navigation; this provider owns the auth logic.
@riverpod
Future<String> resolveStartRoute(Ref ref) async {
  var auth = ref.read(authStateProvider);
  if (!auth.isSignedIn) return '/auth/signin';

  try {
    final dio = ref.read(dioProvider);
    final response = await dio.get<Map<String, dynamic>>('/api/v1/auth/me');
    final data = response.data;
    if (data != null) {
      if (data['setupComplete'] == true && !auth.isSetupComplete) {
        await AuthNotifier.instance.markSetupComplete();
      }
      if (data['setupComplete'] == true && !auth.isOnboardingComplete) {
        await AuthNotifier.instance.markOnboardingComplete();
      }
      final childName = data['childName'] as String?;
      if (childName != null &&
          childName.isNotEmpty &&
          childName != auth.childName) {
        await AuthNotifier.instance.setChildName(childName);
      }
      auth = ref.read(authStateProvider);
    }
  } on DioException catch (e) {
    appLog.w('[Splash] Profile refresh failed (cached state): ${e.type}');
  } catch (e) {
    // SharedPreferences failure, null deref, or any other non-network error —
    // fall back to the last-known cached auth state rather than crashing.
    appLog.w('[Splash] Startup error, using cached auth state: $e');
  }

  if (!auth.isSetupComplete) return '/auth/setup';
  if (!auth.isOnboardingComplete) return '/onboarding';
  return '/';
}
