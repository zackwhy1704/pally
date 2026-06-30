import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_screen.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_view_model.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );

void main() {
  group('DirectOnboardingScreen', () {
    testWidgets('step 1 renders sign-up fields', (tester) async {
      await tester.pumpWidget(_wrap(
        const DirectOnboardingScreen(),
        overrides: [
          directOnboardingViewModelProvider
              .overrideWith(() => _Step1VM()),
        ],
      ));

      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Already have an account? Sign in'), findsOneWidget);
      expect(find.text('Step 1 of 3'), findsOneWidget);
      // Age group selectors are present
      expect(find.text('I am 13 or older'), findsOneWidget);
      expect(find.text('I am under 13'), findsOneWidget);
    });

    testWidgets('step 1 parent email hidden when 13+', (tester) async {
      await tester.pumpWidget(_wrap(
        const DirectOnboardingScreen(),
        overrides: [
          directOnboardingViewModelProvider
              .overrideWith(() => _Step1AgeKnownVM(isUnder13: false)),
        ],
      ));

      expect(find.text("Parent's email address"), findsNothing);
    });

    testWidgets('step 1 parent email shown when under 13', (tester) async {
      await tester.pumpWidget(_wrap(
        const DirectOnboardingScreen(),
        overrides: [
          directOnboardingViewModelProvider
              .overrideWith(() => _Step1AgeKnownVM(isUnder13: true)),
        ],
      ));

      expect(find.text("Parent's email address"), findsOneWidget);
      expect(
        find.text(
            "We'll email your parent to approve your account before you can use AI features."),
        findsOneWidget,
      );
    });

    testWidgets(
        'awaitingConsent state does not show full-screen consent blocker — '
        'under-13 users go straight to the dashboard', (tester) async {
      await tester.pumpWidget(_wrap(
        const DirectOnboardingScreen(),
        overrides: [
          directOnboardingViewModelProvider
              .overrideWith(() => _ConsentPendingVM()),
        ],
      ));

      // The full-screen consent UI is now on the home screen banner, not here.
      expect(find.text("Check your parent's email!"), findsNothing);
      // The normal step-1 UI should be rendered instead.
      expect(find.text('Create your account'), findsOneWidget);
    });

    testWidgets(
        'email field rejects single-char TLD and shows inline error', (tester) async {
      await tester.pumpWidget(_wrap(
        const DirectOnboardingScreen(),
        overrides: [
          directOnboardingViewModelProvider
              .overrideWith(() => _Step1AgeKnownVM(isUnder13: false)),
        ],
      ));

      // Name, Email, Password fields are indices 0, 1, 2
      await tester.enterText(find.byType(TextFormField).at(0), 'Alice');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'jsja@hshs.c');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');

      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pump();

      expect(
        find.text('Please enter a valid email (e.g. you@example.com)'),
        findsOneWidget,
      );
    });

    testWidgets(
        'parent email field rejects single-char TLD and shows inline error',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const DirectOnboardingScreen(),
        overrides: [
          directOnboardingViewModelProvider
              .overrideWith(() => _Step1AgeKnownVM(isUnder13: true)),
        ],
      ));

      // Under-13: Name=0, Email=1, Password=2, ParentEmail=3
      await tester.enterText(find.byType(TextFormField).at(0), 'Bob');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'bob@school.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(
          find.byType(TextFormField).at(3), 'parent@home.c');

      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pump();

      expect(
        find.text(
            "Please enter your parent's valid email (e.g. parent@example.com)"),
        findsOneWidget,
      );
    });

    testWidgets('step 2 renders subject and level pickers', (tester) async {
      await tester.pumpWidget(_wrap(
        const DirectOnboardingScreen(),
        overrides: [
          directOnboardingViewModelProvider
              .overrideWith(() => _Step2VM()),
        ],
      ));

      expect(find.text('What are you studying?'), findsOneWidget);
      expect(find.text('Subject'), findsOneWidget);
      expect(find.text('Education stage'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Step 2 of 3'), findsOneWidget);
      // Subject chips
      expect(find.text('Maths'), findsOneWidget);
      expect(find.text('Science'), findsOneWidget);
      // Education stage tiles (global, not Singapore-specific)
      expect(find.text('Primary School'), findsOneWidget);
      expect(find.text('High School'), findsOneWidget);
      expect(find.text('University / Adult'), findsOneWidget);
    });

    testWidgets('step 3 renders upload prompt', (tester) async {
      await tester.pumpWidget(_wrap(
        const DirectOnboardingScreen(),
        overrides: [
          directOnboardingViewModelProvider
              .overrideWith(() => _Step3IdleVM()),
        ],
      ));

      expect(find.text('Add your first notes'), findsOneWidget);
      expect(find.text('Add to Mochi'), findsOneWidget);
      expect(find.text('Or snap a photo'), findsOneWidget);
      expect(find.text('Or choose a file'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
      expect(find.text('Step 3 of 3'), findsOneWidget);
    });

    testWidgets('step 3 processing shows spinner and message', (tester) async {
      await tester.pumpWidget(_wrap(
        const DirectOnboardingScreen(),
        overrides: [
          directOnboardingViewModelProvider
              .overrideWith(() => _Step3CompilingVM()),
        ],
      ));

      expect(find.text('Mochi is reading your notes...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('step 3 ready shows success and start button', (tester) async {
      await tester.pumpWidget(_wrap(
        const DirectOnboardingScreen(),
        overrides: [
          directOnboardingViewModelProvider
              .overrideWith(() => _Step3ReadyVM()),
        ],
      ));

      expect(find.text('Your "Fractions" module is ready!'), findsOneWidget);
      expect(find.text('Start learning'), findsOneWidget);
    });
  });
}

// ── Test view model overrides ──────────────────────────────────────────────

class _Step1VM extends DirectOnboardingViewModel {
  @override
  DirectOnboardingState build() => const DirectOnboardingState(step: 1);
}

class _Step2VM extends DirectOnboardingViewModel {
  @override
  DirectOnboardingState build() => const DirectOnboardingState(step: 2);
}

class _Step3IdleVM extends DirectOnboardingViewModel {
  @override
  DirectOnboardingState build() => const DirectOnboardingState(
        step: 3,
        avatarId: 'test-avatar',
        uploadStage: DirectUploadStage.idle,
      );
}

class _Step3CompilingVM extends DirectOnboardingViewModel {
  @override
  DirectOnboardingState build() => const DirectOnboardingState(
        step: 3,
        avatarId: 'test-avatar',
        uploadStage: DirectUploadStage.compiling,
      );
}

class _Step3ReadyVM extends DirectOnboardingViewModel {
  @override
  DirectOnboardingState build() => const DirectOnboardingState(
        step: 3,
        avatarId: 'test-avatar',
        uploadStage: DirectUploadStage.ready,
        firstModuleId: 'mod-1',
        firstModuleTitle: 'Fractions',
      );
}

class _Step1AgeKnownVM extends DirectOnboardingViewModel {
  _Step1AgeKnownVM({required this.isUnder13});
  final bool isUnder13;

  @override
  DirectOnboardingState build() =>
      DirectOnboardingState(step: 1, isUnder13: isUnder13);
}

class _ConsentPendingVM extends DirectOnboardingViewModel {
  @override
  DirectOnboardingState build() => const DirectOnboardingState(
        awaitingConsent: true,
        maskedParentEmail: 'j***e@gmail.com',
      );
}
