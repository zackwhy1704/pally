import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_screen.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_view_model.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );

void main() {
  // In-memory flutter_secure_storage so the AuthNotifier singleton (read by the
  // screen's "already signed in" gate) works in tests without native channels.
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String>{};

  setUp(() async {
    store.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final args = (call.arguments as Map?) ?? {};
      switch (call.method) {
        case 'read':
          return store[args['key']];
        case 'write':
          store[args['key'] as String] = args['value'] as String;
          return null;
        case 'delete':
          store.remove(args['key']);
          return null;
        case 'deleteAll':
          store.clear();
          return null;
        case 'readAll':
          return Map<String, String>.from(store);
        case 'containsKey':
          return store.containsKey(args['key']);
      }
      return null;
    });
    // Start every test from a signed-OUT singleton so the default flow renders
    // the form; the two interstitial tests opt in with an explicit signIn.
    await AuthNotifier.instance.signOut();
  });

  tearDown(() async {
    await AuthNotifier.instance.signOut();
  });

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

    testWidgets(
        'entering signup while already signed in shows the log-out '
        'interstitial, NOT the sign-up form', (tester) async {
      await AuthNotifier.instance
          .signIn(userId: 'u1', token: 't1');
      await AuthNotifier.instance.setChildName('Alex');

      await tester.pumpWidget(_wrap(
        const DirectOnboardingScreen(),
        overrides: [
          directOnboardingViewModelProvider.overrideWith(() => _Step1VM()),
        ],
      ));

      // The explicit choice is shown first...
      expect(find.text('Create a new account?'), findsOneWidget);
      expect(
        find.text(
            "You're signed in as Alex. Log out to create a new account?"),
        findsOneWidget,
      );
      expect(find.text('Log out & continue'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      // ...and the sign-up form is NOT (never silently continue).
      expect(find.text('Create your account'), findsNothing);
    });

    testWidgets(
        'tapping Log out & continue dismisses the interstitial and reveals '
        'the sign-up form', (tester) async {
      await AuthNotifier.instance
          .signIn(userId: 'u1', token: 't1');
      await AuthNotifier.instance.setChildName('Alex');

      await tester.pumpWidget(_wrap(
        const DirectOnboardingScreen(),
        overrides: [
          directOnboardingViewModelProvider.overrideWith(() => _NoopLogoutVM()),
        ],
      ));

      expect(find.text('Create a new account?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Log out & continue'));
      await tester.pumpAndSettle();

      // After an explicit logout the normal step-1 form appears.
      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Create a new account?'), findsNothing);
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

    testWidgets('step 3 irrelevant upload shows the override question, NOT success',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const DirectOnboardingScreen(),
        overrides: [
          directOnboardingViewModelProvider
              .overrideWith(() => _Step3IrrelevantVM()),
        ],
      ));

      // The honest "use anyway?" override — never the fake success screen.
      expect(find.textContaining("doesn't look like"), findsOneWidget);
      expect(find.text('Use it anyway'), findsOneWidget);
      expect(find.text('Choose a different file'), findsOneWidget);
      // NOT the success/ready screen.
      expect(find.text('Start learning'), findsNothing);
    });

    testWidgets('step 3 segmented (150+ page) upload shows chapter picker, NOT success',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const DirectOnboardingScreen(),
        overrides: [
          directOnboardingViewModelProvider
              .overrideWith(() => _Step3SegmentedVM()),
        ],
      ));
      await tester.pump();

      // The chapter-pick surface — never the fake success/start screen.
      expect(find.text('Your book is split into chapters'), findsOneWidget);
      expect(find.text('Choose chapters'), findsOneWidget);
      expect(find.text('Start learning'), findsNothing);
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

/// Step-1 VM whose logout is a no-op so the interstitial-dismissal test doesn't
/// touch the AuthNotifier singleton / secure storage.
class _NoopLogoutVM extends DirectOnboardingViewModel {
  @override
  DirectOnboardingState build() => const DirectOnboardingState(step: 1);

  @override
  Future<void> logOutForNewSignup() async {}
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

class _Step3SegmentedVM extends DirectOnboardingViewModel {
  @override
  DirectOnboardingState build() => const DirectOnboardingState(
        step: 3,
        avatarId: 'test-avatar',
        uploadStage: DirectUploadStage.awaitingChapterPick,
      );
}

class _Step3IrrelevantVM extends DirectOnboardingViewModel {
  @override
  DirectOnboardingState build() => const DirectOnboardingState(
        step: 3,
        avatarId: 'test-avatar',
        selectedSubject: 'Maths',
        uploadStage: DirectUploadStage.irrelevant,
        irrelevantReason: 'This looks like coding material, not Maths.',
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
