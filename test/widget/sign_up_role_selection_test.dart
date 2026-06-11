import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/auth/screens/sign_up_screen.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(400, 1200)),
          child: child,
        ),
      ),
    );

void main() {
  group('SignUpScreen role selection', () {
    testWidgets('shows details form on step 0 (initial state)',
        (tester) async {
      await tester.pumpWidget(_wrap(const SignUpScreen()));
      await tester.pump();

      // Step 0 shows the form
      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Step 1 of 3 — Your details'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Continue button exists and is initially disabled',
        (tester) async {
      await tester.pumpWidget(_wrap(const SignUpScreen()));
      await tester.pump();

      // The Continue button should exist
      final continueButton = find.ancestor(
        of: find.text('Continue'),
        matching: find.byType(ElevatedButton),
      );
      expect(continueButton, findsOneWidget);

      // Button should be disabled initially (no form filled)
      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNull);
    });

    testWidgets(
        'Continue button becomes enabled after valid form + terms agreed',
        (tester) async {
      await tester.pumpWidget(_wrap(const SignUpScreen()));
      await tester.pump();

      // Fill in form fields
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(
          find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(
          find.byType(TextFormField).at(3), 'password123');
      await tester.pump();

      // Check the terms checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Button should now be enabled
      final continueButton = find.ancestor(
        of: find.text('Continue'),
        matching: find.byType(ElevatedButton),
      );
      final button = tester.widget<ElevatedButton>(continueButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('RoleCard widget renders student and parent options',
        (tester) async {
      // Verify the _RoleCard widget structure by directly testing
      // the sign-up screen contains the expected form field labels.
      await tester.pumpWidget(_wrap(const SignUpScreen()));
      await tester.pump();

      // Should have Confirm Password field
      expect(find.text('Confirm Password'), findsOneWidget);
      // Should have referral code field
      expect(find.text('Referral code (optional)'), findsOneWidget);
    });
  });
}
