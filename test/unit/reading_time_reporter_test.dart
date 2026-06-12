import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/progress/data/reading_time_reporter.dart';

/// Captures the last POST so we can assert the body the reporter sends.
class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;
  Object? lastData;
  int callCount = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    callCount++;
    lastRequest = options;
    lastData = options.data;
    return ResponseBody.fromString('{}', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }
}

void main() {
  late Dio dio;
  late _CapturingAdapter adapter;
  late ReadingTimeReporter reporter;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    adapter = _CapturingAdapter();
    dio.httpClientAdapter = adapter;
    reporter = ReadingTimeReporter(dio);
  });

  test('reports a normal session with the avatarId and durationSeconds',
      () async {
    await reporter.report(avatarId: 'av1', durationSeconds: 120);

    expect(adapter.callCount, 1);
    expect(adapter.lastRequest?.path, '/api/v1/progress/reading');
    final data = adapter.lastData as Map<String, dynamic>;
    expect(data['avatarId'], 'av1');
    expect(data['durationSeconds'], 120);
  });

  test('drops trivially short sessions below the minimum', () async {
    await reporter.report(avatarId: 'av1', durationSeconds: 3);
    expect(adapter.callCount, 0, reason: 'short sessions must not be sent');
  });

  test('clamps an absurdly long session to the client cap', () async {
    await reporter.report(avatarId: 'av1', durationSeconds: 999999);

    expect(adapter.callCount, 1);
    final data = adapter.lastData as Map<String, dynamic>;
    expect(data['durationSeconds'], ReadingTimeReporter.maxReportSeconds);
  });

  test('a network failure is swallowed (best-effort metric)', () async {
    dio.httpClientAdapter = _ThrowingAdapter();
    final r = ReadingTimeReporter(dio);
    // Must not throw even though the POST fails.
    await r.report(avatarId: 'av1', durationSeconds: 60);
  });
}

class _ThrowingAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    throw DioException(requestOptions: options);
  }
}
