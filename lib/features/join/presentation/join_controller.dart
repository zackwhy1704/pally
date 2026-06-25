import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/home/presentation/home_view_model.dart';
import 'package:pally/features/library/presentation/library_view_model.dart';
import 'package:pally/features/groups/presentation/groups_view_model.dart';
import 'package:pally/features/join/data/join_resolve_service.dart';

part 'join_controller.g.dart';

/// Orchestrates the Join surface: resolve a code to a name (for the mandatory
/// confirmation), then commit through the EXISTING backends — class redeem and
/// group join. Never auto-joins; the screen always confirms first.
@riverpod
class JoinController extends _$JoinController {
  @override
  void build() {}

  /// Name a code before joining. Null when it can't be resolved (offline /
  /// unknown code) — the caller falls back to a generic, still-confirmed step.
  Future<ResolvedCode?> resolve(String code) =>
      ref.read(joinResolveServiceProvider).resolve(code);

  /// Redeem a class code. Returns null on success, else a user-facing error.
  Future<String?> joinClass(String code) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post<dynamic>(
        '/api/v1/centre/redeem-class-code',
        data: {'code': code.trim().toUpperCase()},
      );
      // Surface the new class Mochi immediately.
      ref.invalidate(homeViewModelProvider);
      ref.invalidate(libraryViewModelProvider);
      return null;
    } on DioException catch (e) {
      return _error(e, 'Could not join — check the code and try again');
    }
  }

  /// Join a study group by invite code. Returns null on success, else an error.
  Future<String?> joinGroup(String code) async {
    final group = await ref
        .read(groupListViewModelProvider.notifier)
        .join(code.trim().toUpperCase());
    return group == null ? 'Could not join that group — check the code' : null;
  }

  String _error(DioException e, String fallback) {
    final raw = e.response?.data;
    if (raw is Map && raw['error'] != null) return raw['error'].toString();
    return fallback;
  }
}
