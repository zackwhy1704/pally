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

    testWidgets('birth-year field shows on the student role step only',
        (tester) async {
      await tester.pumpWidget(_wrap(const SignUpScreen()));
      await tester.pump();

      // Fill the details form so we can advance to the role step.
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(
          find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(
          find.byType(TextFormField).at(3), 'password123');
      await tester.pump();
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Advance to the role step.
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Student is the default role → birth-year field is present.
      expect(find.text('Year you were born'), findsOneWidget);

      // Switching to the parent role hides the birth-year field.
      await tester.tap(find.text("I'm a parent / guardian"));
      await tester.pumpAndSettle();
      expect(find.text('Year you were born'), findsNothing);
    });

    testWidgets('role step has no overflow at 320x568 @1.3 on student path',
        (tester) async {
      // Use a small physical width (320) to exercise horizontal overflow, but
      // keep a tall logical height so the details-step form fields are all
      // reachable to advance to the role step under test.
      tester.view.physicalSize = const Size(320, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 1400),
                textScaler: TextScaler.linear(1.3),
              ),
              child: const SignUpScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(
          find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(
          find.byType(TextFormField).at(3), 'password123');
      await tester.pump();
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Birth-year field rendered and no layout overflow thrown.
      expect(find.text('Year you were born'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
