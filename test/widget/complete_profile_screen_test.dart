import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/auth/screens/complete_profile_screen.dart';
import 'package:pally/features/auth/screens/complete_profile_view_model.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );

void main() {
  group('CompleteProfileScreen', () {
    testWidgets('idle state renders the age-group prompt and Continue',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const CompleteProfileScreen(),
        overrides: [
          completeProfileViewModelProvider.overrideWith(() => _IdleVM()),
        ],
      ));

      expect(find.text('One quick thing'), findsOneWidget);
      expect(find.text('I am 13 or older'), findsOneWidget);
      expect(find.text('I am under 13'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      // No parent-email field until under-13 is chosen.
      expect(find.text("Parent's email address"), findsNothing);
    });

    testWidgets('choosing under-13 reveals the parent-email field',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const CompleteProfileScreen(),
        overrides: [
          completeProfileViewModelProvider
              .overrideWith(() => _AgeKnownVM(isUnder13: true)),
        ],
      ));

      expect(find.text("Parent's email address"), findsOneWidget);
      expect(
        find.text(
            "We'll email your parent to approve your account before you can use AI features."),
        findsOneWidget,
      );
    });

    testWidgets('loading state disables the button and shows a spinner',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const CompleteProfileScreen(),
        overrides: [
          completeProfileViewModelProvider.overrideWith(() => _LoadingVM()),
        ],
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button =
          tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull); // disabled while in flight
    });

    testWidgets('error state shows a persistent inline message and Try again',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const CompleteProfileScreen(),
        overrides: [
          completeProfileViewModelProvider.overrideWith(() => _ErrorVM()),
        ],
      ));

      expect(find.text('No account found for this email'), findsOneWidget);
      // The primary action doubles as Retry — never a toast-only error.
      expect(find.text('Try again'), findsOneWidget);
      final button =
          tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull); // re-enabled to retry
    });
  });
}

// ── Test view model overrides ──────────────────────────────────────────────

class _IdleVM extends CompleteProfileViewModel {
  @override
  CompleteProfileState build() => const CompleteProfileState();
}

class _AgeKnownVM extends CompleteProfileViewModel {
  _AgeKnownVM({required this.isUnder13});
  final bool isUnder13;

  @override
  CompleteProfileState build() =>
      CompleteProfileState(isUnder13: isUnder13);
}

class _LoadingVM extends CompleteProfileViewModel {
  @override
  CompleteProfileState build() =>
      const CompleteProfileState(isUnder13: false, isLoading: true);
}

class _ErrorVM extends CompleteProfileViewModel {
  @override
  CompleteProfileState build() => const CompleteProfileState(
        isUnder13: false,
        error: 'No account found for this email',
      );
}
