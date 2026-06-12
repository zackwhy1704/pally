import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/json_reader.dart';

part 'review_service.g.dart';

/// A pending/closed review request on a wiki page, as returned by
/// GET /api/v1/wiki-pages/{pageId}/review-requests.
class ReviewRequest {
  const ReviewRequest({
    required this.id,
    required this.status,
    this.reviewerName,
    this.createdAt,
    this.reviewedAt,
    this.expiresAt,
  });

  final String id;
  final String status; // PENDING | COMPLETED | EXPIRED | REVOKED
  final String? reviewerName;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final DateTime? expiresAt;

  bool get isPending => status.toUpperCase() == 'PENDING';

  /// Days remaining before [expiresAt], floored at 0. Null when no expiry.
  int? get daysUntilExpiry {
    final e = expiresAt;
    if (e == null) return null;
    final diff = e.difference(DateTime.now()).inHours / 24.0;
    return diff <= 0 ? 0 : diff.ceil();
  }

  factory ReviewRequest.fromJson(Map<String, dynamic> json) => ReviewRequest(
        // id is load-bearing — the revoke call needs it. Required.
        id: json.require<String>('id'),
        // status drives the whole pending/active UI. Required.
        status: json.require<String>('status'),
        reviewerName: json['reviewerName'] as String?,
        createdAt: _parseDate(json['createdAt']),
        reviewedAt: _parseDate(json['reviewedAt']),
        expiresAt: _parseDate(json['expiresAt']),
      );

  static DateTime? _parseDate(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}

/// Result of creating a review request.
class ReviewLink {
  const ReviewLink({
    required this.token,
    required this.url,
    this.expiresAt,
  });

  final String token;
  final String url;
  final DateTime? expiresAt;

  factory ReviewLink.fromJson(Map<String, dynamic> json) => ReviewLink(
        token: json.optional<String>('token', ''),
        // url is the whole point of a share link — required.
        url: json.require<String>('url'),
        expiresAt: ReviewRequest._parseDate(json['expiresAt']),
      );
}

/// Why a create-review-request call failed, so the UI can branch.
enum ReviewErrorKind {
  tooMany, // 409 — already 3 pending requests
  rateLimited, // 429 — over the daily cap
  unknown,
}

class ReviewException implements Exception {
  const ReviewException(this.kind, this.message);
  final ReviewErrorKind kind;
  final String message;
  @override
  String toString() => message;
}

@riverpod
ReviewService reviewService(Ref ref) => ReviewService(ref.read(dioProvider));

/// Thin wrapper over the wiki-page review-request endpoints.
class ReviewService {
  ReviewService(this._dio);
  final Dio _dio;

  /// Creates a review request. [notifyParent] true means "ask my parent"
  /// (push notification to the linked parent); false means a plain share link.
  Future<ReviewLink> createRequest(String pageId,
      {required bool notifyParent}) async {
    try {
      final res = await _dio.post<dynamic>(
        '/api/v1/wiki-pages/$pageId/review-request',
        data: {'notifyParent': notifyParent},
      );
      return ReviewLink.fromJson(_unwrap(res.data));
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Revokes a review request (invalidates the share link).
  Future<void> revoke(String pageId, String requestId) async {
    await _dio.delete<dynamic>(
      '/api/v1/wiki-pages/$pageId/review-request/$requestId',
    );
  }

  /// Lists all review requests for a page (pending + historical).
  Future<List<ReviewRequest>> list(String pageId) async {
    final res = await _dio.get<dynamic>(
      '/api/v1/wiki-pages/$pageId/review-requests',
    );
    final data = res.data;
    final List<dynamic> raw = data is List
        ? data
        : (data is Map && data['data'] is List
            ? data['data'] as List<dynamic>
            : const <dynamic>[]);
    return raw
        .whereType<Map>()
        .map((e) => ReviewRequest.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Map<String, dynamic> _unwrap(dynamic data) =>
      (data is Map && data['data'] is Map)
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data as Map);

  ReviewException _mapError(DioException e) {
    final status = e.response?.statusCode;
    return switch (status) {
      409 => const ReviewException(ReviewErrorKind.tooMany,
          'You already have 3 review links open. Close one first.'),
      429 => const ReviewException(ReviewErrorKind.rateLimited,
          "That's enough review links for today — try again tomorrow."),
      _ => const ReviewException(
          ReviewErrorKind.unknown, "Couldn't create a review link — try again."),
    };
  }
}
