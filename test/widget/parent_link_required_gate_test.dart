import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/app/api_client.dart';

/// A Dio adapter that always returns a 403 with a PARENT_LINK_REQUIRED body,
/// mirroring the backend's under-13 gate response.
class _ParentLinkAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"data":{"code":"PARENT_LINK_REQUIRED","reason":"under-13 no parent"}}',
      403,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  testWidgets(
      '403 PARENT_LINK_REQUIRED routes the child to /auth/setup (declare age)',
      (tester) async {
    // Server-side, PARENT_LINK_REQUIRED is raised ONLY for an unknown birth year
    // (AGE_DECLARATION_REQUIRED) — so the fix is to finish account setup, not to
    // nag a parent. The old /family/link-code route never existed (it dead-ended
    // on the error screen); the interceptor now routes to the registered
    // /auth/setup. See route_references_exist_test for the guard that caught it.
    final navKey = GlobalKey<NavigatorState>();

    final router = GoRouter(
      navigatorKey: navKey,
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/auth/setup',
          // Lightweight stand-in for the real setup screen — we only assert the
          // interceptor *navigates here*.
          builder: (_, __) => const Scaffold(body: Text('Account setup')),
        ),
      ],
    );

    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          globalNavigatorKeyProvider.overrideWithValue(navKey),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return MaterialApp.router(routerConfig: router);
          },
        ),
      ),
    );
    await tester.pump();

    // Swap the Dio's adapter so the gated request returns the 403 gate.
    final dio = container.read(dioProvider);
    dio.httpClientAdapter = _ParentLinkAdapter();

    // Dio interceptors run on the real event loop, which the testWidgets
    // FakeAsync zone does not auto-advance — drive the request inside
    // runAsync so the interceptor chain (and its navigation push) completes.
    final caught = await tester.runAsync(() async {
      try {
        await dio.post<dynamic>('/api/v1/avatars/abc/chat');
        return null;
      } catch (e) {
        return e;
      }
    });
    expect(caught, isA<DioException>());

    // Let the post-frame navigation + toast run (bounded pumps; the toast's
    // auto-dismiss Timer is drained so no timer is pending at teardown).
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    // The child landed on the account-setup screen as a blocking step.
    expect(find.text('Account setup'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });
}
