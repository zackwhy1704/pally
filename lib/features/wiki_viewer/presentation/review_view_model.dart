import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/features/wiki_viewer/data/review_service.dart';

part 'review_view_model.g.dart';

@immutable
class ReviewState {
  const ReviewState({
    this.requests = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.isRevoking = false,
    this.lastCreatedUrl,
    this.askedParent = false,
    this.error,
  });

  final List<ReviewRequest> requests;
  final bool isLoading;
  final bool isCreating;
  final bool isRevoking;

  /// URL of the most recently created share link (for Share.share).
  final String? lastCreatedUrl;

  /// True once an "ask my parent" request has succeeded — flips the button
  /// to "Asked ✓ — waiting".
  final bool askedParent;

  /// User-facing error message, if a call failed.
  final String? error;

  /// The first PENDING request, if any — drives the "link active" row.
  ReviewRequest? get pending {
    for (final r in requests) {
      if (r.isPending) return r;
    }
    return null;
  }

  ReviewState copyWith({
    List<ReviewRequest>? requests,
    bool? isLoading,
    bool? isCreating,
    bool? isRevoking,
    Object? lastCreatedUrl = _sentinel,
    bool? askedParent,
    Object? error = _sentinel,
  }) {
    return ReviewState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isRevoking: isRevoking ?? this.isRevoking,
      lastCreatedUrl: lastCreatedUrl == _sentinel
          ? this.lastCreatedUrl
          : lastCreatedUrl as String?,
      askedParent: askedParent ?? this.askedParent,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();

@riverpod
class ReviewViewModel extends _$ReviewViewModel {
  late String _pageId;

  @override
  ReviewState build(String pageId) {
    _pageId = pageId;
    _load();
    return const ReviewState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final requests = await ref.read(reviewServiceProvider).list(_pageId);
      state = state.copyWith(
        requests: requests,
        isLoading: false,
        error: null,
      );
    } catch (_) {
      // Fail soft — listing failures shouldn't block the sheet; the user can
      // still create a link. Keep any existing requests.
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refresh() => _load();

  /// Creates a share link (notifyParent:false). Returns the URL on success,
  /// or null on failure (with [ReviewState.error] set).
  Future<String?> createShareLink() async {
    if (state.isCreating) return null;
    state = state.copyWith(isCreating: true, error: null);
    try {
      final link = await ref
          .read(reviewServiceProvider)
          .createRequest(_pageId, notifyParent: false);
      state = state.copyWith(isCreating: false, lastCreatedUrl: link.url);
      await _load();
      return link.url;
    } on ReviewException catch (e) {
      state = state.copyWith(isCreating: false, error: e.message);
      return null;
    } catch (_) {
      state = state.copyWith(
          isCreating: false, error: "Couldn't create a review link.");
      return null;
    }
  }

  /// Asks the linked parent to review (notifyParent:true). Flips
  /// [ReviewState.askedParent] true on success.
  Future<void> askParent() async {
    if (state.isCreating || state.askedParent) return;
    state = state.copyWith(isCreating: true, error: null);
    try {
      await ref
          .read(reviewServiceProvider)
          .createRequest(_pageId, notifyParent: true);
      state = state.copyWith(isCreating: false, askedParent: true);
      await _load();
    } on ReviewException catch (e) {
      state = state.copyWith(isCreating: false, error: e.message);
    } catch (_) {
      state =
          state.copyWith(isCreating: false, error: "Couldn't ask your parent.");
    }
  }

  /// Revokes a pending review request.
  Future<void> revoke(String requestId) async {
    if (state.isRevoking) return;
    state = state.copyWith(isRevoking: true, error: null);
    try {
      await ref.read(reviewServiceProvider).revoke(_pageId, requestId);
      state = state.copyWith(
        isRevoking: false,
        requests: state.requests.where((r) => r.id != requestId).toList(),
      );
    } catch (_) {
      state =
          state.copyWith(isRevoking: false, error: "Couldn't close the link.");
    }
  }
}
