import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ParentalConsentPendingSheet(
          maskedEmail: maskedEmail,
          initialCooldownSeconds: initialCooldownSeconds,
          onResend: onResend,
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
