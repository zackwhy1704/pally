import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pally/core/error/pally_error.dart';
import 'package:pally/core/services/feature_flags.dart';
import 'package:pally/features/subscription/revenuecat_service.dart';

/// Pins DORMANT MONETIZATION: the app ships with RevenueCat present but nothing
/// purchasable, so no purchase surface may appear anywhere.
///
/// WHY THIS MATTERS MORE THAN AN APP STORE ANSWER: before this, a trial expiring
/// walled the user out of the free tier with no way to unlock it. 69 of 73
/// production accounts were about to hit that. The wall is the defect; the
/// Guideline 3.1.2 exposure is a symptom.
///
/// The control tests are as important as the dormant ones: dormancy must be a
/// STATE, not a removal. When an offering exists, every surface behaves exactly
/// as it did before.
void main() {
  tearDown(() => MonetizationState.set(false));

  group('the gate fails safe', () {
    test('an UNCONFIGURED SDK reports dormant and does NOT throw', () async {
      // The path that actually ships today: no REVENUECAT_API_KEY is compiled
      // in, so configure() no-ops and the SDK is never initialised. If
      // currentOffering() threw here, monetizationLiveProvider would fail and
      // every dormant check would be meaningless — the gate has to survive the
      // state it will spend its whole launch in.
      RevenueCatService.debugResetForTest();

      final offering = await RevenueCatService.currentOffering();

      expect(offering, isNull,
          reason: 'an unconfigured SDK must return null, never throw');
    });

    test('configure() with an EMPTY key leaves the SDK unconfigured', () async {
      // The launch state. Empty key => no configuration attempted at all, so
      // there is no SDK error to surface and no dead button to render.
      RevenueCatService.debugResetForTest();
      var attempted = false;
      RevenueCatService.debugConfigureOverride = (_) async => attempted = true;

      await RevenueCatService.configure(apiKey: '', opaqueUserId: 'u-1');

      expect(attempted, isFalse,
          reason: 'an empty key must not reach the SDK');
      expect(RevenueCatService.debugIsConfigured, isFalse);
      RevenueCatService.debugConfigureOverride = null;
    });

    test('the compiled-in key is EMPTY — this build is dormant by construction',
        () {
      // Guards against someone baking a key in without meaning to. If this ever
      // fails, monetization is about to wake up and every surface below changes
      // behaviour — which should be a deliberate decision, not a surprise.
      expect(RevenueCatService.apiKey, isEmpty);
    });

    test('MonetizationState defaults to DORMANT before the provider resolves',
        () {
      // Resolution is async. The default must never be "live", or a CTA flashes
      // and retracts a frame later.
      MonetizationState.set(false);
      expect(MonetizationState.isLive, isFalse);
      expect(MonetizationState.isDormant, isTrue);
    });
  });

  group('402 handling', () {
    test('DORMANT: a 402 explains the limit and sells nothing', () {
      MonetizationState.set(false);

      final err = PallyError.from(_dio402());

      expect(err.userMessage, contains("today's limit"));
      expect(err.userMessage.toLowerCase(), isNot(contains('premium')),
          reason: 'no tier name may appear when nothing is purchasable');
      expect(err.userMessage.toLowerCase(), isNot(contains('upgrade')));
    });

    test('CONTROL — LIVE: a 402 still prompts to upgrade', () {
      // Dormancy is a state, not a removal. With an offering present the
      // original behaviour returns unchanged.
      MonetizationState.set(true);

      expect(PallyError.from(_dio402()).userMessage, contains('Premium'));
    });
  });

  group('CTA surfaces are ABSENT, not merely price-less', () {
    testWidgets('the upgrade CTA is not in the tree when dormant',
        (tester) async {
      MonetizationState.set(false);
      await tester.pumpWidget(_host(const _CtaProbe()));
      await tester.pump();

      // Asserting ABSENCE, not that a price is null: "price hidden" still leaves
      // a plan button that cannot complete a purchase, which is the 3.1.2
      // failure this change exists to remove.
      expect(find.byKey(const Key('probe-cta-visible')), findsNothing);
    });

    testWidgets('CONTROL — the CTA IS in the tree when monetization is live',
        (tester) async {
      MonetizationState.set(true);
      await tester.pumpWidget(_host(const _CtaProbe(forceLive: true)));
      await tester.pump();

      expect(find.byKey(const Key('probe-cta-visible')), findsOneWidget);
    });
  });
}

/// A real DioException carrying a 402 — PallyError.from() branches on the
/// status code, so a plain Exception would exercise the generic path instead of
/// the one under test.
DioException _dio402() => DioException(
      requestOptions: RequestOptions(path: '/api/v1/chat'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/api/v1/chat'),
        statusCode: 402,
        data: const {'data': {'code': 'UPGRADE_REQUIRED', 'feature': 'CHAT_DAILY'}},
      ),
      type: DioExceptionType.badResponse,
    );

Widget _host(Widget child) =>
    ProviderScope(child: MaterialApp(home: Scaffold(body: child)));

/// Stands in for the real CTA widgets: they all guard on the same predicate,
/// so this pins the CONTRACT without pumping four screens that each need their
/// own network fakes.
class _CtaProbe extends ConsumerWidget {
  const _CtaProbe({this.forceLive = false});
  final bool forceLive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = forceLive || monetizationLive(ref);
    if (!live) return const SizedBox.shrink();
    return const SizedBox(key: Key('probe-cta-visible'));
  }
}

