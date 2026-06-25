import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

part 'join_resolve_service.g.dart';

@riverpod
JoinResolveService joinResolveService(Ref ref) =>
    JoinResolveService(ref.read(dioProvider));

/// What a code resolves to, server-side, with no commit. `context` is the centre
/// name for a class, else null.
class ResolvedCode {
  const ResolvedCode({
    required this.type,
    required this.code,
    required this.name,
    this.context,
  });

  final String type; // CLASS | GROUP
  final String code;
  final String name;
  final String? context;

  factory ResolvedCode.fromJson(Map<String, dynamic> json) => ResolvedCode(
        type: (json['type'] ?? '').toString(),
        code: (json['code'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        context: json['context']?.toString(),
      );
}

/// Names what a code joins (class/group) BEFORE any commit, powering the Join
/// surface's confirmation. Never throws — returns null when a code can't be
/// resolved (unknown code, offline) so the caller can fall back to a generic,
/// still-confirmed step rather than break.
class JoinResolveService {
  JoinResolveService(this._dio);

  final Dio _dio;

  Future<ResolvedCode?> resolve(String code) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/join/resolve-code/${Uri.encodeComponent(code.trim().toUpperCase())}',
      );
      final raw = res.data;
      final data = (raw is Map && raw['data'] is Map)
          ? Map<String, dynamic>.from(raw['data'] as Map)
          : Map<String, dynamic>.from(raw as Map);
      return ResolvedCode.fromJson(data);
    } on DioException catch (e) {
      appLog.w('[Join] resolve-code failed status=${e.response?.statusCode}');
      return null;
    }
  }
}
