import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/shared/models/referral.dart';

part 'referral_service.g.dart';

@riverpod
ReferralService referralService(Ref ref) =>
    ReferralService(ref.read(dioProvider));

@riverpod
Future<ReferralSummary> referralSummary(Ref ref) =>
    ref.read(referralServiceProvider).me();

@riverpod
Future<List<ReferralRedemption>> referralRedemptions(Ref ref) =>
    ref.read(referralServiceProvider).redemptions();

class ReferralService {
  ReferralService(this._dio);
  final Dio _dio;

  Future<ReferralSummary> me() async {
    final res = await _dio.get<dynamic>('/api/v1/referral/me');
    return ReferralSummary.fromJson(_unwrap(res.data));
  }

  Future<List<ReferralRedemption>> redemptions() async {
    final res = await _dio.get<dynamic>('/api/v1/referral/redemptions');
    final body = _unwrap(res.data);
    final rows = (body['redemptions'] as List?) ?? const [];
    return rows
        .map((r) => ReferralRedemption.fromJson(
            Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  /// Returns null on success; a friendly error string on failure. Never
  /// throws — used both at signup (where the user might be skipping the
  /// field) and from Settings.
  Future<String?> redeem(String code) async {
    try {
      await _dio.post<dynamic>('/api/v1/referral/redeem',
          data: {'code': code.trim().toUpperCase()});
      return null;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      String msg = 'Code not accepted';
      final raw = e.response?.data;
      if (raw is Map) {
        final err = raw['error'];
        if (err != null) msg = err.toString();
      }
      appLog.w('[Referral] redeem failed status=$status msg=$msg');
      return msg;
    }
  }

  Map<String, dynamic> _unwrap(dynamic data) =>
      (data is Map && data['data'] is Map)
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data as Map);
}
