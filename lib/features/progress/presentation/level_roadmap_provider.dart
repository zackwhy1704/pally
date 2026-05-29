import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/level_roadmap.dart';

part 'level_roadmap_provider.g.dart';

@riverpod
Future<LevelRoadmap> levelRoadmap(Ref ref) async {
  try {
    final dio = ref.read(dioProvider);
    final res = await dio.get<dynamic>('/api/v1/progress/level-roadmap');
    final data = res.data;
    final body = (data is Map && data['data'] is Map)
        ? Map<String, dynamic>.from(data['data'] as Map)
        : Map<String, dynamic>.from(data as Map);
    return LevelRoadmap.fromJson(body);
  } on DioException catch (e) {
    appLog.w('[Roadmap] /level-roadmap failed: ${e.message}');
    rethrow;
  }
}
