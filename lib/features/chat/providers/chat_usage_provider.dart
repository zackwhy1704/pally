import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/utils/logger.dart';

part 'chat_usage_provider.g.dart';

@immutable
class ChatUsage {
  const ChatUsage({
    required this.isPremium,
    required this.used,
    required this.limit,
  });

  /// Premium → no cap, never warn. {@code limit} is null in that case.
  final bool isPremium;
  final int used;
  final int? limit;

  int? get remaining =>
      limit == null ? null : (limit! - used).clamp(0, limit!);

  /// "Almost out" threshold — surfaces the hint when this many chats or
  /// fewer remain. Tuned so the kid sees it twice (5, then 2) before the
  /// wall, never as a sudden surprise.
  bool get shouldWarn {
    if (isPremium || limit == null) return false;
    return remaining! <= 5;
  }
}

/// Polls the backend's /usage/today endpoint. Best-effort: a failure leaves
/// state null and the chat just doesn't show the hint — never an error.
@riverpod
class ChatUsageNotifier extends _$ChatUsageNotifier {
  @override
  ChatUsage? build() {
    Future.microtask(refresh);
    return null;
  }

  Future<void> refresh() async {
    try {
      final dio = ref.read(dioProvider);
      final response =
          await dio.get<Map<String, dynamic>>('/api/v1/usage/today');
      final data = response.data;
      if (data == null) return;
      state = ChatUsage(
        isPremium: (data['isPremium'] as bool?) ?? false,
        used: (data['chatUsed'] as int?) ?? 0,
        limit: data['chatLimit'] as int?,
      );
    } catch (e) {
      // Quota hint is purely additive UX. Log and stay silent so the chat
      // continues to work as normal even if /usage/today is flaky.
      appLog.d('[ChatUsage] refresh failed: ${PallyError.from(e).userMessage}');
    }
  }

  /// Optimistically decrements the counter so the kid sees the warning
  /// land immediately after a send, before /usage/today catches up.
  void recordSent() {
    final current = state;
    if (current == null || current.isPremium) return;
    state = ChatUsage(
      isPremium: current.isPremium,
      used: current.used + 1,
      limit: current.limit,
    );
  }
}
