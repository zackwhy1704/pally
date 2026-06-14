import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

part 'family_service.g.dart';

/// Thin wrapper over /api/v1/account/{link-code,claim,family}. The
/// AccountController shipped in a prior milestone; this only exposes the
/// methods the family UI needs and translates Dio errors into a small set
/// of strings the screens can branch on.
@riverpod
FamilyService familyService(Ref ref) =>
    FamilyService(ref.read(dioProvider));

class FamilyLinkCode {
  const FamilyLinkCode({required this.code, required this.expiresAt});
  final String code;
  final String expiresAt;
}

class FamilyError implements Exception {
  const FamilyError(this.kind, this.message);
  final FamilyErrorKind kind;
  final String message;
  @override
  String toString() => message;
}

enum FamilyErrorKind {
  invalid, // 404 — code not found
  expired, // 410 — code expired
  alreadyLinked, // 409 — already linked
  forbidden, // 403/400 — guards
  upgradeRequired, // 402 — child cap reached; the global interceptor opens the paywall
  unknown,
}

class FamilyService {
  FamilyService(this._dio);
  final Dio _dio;

  Future<FamilyLinkCode> issueLinkCode() async {
    final res = await _dio.post<dynamic>('/api/v1/account/link-code');
    final body = _unwrap(res.data);
    return FamilyLinkCode(
      code: body['code'] as String,
      expiresAt: body['expiresAt'] as String,
    );
  }

  /// Claims a child link code. Returns the response body which may include
  /// `consentRequired: true` if the child is 13+ and requires PDPA consent.
  Future<Map<String, dynamic>> claim(String code) async {
    try {
      final res = await _dio
          .post<dynamic>('/api/v1/account/claim', data: {'code': code});
      if (res.data is Map) {
        return Map<String, dynamic>.from(res.data as Map);
      }
      return const {};
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> family() async {
    final res = await _dio.get<dynamic>('/api/v1/account/family');
    return _unwrap(res.data);
  }

  /// Fetch a single child's detailed dashboard for the parent drill-down.
  Future<Map<String, dynamic>> fetchChildDashboard(String childId) async {
    final res = await _dio.get<dynamic>(
        '/api/v1/parent/children/$childId/dashboard');
    return _unwrap(res.data);
  }

  /// Fetch weekly reports for a specific child.
  Future<List<Map<String, dynamic>>> fetchChildReports(
      String childId) async {
    final res =
        await _dio.get<dynamic>('/api/v1/parent/children/$childId/reports');
    final data = _unwrap(res.data);
    return ((data['reports'] as List?) ?? [])
        .whereType<Map>()
        .map((r) => Map<String, dynamic>.from(r))
        .toList();
  }

  /// Assign revision modules to a child.
  Future<void> assignRevision(
    String childId,
    List<String> moduleIds,
    String dueDate,
    String title,
  ) async {
    await _dio.post<dynamic>(
      '/api/v1/parent/children/$childId/assignments',
      data: {
        'moduleIds': moduleIds,
        'dueDate': dueDate,
        'title': title,
      },
    );
  }

  /// Award bonus stars to a child.
  Future<void> awardStars(String childId, int amount, String? note) async {
    await _dio.post<dynamic>(
      '/api/v1/parent/children/$childId/award-stars',
      data: {
        'amount': amount,
        if (note != null) 'note': note,
      },
    );
  }

  /// Set weekly learning goal for a child.
  Future<void> setGoal(
      String childId, int weeklyMinutes, int weeklyModules) async {
    await _dio.put<dynamic>(
      '/api/v1/parent/children/$childId/goal',
      data: {
        'weeklyMinutes': weeklyMinutes,
        'weeklyModules': weeklyModules,
      },
    );
  }

  /// Get the current weekly goal for a child.
  Future<Map<String, dynamic>> getGoal(String childId) async {
    final res =
        await _dio.get<dynamic>('/api/v1/parent/children/$childId/goal');
    return _unwrap(res.data);
  }

  Map<String, dynamic> _unwrap(dynamic data) =>
      (data is Map && data['data'] is Map)
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data as Map);

  FamilyError _mapError(DioException e) {
    final status = e.response?.statusCode;
    String msg = 'Could not link this account';
    final raw = e.response?.data;
    if (raw is Map) {
      final err = raw['error'];
      if (err != null) msg = err.toString();
    }
    appLog.w('[Family] $status — $msg');
    return switch (status) {
      404 => const FamilyError(
          FamilyErrorKind.invalid, 'That code doesn\'t look right. Try again.'),
      410 => const FamilyError(FamilyErrorKind.expired,
          'That code has expired — ask the child for a new one.'),
      409 => const FamilyError(FamilyErrorKind.alreadyLinked,
          'That child is already linked to a parent.'),
      403 => FamilyError(FamilyErrorKind.forbidden, msg),
      400 => FamilyError(FamilyErrorKind.forbidden, msg),
      // Child cap reached — the global Dio interceptor already routes to the
      // paywall on 402 UPGRADE_REQUIRED; the screen suppresses its own toast.
      402 => const FamilyError(FamilyErrorKind.upgradeRequired,
          'A Family plan is needed to link more children.'),
      _ => FamilyError(FamilyErrorKind.unknown, msg),
    };
  }
}
