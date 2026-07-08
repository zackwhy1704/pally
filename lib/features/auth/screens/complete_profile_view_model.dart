import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/auth/services/auth_service.dart';

part 'complete_profile_view_model.g.dart';

/// State for the birth-year completion step (backend 403
/// `PROFILE_COMPLETION_REQUIRED`). Social/legacy accounts missing a birth year
/// are routed here; on submit we derive a synthetic birth year the same way the
/// direct-onboarding flow does and store the fresh token the backend returns.
@immutable
class CompleteProfileState {
  const CompleteProfileState({
    this.isUnder13,
    this.isLoading = false,
    this.error,
    this.done = false,
  });

  /// null = not yet selected; true = under 13; false = 13+.
  final bool? isUnder13;
  final bool isLoading;
  final String? error;

  /// Fires once after a successful completion; the screen listens and dismisses.
  final bool done;

  CompleteProfileState copyWith({
    Object? isUnder13 = _sentinel,
    bool? isLoading,
    Object? error = _sentinel,
    bool? done,
  }) {
    return CompleteProfileState(
      isUnder13: isUnder13 == _sentinel ? this.isUnder13 : isUnder13 as bool?,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
      done: done ?? this.done,
    );
  }
}

const _sentinel = Object();

@riverpod
class CompleteProfileViewModel extends _$CompleteProfileViewModel {
  @override
  CompleteProfileState build() => const CompleteProfileState();

  void setAgeGroup({required bool isUnder13}) {
    state = state.copyWith(isUnder13: isUnder13);
  }

  /// POST the derived birth year (and parent email for under-13) to
  /// `/api/v1/auth/complete-profile`, then store the returned fresh token.
  Future<void> submit({required String? parentEmail}) async {
    if (state.isLoading) return;

    final under13 = state.isUnder13;
    if (under13 == null) {
      state = state.copyWith(error: 'Please select your age group to continue.');
      return;
    }
    if (under13 && (parentEmail == null || parentEmail.trim().isEmpty)) {
      state = state.copyWith(error: "Please enter your parent's email address.");
      return;
    }

    // Derive a synthetic birth year the same way direct onboarding does:
    // under-13 → currentYear-12 (safely under the threshold); 13+ →
    // currentYear-13 (confirms they are at least 13).
    final birthYear =
        under13 ? DateTime.now().year - 12 : DateTime.now().year - 13;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await AuthService.instance.completeProfile(
        birthYear: birthYear,
        parentEmail: under13 ? parentEmail : null,
      );
      // Store the fresh session token so subsequent requests pass the gate.
      await AuthNotifier.instance.signIn(
        userId: result.userId,
        token: result.token,
        setupComplete: true,
        onboardingComplete: true,
        accountType: result.accountType,
      );
      appLog.i('[CompleteProfile] Birth year submitted; session refreshed');
      state = state.copyWith(isLoading: false, done: true);
    } on AuthException catch (e) {
      appLog.w('[CompleteProfile] Submit failed: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e, st) {
      appLog.e('[CompleteProfile] Unexpected error', error: e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }
}
