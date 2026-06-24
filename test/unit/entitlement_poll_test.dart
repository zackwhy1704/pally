import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';

/// Fake Dio whose GET /entitlement reports free for the first [premiumAfter]-1
/// calls, then premium — simulating the RevenueCat webhook landing on the
/// backend a few polls after a successful purchase.
class _SeqDio extends Fake implements Dio {
  _SeqDio(this.premiumAfter);
  final int premiumAfter;
  int calls = 0;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    calls++;
    final premium = calls >= premiumAfter;
    return Response<T>(
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
      data: <String, dynamic>{
        'isPremium': premium,
        'source': premium ? 'IAP' : 'NONE',
      } as T,
    );
  }
}

ProviderContainer _container(Dio dio) =>
    ProviderContainer(overrides: [dioProvider.overrideWithValue(dio)]);

void main() {
  group('EntitlementVm.pollUntilPremium', () {
    test('returns true and flips state once the backend reports premium',
        () async {
      // build() does the 1st fetch (free); the 1st poll is the 2nd call → premium.
      final c = _container(_SeqDio(2));
      addTearDown(c.dispose);
      // Hold a listener so the autoDispose provider isn't torn down between reads.
      c.listen(entitlementVmProvider, (_, __) {});
      await c.read(entitlementVmProvider.future);

      final ok = await c.read(entitlementVmProvider.notifier).pollUntilPremium(
            timeout: const Duration(seconds: 2),
            interval: const Duration(milliseconds: 5),
          );

      expect(ok, isTrue);
      expect(c.read(entitlementVmProvider).value?.isPremium, isTrue);
    });

    test('returns false (bounded) and stays free when the webhook never lands',
        () async {
      final c = _container(_SeqDio(9999));
      addTearDown(c.dispose);
      c.listen(entitlementVmProvider, (_, __) {});
      await c.read(entitlementVmProvider.future);

      final ok = await c.read(entitlementVmProvider.notifier).pollUntilPremium(
            timeout: const Duration(milliseconds: 40),
            interval: const Duration(milliseconds: 5),
          );

      expect(ok, isFalse);
      expect(c.read(entitlementVmProvider).value?.isPremium, isFalse);
    });
  });
}
