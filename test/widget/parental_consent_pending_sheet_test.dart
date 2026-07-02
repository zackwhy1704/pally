import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/consent/presentation/parental_consent_pending_sheet.dart';

/// The half-elevated (under-13 awaiting parent) sheet must: show the MASKED
/// parent email (never the full address), drive the resend button through
/// idle → sending → sent/cooldown/failed with a live countdown, and never be a
/// silent no-op.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    required String maskedEmail,
    required int initialCooldownSeconds,
    required Future<ResendResult> Function() onResend,
    Future<ResendResult> Function(String)? onChangeEmail,
  }) async {
    await tester.pumpWidget(ProviderScope(
      // Override with a constant so the sheet's authState listener doesn't
      // instantiate (and, on teardown, dispose) the real AuthNotifier singleton.
      overrides: [authStateProvider.overrideWith((ref) => const AuthState())],
      child: MaterialApp(
        home: Scaffold(
          body: ParentalConsentPendingSheet(
            maskedEmail: maskedEmail,
            initialCooldownSeconds: initialCooldownSeconds,
            onResend: onResend,
            onChangeEmail: onChangeEmail,
          ),
        ),
      ),
    ));
  }

  testWidgets('renders masked parent email and a Resend button', (tester) async {
    await pump(
      tester,
      maskedEmail: 'j***@gmail.com',
      initialCooldownSeconds: 0,
      onResend: () async => const ResendResult(ResendOutcome.sent),
    );

    expect(find.textContaining('j***@gmail.com'), findsOneWidget);
    // Full address must never leak — the masked form is the only email shown.
    expect(find.textContaining('john@gmail.com'), findsNothing);
    expect(find.text('Resend email'), findsOneWidget);
  });

  testWidgets('successful resend shows the sent confirmation and disables cooldown',
      (tester) async {
    var calls = 0;
    await pump(
      tester,
      maskedEmail: 'a***@x.com',
      initialCooldownSeconds: 0,
      onResend: () async {
        calls += 1;
        return const ResendResult(ResendOutcome.sent, cooldownSeconds: 60);
      },
    );

    await tester.tap(find.text('Resend email'));
    await tester.pump(); // sending
    await tester.pump(); // resolves to sent
    await tester.pump();

    expect(calls, 1);
    expect(find.textContaining('re-sent to a***@x.com'), findsOneWidget);
    // Button now shows the countdown and is disabled.
    expect(find.text('Resend in 60s'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('starts in a disabled cooldown when one is already active',
      (tester) async {
    await pump(
      tester,
      maskedEmail: 'a***@x.com',
      initialCooldownSeconds: 42,
      onResend: () async => const ResendResult(ResendOutcome.sent),
    );

    expect(find.text('Resend in 42s'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('wrong-email recovery: change-email opens an entry dialog and re-points',
      (tester) async {
    String? changedTo;
    await pump(
      tester,
      maskedEmail: 'w***@typo.com',
      initialCooldownSeconds: 0,
      onResend: () async => const ResendResult(ResendOutcome.sent),
      onChangeEmail: (email) async {
        changedTo = email;
        return ResendResult(ResendOutcome.sent,
            cooldownSeconds: 60, maskedEmail: 'r***@right.com');
      },
    );

    // The recovery affordance is visible (a typo isn't a dead-end).
    expect(find.text("Wrong grown-up's email? Change it"), findsOneWidget);
    await tester.tap(find.text("Wrong grown-up's email? Change it"));
    await tester.pump(); // open dialog
    await tester.pump(const Duration(milliseconds: 300)); // settle dialog anim

    // A dialog to enter the correct address appears.
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'right@right.com');
    await tester.tap(find.text('Send'));
    await tester.pump(); // close dialog + sending
    await tester.pump(); // resolves

    expect(changedTo, 'right@right.com');
    // The masked address updates to the new inbox (shown in intro + status line).
    expect(find.textContaining('r***@right.com'), findsWidgets);
  });

  testWidgets('change-email affordance is absent when no handler is wired',
      (tester) async {
    await pump(
      tester,
      maskedEmail: 'a***@x.com',
      initialCooldownSeconds: 0,
      onResend: () async => const ResendResult(ResendOutcome.sent),
    );
    expect(find.text("Wrong grown-up's email? Change it"), findsNothing);
  });

  testWidgets('a failed resend shows a visible retry-able error', (tester) async {
    await pump(
      tester,
      maskedEmail: 'a***@x.com',
      initialCooldownSeconds: 0,
      onResend: () async => const ResendResult(ResendOutcome.failed),
    );

    await tester.tap(find.text('Resend email'));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining("Couldn't resend"), findsOneWidget);
    // Still actionable — not a silent dead end.
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });
}
