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

  Future<void> claim(String code) async {
    try {
      await _dio.post<dynamic>('/api/v1/account/claim', data: {'code': code});
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> family() async {
    final res = await _dio.get<dynamic>('/api/v1/account/family');
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
      _ => FamilyError(FamilyErrorKind.unknown, msg),
    };
  }
}
