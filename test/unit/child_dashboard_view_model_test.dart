import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/parent/presentation/child_dashboard_view_model.dart';

class _SuccessDio extends Fake implements Dio {
  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    Object? data,
  }) async {
    final Map<String, dynamic> body = {
      'childName': 'Bob',
      'sessionsThisWeek': 3,
      'minutesThisWeek': 45,
      'xpThisWeek': 120,
      'streakDays': 2,
      'subjects': <dynamic>[],
      'weakAreas': <dynamic>[],
      'modulesCompleted': 2,
      'modulesTotal': 8,
    };
    return Response<T>(
      data: body as T,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }
}

class _FailDio extends Fake implements Dio {
  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    Object? data,
  }) =>
      Future.error(DioException(requestOptions: RequestOptions(path: path)));
}

ProviderContainer _container(Dio dio) => ProviderContainer(
      overrides: [dioProvider.overrideWithValue(dio)],
    );

void main() {
  group('childDashboardProvider', () {
    test('parses response into ChildDashboard', () async {
      final c = _container(_SuccessDio());
      addTearDown(c.dispose);

      final dash = await c.read(childDashboardProvider('c1').future);
      expect(dash.childName, 'Bob');
      expect(dash.sessionsThisWeek, 3);
      expect(dash.minutesThisWeek, 45);
      expect(dash.xpThisWeek, 120);
      expect(dash.streakDays, 2);
      expect(dash.modulesCompleted, 2);
      expect(dash.modulesTotal, 8);
    });

    test('propagates error on Dio failure', () async {
      final c = _container(_FailDio());
      addTearDown(c.dispose);

      await expectLater(
        c.read(childDashboardProvider('c1').future),
        throwsA(isA<DioException>()),
      );
    });
  });
}
