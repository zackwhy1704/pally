import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/features/modules/presentation/module_player_screen.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';
import 'package:pally/shared/models/learning_module.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );

void main() {
  group('ModulePlayerScreen', () {
    testWidgets('shows loading spinner during initial load', (tester) async {
      await tester.pumpWidget(_wrap(
        const ModulePlayerScreen(
            avatarId: 'test-avatar', moduleId: 'test-mod'),
        overrides: [
          modulePlayerViewModelProvider('test-avatar', 'test-mod')
              .overrideWith(() => _LoadingPlayerVM()),
        ],
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LEARN stage renders micro-card with title and body',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ModulePlayerScreen(
            avatarId: 'test-avatar', moduleId: 'test-mod'),
        overrides: [
          modulePlayerViewModelProvider('test-avatar', 'test-mod')
              .overrideWith(() => _LearnStageVM()),
        ],
      ));

      expect(find.text('Card 1 of 2'), findsOneWidget);
      expect(find.text('What are fractions?'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('LEARN stage shows "Ready to test yourself" on last card',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ModulePlayerScreen(
            avatarId: 'test-avatar', moduleId: 'test-mod'),
        overrides: [
          modulePlayerViewModelProvider('test-avatar', 'test-mod')
              .overrideWith(() => _LearnLastCardVM()),
        ],
      ));

      expect(find.text('Ready to test yourself'), findsOneWidget);
    });

    testWidgets('TEST stage HOT_TAKE shows Agree and Disagree buttons',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ModulePlayerScreen(
            avatarId: 'test-avatar', moduleId: 'test-mod'),
        overrides: [
          modulePlayerViewModelProvider('test-avatar', 'test-mod')
              .overrideWith(() => _TestHotTakeVM()),
        ],
      ));

      expect(find.text('True or False?'), findsOneWidget);
      expect(find.text('Agree'), findsOneWidget);
      expect(find.text('Disagree'), findsOneWidget);
    });

    testWidgets('COMPLETE stage shows celebration and mastery bars',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ModulePlayerScreen(
            avatarId: 'test-avatar', moduleId: 'test-mod'),
        overrides: [
          modulePlayerViewModelProvider('test-avatar', 'test-mod')
              .overrideWith(() => _CompleteVM()),
        ],
      ));

      expect(find.text('Module complete!'), findsOneWidget);
      expect(find.text('Back to modules'), findsOneWidget);
      expect(find.text('+25 XP'), findsOneWidget);
      expect(find.text('Adding fractions'), findsOneWidget);
    });

    testWidgets(
        'muddiest screen shows before completion when not yet submitted',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ModulePlayerScreen(
            avatarId: 'test-avatar', moduleId: 'test-mod'),
        overrides: [
          modulePlayerViewModelProvider('test-avatar', 'test-mod')
              .overrideWith(() => _MuddiestVM()),
        ],
      ));

      // Complete + concepts present + muddiest not yet answered → the
      // one-tap "which part was hardest?" prompt, not the celebration.
      expect(find.text('Which part was hardest?'), findsOneWidget);
      expect(find.text('Adding fractions'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Module complete!'), findsNothing);
    });

    testWidgets(
        'empty servable stage shows "being updated" state, not a blank screen '
        'or a red error/Retry', (tester) async {
      await tester.pumpWidget(_wrap(
        const ModulePlayerScreen(
            avatarId: 'test-avatar', moduleId: 'test-mod'),
        overrides: [
          modulePlayerViewModelProvider('test-avatar', 'test-mod')
              .overrideWith(() => _ContentUpdatingVM()),
        ],
      ));

      // The friendly waiting card — NOT the red error + "Try again" (retrying
      // now can't repopulate content that's mid-review). Bounces to Library.
      expect(find.text('Mochi is refreshing this lesson — check back soon.'),
          findsOneWidget);
      expect(find.text('Go to Library'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
      expect(find.byIcon(Icons.error_outline_rounded), findsNothing);
    });

    testWidgets(
        'revision PROVE stage renders the PROVE UI + revision banner + "Prove" chip, '
        'never "Unknown stage"', (tester) async {
      await tester.pumpWidget(_wrap(
        const ModulePlayerScreen(
            avatarId: 'test-avatar', moduleId: 'test-mod'),
        overrides: [
          modulePlayerViewModelProvider('test-avatar', 'test-mod')
              .overrideWith(() => _RevisionProveVM()),
        ],
      ));

      // The adopted PROVE stage renders ProveBody (the question) + revision banner,
      // and the header chip reads "Prove" — NOT the pre-fix "Complete"/"Unknown stage".
      expect(find.text('Explain in your own words'), findsOneWidget);
      expect(find.textContaining('Revision mode'), findsOneWidget);
      expect(find.text('Prove'), findsOneWidget);
      expect(find.text('Unknown stage'), findsNothing);
      expect(find.text('Complete'), findsNothing);
    });

    testWidgets('error state shows error message and retry button',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ModulePlayerScreen(
            avatarId: 'test-avatar', moduleId: 'test-mod'),
        overrides: [
          modulePlayerViewModelProvider('test-avatar', 'test-mod')
              .overrideWith(() => _ErrorPlayerVM()),
        ],
      ));

      expect(find.text('Try again'), findsOneWidget);
    });
  });
}

