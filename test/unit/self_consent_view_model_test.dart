import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/auth/screens/self_consent_view_model.dart';

class _OkDio extends Fake implements Dio {
  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async =>
      Response<T>(
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
}

class _FailDio extends Fake implements Dio {
  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      Future.error(DioException(
        requestOptions: RequestOptions(path: path),
      ));
}

ProviderContainer _container(Dio dio) => ProviderContainer(
      overrides: [dioProvider.overrideWithValue(dio)],
    );

void main() {
  group('SelfConsentViewModel', () {
    test('initial state is AsyncData(null) — not loading', () {
      final c = _container(_OkDio());
      addTearDown(c.dispose);
      expect(c.read(selfConsentViewModelProvider), const AsyncData<void>(null));
    });

    test('submitConsent transitions loading → data on success', () async {
      final c = _container(_OkDio());
      addTearDown(c.dispose);
      final notifier = c.read(selfConsentViewModelProvider.notifier);

      final future = notifier.submitConsent();
      expect(c.read(selfConsentViewModelProvider).isLoading, isTrue);

      await future;
      expect(c.read(selfConsentViewModelProvider), isA<AsyncData<void>>());
    });

    test('submitConsent always resolves to data even when Dio throws', () async {
      final c = _container(_FailDio());
      addTearDown(c.dispose);
      await c.read(selfConsentViewModelProvider.notifier).submitConsent();
      expect(c.read(selfConsentViewModelProvider), isA<AsyncData<void>>());
    });
  });
}
