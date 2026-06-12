import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/family/family_service.dart';
import 'package:pally/features/family/presentation/family_link_code_screen.dart';

/// Fake service that hands the screen a code expiring at a fixed instant.
class _FakeFamilyService extends FamilyService {
  _FakeFamilyService(this._expiresAt) : super(Dio());
  final DateTime _expiresAt;

  @override
  Future<FamilyLinkCode> issueLinkCode() async => FamilyLinkCode(
        code: 'ABC123',
        expiresAt: _expiresAt.toUtc().toIso8601String(),
      );
}

void main() {
  // A controllable clock the test advances in lockstep with tester.pump().
  late DateTime fakeNow;
  // Anchor "now" and the expiry to fixed instants so the countdown is exact.
  final start = DateTime(2026, 1, 1, 12, 0, 0);

  Widget wrap(DateTime expiresAt) => ProviderScope(
        overrides: [
          familyServiceProvider
              .overrideWithValue(_FakeFamilyService(expiresAt)),
        ],
        child: MaterialApp(
          home: FamilyLinkCodeScreen(clock: () => fakeNow),
        ),
      );

  testWidgets('renders a live mm:ss countdown that decrements every second',
      (tester) async {
    fakeNow = start;
    // Expires 5 seconds after the anchored now.
    await tester.pumpWidget(wrap(start.add(const Duration(seconds: 5))));
    await tester.pump(); // resolve issueLinkCode()
    await tester.pump();

    expect(find.text('ABC123'), findsOneWidget);
    expect(find.text('This code works for 15 minutes.'), findsOneWidget);
    // 5s remaining -> 00:05.
    expect(find.text('Expires in 00:05'), findsOneWidget);

    // Advance the clock + the timer by 3 seconds, one tick at a time.
    for (var i = 0; i < 3; i++) {
      fakeNow = fakeNow.add(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    }
    // 2s remaining -> 00:02.
    expect(find.text('Expires in 00:02'), findsOneWidget);
  });

  testWidgets('flips to the expired state at zero and stops counting',
      (tester) async {
    fakeNow = start;
    await tester.pumpWidget(wrap(start.add(const Duration(seconds: 2))));
    await tester.pump();
    await tester.pump();

    expect(find.text('Expires in 00:02'), findsOneWidget);
    expect(find.textContaining('Code expired'), findsNothing);

    // Advance past expiry.
    for (var i = 0; i < 3; i++) {
      fakeNow = fakeNow.add(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    }

    expect(find.text('Code expired — tap refresh below'), findsOneWidget);
    expect(find.textContaining('Expires in'), findsNothing);
  });
}
