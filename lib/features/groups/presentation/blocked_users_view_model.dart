import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pally/app/api_client.dart';

part 'blocked_users_view_model.g.dart';

/// A user this student has blocked.
class BlockedUser {
  const BlockedUser({required this.userId, required this.displayName});
  final String userId;
  final String displayName;
}

/// Owns the network for the "Blocked people" screen.
///
/// Data access lives here, not in the widget: screens render state, they do not
/// fetch (enforced by `test/guard/layering_guard_test.dart`).
///
/// The list is read from the SERVER rather than cached locally — blocking is
/// server-enforced, so the server is the only honest source of who is blocked.
@riverpod
class BlockedUsersVm extends _$BlockedUsersVm {
  bool _pending = false;

  @override
  Future<List<BlockedUser>> build() => _fetch();

  Future<List<BlockedUser>> _fetch() async {
    final dio = ref.read(dioProvider);
    final res = await dio.get<dynamic>('/api/v1/blocks');
    final body = res.data;
    final data = (body is Map<String, dynamic> ? body['data'] : null) as List? ??
        const <dynamic>[];
    return data
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map((m) => BlockedUser(
              userId: (m['userId'] as String?) ?? '',
              displayName: (m['displayName'] as String?) ?? 'Member',
            ))
        .toList();
  }

  /// Unblocks and refetches. Guideline 1.2 expects blocking to be reversible.
  Future<void> unblock(String userId) async {
    if (_pending) return; // re-entry guard
    _pending = true;
    try {
      final dio = ref.read(dioProvider);
      await dio.delete<dynamic>(
        '/api/v1/blocks/$userId',
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      state = await AsyncValue.guard(_fetch);
    } finally {
      _pending = false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