// ── Test view model overrides ──────────────────────────────────────────────

class _LoadingPlayerVM extends ModulePlayerViewModel {
  @override
  ModulePlayerState build(String avatarId, String moduleId) =>
      const ModulePlayerState(isLoading: true);
}

class _LearnStageVM extends ModulePlayerViewModel {
  @override
  ModulePlayerState build(String avatarId, String moduleId) =>
      const ModulePlayerState(
        stage: 'LEARN',
        items: [
          ModuleContentItem(
            id: 'i1',
            stage: 'LEARN',
            type: 'MICRO_CARD',
            contentJson: {
              'title': 'What are fractions?',
              'body': 'A fraction represents a part of a whole.',
              'keyTerms': ['fraction', 'whole'],
            },
          ),
          ModuleContentItem(
            id: 'i2',
            stage: 'LEARN',
            type: 'MICRO_CARD',
            contentJson: {
              'title': 'Numerator and denominator',
              'body': 'Top is numerator, bottom is denominator.',
            },
          ),
        ],
        currentIndex: 0,
      );
}

class _LearnLastCardVM extends ModulePlayerViewModel {
  @override
  ModulePlayerState build(String avatarId, String moduleId) =>
      const ModulePlayerState(
        stage: 'LEARN',
        items: [
          ModuleContentItem(
            id: 'i1',
            stage: 'LEARN',
            type: 'MICRO_CARD',
            contentJson: {'title': 'Last card', 'body': 'Done!'},
          ),
        ],
        currentIndex: 0,
      );
}

class _TestHotTakeVM extends ModulePlayerViewModel {
  @override
  ModulePlayerState build(String avatarId, String moduleId) =>
      const ModulePlayerState(
        stage: 'TEST',
        items: [
          ModuleContentItem(
            id: 'ht1',
            stage: 'TEST',
            type: 'HOT_TAKE',
            contentJson: {
              'statement': '1/2 + 1/3 = 2/5',
              'explanation': 'You need common denominators.',
              'isCorrect': false,
            },
          ),
        ],
        currentIndex: 0,
      );
}

class _CompleteVM extends ModulePlayerViewModel {
  @override
  ModulePlayerState build(String avatarId, String moduleId) =>
      const ModulePlayerState(
        stage: 'COMPLETE',
        isComplete: true,
        // Post-muddiest: the celebration screen follows the one-tap muddiest
        // prompt, so this represents the state after that prompt is answered.
        muddiestSubmitted: true,
        results: ModuleResults(
          xpEarned: 25,
          concepts: [
            ConceptMastery(
              concept: 'Adding fractions',
              mastery: 0.9,
              feedback: 'Well done!',
              passed: true,
            ),
          ],
        ),
      );
}

class _MuddiestVM extends ModulePlayerViewModel {
  @override
  ModulePlayerState build(String avatarId, String moduleId) =>
      const ModulePlayerState(
        stage: 'COMPLETE',
        isComplete: true,
        // muddiestSubmitted defaults to false → muddiest screen should show.
        results: ModuleResults(
          xpEarned: 25,
          concepts: [
            ConceptMastery(
              concept: 'Adding fractions',
              mastery: 0.9,
              feedback: 'Well done!',
              passed: true,
            ),
          ],
        ),
      );
}

class _RevisionProveVM extends ModulePlayerViewModel {
  @override
  ModulePlayerState build(String avatarId, String moduleId) =>
      const ModulePlayerState(
        stage: 'PROVE',
        isRevision: true,
        items: [
          ModuleContentItem(
            id: 'pv-1',
            stage: 'PROVE',
            type: 'PROVE_QUESTION',
            contentJson: {'question': 'Explain in your own words'},
          ),
        ],
        currentIndex: 0,
      );
}

class _ContentUpdatingVM extends ModulePlayerViewModel {
  @override
  ModulePlayerState build(String avatarId, String moduleId) =>
      const ModulePlayerState(isContentUpdating: true);
}

class _ErrorPlayerVM extends ModulePlayerViewModel {
  @override
  ModulePlayerState build(String avatarId, String moduleId) =>
      const ModulePlayerState(
        error: PallyError(PallyErrorKind.server, 'Something went wrong.'),
      );
}
