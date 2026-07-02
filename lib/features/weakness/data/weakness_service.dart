import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/weakness/data/weakness_focus.dart';

/// Fetches the student's own weakness focus for a backend subject enum
/// (e.g. "MATHS"). Returns [WeaknessFocus.empty] on any error so the card
/// simply doesn't render — this is a nice-to-have surface, never a blocker.
final weaknessFocusProvider =
    FutureProvider.family<WeaknessFocus, String>((ref, backendSubject) async {
  try {
    final dio = ref.read(dioProvider);
    // The ApiResponse interceptor unwraps the envelope → data is the inner map.
    final res = await dio.get<dynamic>(
      '/api/v1/weakness/focus',
      queryParameters: {'subject': backendSubject},
    );
    final body = res.data;
    if (body is Map) return WeaknessFocus.fromJson(body.cast<String, dynamic>());
    return WeaknessFocus.empty;
  } catch (e) {
    appLog.d('[Weakness] focus fetch failed (non-fatal): $e');
    return WeaknessFocus.empty;
  }
});
