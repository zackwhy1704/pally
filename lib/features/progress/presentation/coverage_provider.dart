import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/coverage_summary.dart';

part 'coverage_provider.g.dart';

@riverpod
Future<CoverageSummary> coverage(Ref ref) async {
  try {
    final dio = ref.read(dioProvider);
    final res = await dio.get<dynamic>('/api/v1/progress/coverage');
    final data = res.data;
    final body = (data is Map && data['data'] is Map)
        ? Map<String, dynamic>.from(data['data'] as Map)
        : Map<String, dynamic>.from(data as Map);
    return CoverageSummary.fromJson(body);
  } on DioException catch (e) {
    appLog.w('[Coverage] /coverage failed: ${e.message}');
    rethrow;
  }
}
