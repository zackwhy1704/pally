import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/utils/logger.dart';

part 'delete_account_view_model.g.dart';

/// The three steps of the delete-account flow: read the consequences → re-auth →
/// the account is scheduled (grace window).
enum DeleteAccountStep { consequences, reauth, scheduled }

@immutable
class DeleteAccountState {
  const DeleteAccountState({
    this.step = DeleteAccountStep.consequences,
    this.isLoading = false,
    this.error,
    this.codeSent = false,
    this.graceEndsAt,
    this.needsManualCancellation = false,
  });

  final DeleteAccountStep step;
  final bool isLoading;

  /// Persistent inline error (never a vanishing toast) with a Retry affordance
  /// in the UI. Null when there is none.
  final String? error;

  /// True once a re-auth code has been emailed (passwordless / social accounts).
  final bool codeSent;

  /// Set on success: when the account is permanently deleted.
  final DateTime? graceEndsAt;

  /// True when a store IAP (App Store / Play) must be cancelled by the user
  /// themselves — the server can't. Drives the iOS-safe "cancel in your device's
  /// subscription settings" note. Never a price, never an external link.
  final bool needsManualCancellation;

  DeleteAccountState copyWith({
    DeleteAccountStep? step,
    bool? isLoading,
    Object? error = _sentinel,
    bool? codeSent,
    Object? graceEndsAt = _sentinel,
    bool? needsManualCancellation,
  }) {
    return DeleteAccountState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
      codeSent: codeSent ?? this.codeSent,
      graceEndsAt: graceEndsAt == _sentinel
          ? this.graceEndsAt
          : graceEndsAt as DateTime?,
      needsManualCancellation:
          needsManualCancellation ?? this.needsManualCancellation,
    );
  }
}

const _sentinel = Object();

/// Drives the account-deletion request flow (grace/re-auth). All network access
/// lives here, never in the screen. Deletion enters a 14-day restore window; the
/// screen shows the scheduled state on success.
@riverpod
class DeleteAccountViewModel extends _$DeleteAccountViewModel {
  static const _timeout = Duration(seconds: 20);

  @override
  DeleteAccountState build() => const DeleteAccountState();

  void proceedToReauth() =>
      state = state.copyWith(step: DeleteAccountStep.reauth, error: null);

  void backToConsequences() =>
      state = state.copyWith(step: DeleteAccountStep.consequences, error: null);

  void clearError() => state = state.copyWith(error: null);

  /// Emails a 6-digit re-auth code (passwordless / social accounts). A no-op on
  /// the server for password accounts, so it's always safe to offer.
  Future<void> sendCode() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(dioProvider).post<dynamic>(
            '/api/v1/account/delete/send-code',
            options: Options(sendTimeout: _timeout, receiveTimeout: _timeout),
          );
      state = state.copyWith(isLoading: false, codeSent: true);
    } catch (e) {
      appLog.w('[DeleteAccount] send-code failed: $e');
      state = state.copyWith(isLoading: false, error: _message(e));
    }
  }

  /// Re-auths and requests deletion. On success the account is in the grace
  /// window and the step advances to [DeleteAccountStep.scheduled]. Wrong
  /// password (401), a non-empty centre (409 CENTRE_NOT_EMPTY), a parent with
  /// children (409) and rate-limit (429) all land as a persistent inline error.
  Future<void> requestDeletion({String? password, String? code}) async {
    if (state.isLoading) return;
    final hasPassword = password != null && password.isNotEmpty;
    final hasCode = code != null && code.isNotEmpty;
    if (!hasPassword && !hasCode) {
      state = state.copyWith(
          error: 'Enter your password or the emailed code to confirm.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ref.read(dioProvider).post<dynamic>(
            '/api/v1/account/delete',
            data: {
              if (hasPassword) 'password': password,
              if (hasCode) 'code': code,
            },
            options: Options(sendTimeout: _timeout, receiveTimeout: _timeout),
          );
      // Success responses are unwrapped by the client interceptor (res.data is
      // the inner object); read defensively either way.
      final raw = res.data;
      final inner = (raw is Map && raw['data'] is Map)
          ? raw['data'] as Map
          : (raw is Map ? raw : const {});
      final g = inner['graceEndsAt'];
      state = state.copyWith(
        isLoading: false,
        step: DeleteAccountStep.scheduled,
        graceEndsAt: g is String ? DateTime.tryParse(g) : null,
        needsManualCancellation: inner['needsManualCancellation'] == true,
      );
      appLog.i('[DeleteAccount] Scheduled; graceEndsAt=${state.graceEndsAt}');
    } catch (e) {
      appLog.w('[DeleteAccount] request failed: $e');
      state = state.copyWith(isLoading: false, error: _message(e));
    }
  }

  /// Prefer the backend's specific message for the deletion guards (401 wrong
  /// password / bad code; 409 CENTRE_NOT_EMPTY or parent-with-children) — the
  /// generic PallyError mapping is wrong for these (409→"slot locked"). Fall
  /// back to PallyError for offline/timeout/server. The request methods catch
  /// generically (a plain `catch`) and only INSPECT the Dio error type here, so
  /// this layer never catches that error type directly (per the layering guard).
  String _message(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      final backendMsg = body is Map ? body['error'] as String? : null;
      if ((status == 401 || status == 409) &&
          backendMsg != null &&
          backendMsg.isNotEmpty) {
        return backendMsg;
      }
    }
    return PallyError.from(e).userMessage;
  }
}
