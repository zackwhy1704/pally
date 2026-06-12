import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/utils/json_reader.dart';
import 'package:pally/features/wiki_viewer/data/review_service.dart';
import 'package:pally/features/wiki_viewer/presentation/review_view_model.dart';
import 'package:pally/shared/models/wiki_page.dart';

void main() {
  group('WikiPage.reviewState parsing (PART 1)', () {
    WikiPage parse(Map<String, dynamic> extra) => WikiPage.fromJson({
          'id': 'p1',
          'avatarId': 'a1',
          'title': 'T',
          'content': 'C',
          ...extra,
        });

    test('parses each known reviewState value', () {
      expect(parse({'reviewState': 'FLAGGED'}).reviewState,
          WikiReviewState.flagged);
      expect(parse({'reviewState': 'VERIFIED'}).reviewState,
          WikiReviewState.verified);
      expect(parse({'reviewState': 'LOW_CONFIDENCE'}).reviewState,
          WikiReviewState.lowConfidence);
      expect(parse({'reviewState': 'UNVERIFIED'}).reviewState,
          WikiReviewState.unverified);
    });

    test('missing reviewState defaults to UNVERIFIED (null-tolerant)', () {
      expect(parse({}).reviewState, WikiReviewState.unverified);
    });

    test('unknown / null reviewState falls back to UNVERIFIED, never throws',
        () {
      expect(parse({'reviewState': 'SOMETHING_NEW'}).reviewState,
          WikiReviewState.unverified);
      expect(parse({'reviewState': null}).reviewState,
          WikiReviewState.unverified);
    });

    test('verifiedBy and flagNote are captured when present and null when not',
        () {
      final flagged = parse({
        'reviewState': 'FLAGGED',
        'verifiedBy': 'Mum',
        'flagNote': 'Check the dates',
      });
      expect(flagged.verifiedBy, 'Mum');
      expect(flagged.flagNote, 'Check the dates');

      final plain = parse({});
      expect(plain.verifiedBy, isNull);
      expect(plain.flagNote, isNull);
    });
  });

  group('ReviewRequest parsing (PART 2)', () {
    test('parses fields and computes daysUntilExpiry from the future', () {
      final expires = DateTime.now()
          .add(const Duration(days: 5, hours: 12))
          .toIso8601String();
      final r = ReviewRequest.fromJson({
        'id': 'rr1',
        'status': 'PENDING',
        'reviewerName': 'Dad',
        'expiresAt': expires,
      });
      expect(r.id, 'rr1');
      expect(r.isPending, isTrue);
      expect(r.reviewerName, 'Dad');
      // 5.5 days remaining ceils to 6.
      expect(r.daysUntilExpiry, 6);
    });

    test('expired request floors days at 0', () {
      final r = ReviewRequest.fromJson({
        'id': 'rr2',
        'status': 'EXPIRED',
        'expiresAt':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      });
      expect(r.isPending, isFalse);
      expect(r.daysUntilExpiry, 0);
    });

    test('missing required id throws (broken contract surfaces, PART 16)', () {
      expect(
        () => ReviewRequest.fromJson({'status': 'PENDING'}),
        throwsA(isA<JsonParseException>()),
      );
    });

    test('null expiresAt yields null daysUntilExpiry', () {
      final r = ReviewRequest.fromJson({'id': 'x', 'status': 'PENDING'});
      expect(r.daysUntilExpiry, isNull);
    });
  });

  group('ReviewLink parsing (PART 2)', () {
    test('requires url, tolerates missing token', () {
      final link = ReviewLink.fromJson({'url': 'https://x/y'});
      expect(link.url, 'https://x/y');
      expect(link.token, '');
    });

    test('missing url throws', () {
      expect(() => ReviewLink.fromJson({'token': 't'}),
          throwsA(isA<JsonParseException>()));
    });
  });

  group('ReviewService error mapping (PART 2)', () {
    Future<ReviewException> run(int status) async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:1'));
      dio.httpClientAdapter = _StatusAdapter(status);
      final svc = ReviewService(dio);
      try {
        await svc.createRequest('p1', notifyParent: false);
        fail('expected ReviewException');
      } on ReviewException catch (e) {
        return e;
      }
    }

    test('409 maps to tooMany', () async {
      expect((await run(409)).kind, ReviewErrorKind.tooMany);
    });
    test('429 maps to rateLimited', () async {
      expect((await run(429)).kind, ReviewErrorKind.rateLimited);
    });
    test('other statuses map to unknown', () async {
      expect((await run(500)).kind, ReviewErrorKind.unknown);
    });
  });

  group('ReviewState.pending (PART 2)', () {
    test('returns the first PENDING request, ignoring closed ones', () {
      const state = ReviewState(requests: [
        ReviewRequest(id: 'a', status: 'EXPIRED'),
        ReviewRequest(id: 'b', status: 'PENDING'),
        ReviewRequest(id: 'c', status: 'PENDING'),
      ]);
      expect(state.pending?.id, 'b');
    });

    test('returns null when nothing is pending', () {
      const state = ReviewState(requests: [
        ReviewRequest(id: 'a', status: 'COMPLETED'),
      ]);
      expect(state.pending, isNull);
    });
  });
}

/// A Dio adapter that always throws a DioException carrying [status], so the
/// service's DioException → ReviewException mapping can be exercised.
class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.status);
  final int status;
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    throw DioException(
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: status),
    );
  }
}
