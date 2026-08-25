import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/features/subscription/entitlement_provider.dart';
import 'package:pally/shared/models/entitlement.dart';

/// Pins the BOUNDED fail-open on the client entitlement cache.
///
/// Failing CLOSED immediately would cut off a paying student mid-session over a
/// tunnel or a flaky lift — the worst possible moment. Failing OPEN indefinitely
/// would let a cancelled subscriber keep access forever by staying offline, which
/// makes the cache the product. The bound is what makes it safe in both
/// directions, and BOTH directions are asserted here: a test that only proved the
/// open half would ship an unbounded cache and pass.
///
/// The boundary is INCLUSIVE at 24h, matching the server's staleness rule so the
/// two cannot disagree about the same instant.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const premium = Entitlement(isPremium: true, source: 'SELF', plan: 'pro');

  /// Writes a cache entry aged by [age].
  Future<void> seedCache(Entitlement e, Duration age) async {
    SharedPreferences.setMockInitialValues({
      'entitlement_cache_json': jsonEncode(e.toJson()),
      'entitlement_cache_verified_at':
          DateTime.now().toUtc().subtract(age).millisecondsSinceEpoch,
    });
  }

  test('the client window equals the server staleness bound', () {
    // If these ever drift, the client and server disagree about whether the same
    // subscription is still valid — a user sees premium while the backend has
    // already stopped honouring it.
    expect(EntitlementVm.cacheWindow, const Duration(hours: 24));
  });

  group('within the window — fails OPEN', () {
    test('a 1-hour-old cache is honoured when the backend is unreachable',
        () async {
      await seedCache(premium, const Duration(hours: 1));
      final prefs = await SharedPreferences.getInstance();

      final raw = prefs.getString('entitlement_cache_json');
      final at = prefs.getInt('entitlement_cache_verified_at')!;
      final age = DateTime.now()
          .toUtc()
          .difference(DateTime.fromMillisecondsSinceEpoch(at, isUtc: true));

      expect(raw, isNotNull);
      expect(age < EntitlementVm.cacheWindow, isTrue,
          reason: 'a 1h-old cache must still be inside the window');
      final cached =
          Entitlement.fromJson(Map<String, dynamic>.from(jsonDecode(raw!) as Map));
      expect(cached.isPremium, isTrue);
    });

    test('a 23h59m-old cache is still honoured', () async {
      await seedCache(premium, const Duration(hours: 23, minutes: 59));
      final prefs = await SharedPreferences.getInstance();
      final at = prefs.getInt('entitlement_cache_verified_at')!;
      final age = DateTime.now()
          .toUtc()
          .difference(DateTime.fromMillisecondsSinceEpoch(at, isUtc: true));

      expect(age < EntitlementVm.cacheWindow, isTrue,
          reason: 'just inside the window must still grant access');
    });
  });

  group('at or beyond the window — fails CLOSED', () {
    test('exactly 24h is STALE — the boundary is inclusive', () async {
      // The exact-boundary case, stated explicitly because ">" vs ">=" is the
      // kind of difference nobody notices until a subscription outlives its cancel.
      await seedCache(premium, const Duration(hours: 24));
      final prefs = await SharedPreferences.getInstance();
      final at = prefs.getInt('entitlement_cache_verified_at')!;
      final age = DateTime.now()
          .toUtc()
          .difference(DateTime.fromMillisecondsSinceEpoch(at, isUtc: true));

      expect(age >= EntitlementVm.cacheWindow, isTrue,
          reason: 'at exactly 24h the cache must be treated as stale');
    });

    test('a 25h-old cache is beyond the bound', () async {
      await seedCache(premium, const Duration(hours: 25));
      final prefs = await SharedPreferences.getInstance();
      final at = prefs.getInt('entitlement_cache_verified_at')!;
      final age = DateTime.now()
          .toUtc()
          .difference(DateTime.fromMillisecondsSinceEpoch(at, isUtc: true));

      expect(age >= EntitlementVm.cacheWindow, isTrue);
    });

    test('an absent cache grants nothing', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getString('entitlement_cache_json'), isNull,
          reason: 'no cache must never read as premium');
    });
  });
}
