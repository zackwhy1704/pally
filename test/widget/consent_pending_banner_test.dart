import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/home/presentation/home_screen.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_view_model.dart';

/// Fake onboarding VM with a fixed idle state so the banner renders without
/// touching storage/network. Its consent methods are never tapped in these tests.
class _FakeOnboardVM extends DirectOnboardingViewModel {
  @override
  DirectOnboardingState build() => const DirectOnboardingState();
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      authStateProvider.overrideWith(
          (ref) => const AuthState(awaitingConsent: true, maskedParentEmail: 'j***@x.com')),
      directOnboardingViewModelProvider.overrideWith(_FakeOnboardVM.new),
    ],
    child: const MaterialApp(home: Scaffold(body: ConsentPendingBanner())),
  ));
  await tester.pump();
}

void main() {
  testWidgets('while awaiting consent, recovery actions are shown', (tester) async {
    await _pump(tester);
    expect(find.text('Waiting for parental approval'), findsOneWidget);
    expect(find.text('Resend email'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('closing COLLAPSES to a chip (never vanishes) and re-expands', (tester) async {
    await _pump(tester);

    // Close → must NOT disappear; collapses to a persistent, tappable chip.
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(find.text('Waiting for parental approval'), findsNothing);
    expect(find.text('Awaiting parental approval — tap for options'), findsOneWidget);

    // Tap the chip → full banner (with recovery actions) is reachable again.
    await tester.tap(find.text('Awaiting parental approval — tap for options'));
    await tester.pump();
    expect(find.text('Waiting for parental approval'), findsOneWidget);
    expect(find.text('Resend email'), findsOneWidget);
  });
}
