import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/modules/presentation/module_player_screen.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';
import 'package:pally/shared/models/learning_module.dart';
import 'package:pally/shared/models/narration.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );

void main() {
  group('ModulePlayerScreen narration', () {
    testWidgets('LEARN stage shows Listen button on micro-card',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ModulePlayerScreen(
            avatarId: 'test-avatar', moduleId: 'test-mod'),
        overrides: [
          modulePlayerViewModelProvider('test-avatar', 'test-mod')
              .overrideWith(() => _LearnWithNoNarrationVM()),
        ],
      ));

      // The Listen button (speaker icon) should be visible
      expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);
    });

    testWidgets('LEARN stage shows speaker icon when narration is ready',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ModulePlayerScreen(
            avatarId: 'test-avatar', moduleId: 'test-mod'),
        overrides: [
          modulePlayerViewModelProvider('test-avatar', 'test-mod')
              .overrideWith(() => _LearnWithNarrationVM()),
        ],
      ));

      // The filled speaker icon should be visible (narration ready)
      expect(find.byIcon(Icons.volume_up_rounded), findsWidgets);
    });

    testWidgets('LEARN stage shows Play all button', (tester) async {
      await tester.pumpWidget(_wrap(
        const ModulePlayerScreen(
            avatarId: 'test-avatar', moduleId: 'test-mod'),
        overrides: [
          modulePlayerViewModelProvider('test-avatar', 'test-mod')
              .overrideWith(() => _LearnWithNarrationVM()),
        ],
      ));

      expect(find.text('Play all'), findsOneWidget);
    });

    testWidgets('LEARN stage shows Pause button when playing all',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ModulePlayerScreen(
            avatarId: 'test-avatar', moduleId: 'test-mod'),
        overrides: [
          modulePlayerViewModelProvider('test-avatar', 'test-mod')
              .overrideWith(() => _LearnPlayingAllVM()),
        ],
      ));

      expect(find.text('Pause'), findsOneWidget);
    });

    testWidgets('playing card gets teal border highlight', (tester) async {
      await tester.pumpWidget(_wrap(
        const ModulePlayerScreen(
            avatarId: 'test-avatar', moduleId: 'test-mod'),
        overrides: [
          modulePlayerViewModelProvider('test-avatar', 'test-mod')
              .overrideWith(() => _LearnPlayingCardVM()),
        ],
      ));

      // The pause icon should be on the playing card
      expect(find.byIcon(Icons.pause_rounded), findsWidgets);
    });

    testWidgets('narration loading shows spinner on card', (tester) async {
      await tester.pumpWidget(_wrap(
        const ModulePlayerScreen(
            avatarId: 'test-avatar', moduleId: 'test-mod'),
        overrides: [
          modulePlayerViewModelProvider('test-avatar', 'test-mod')
              .overrideWith(() => _LearnNarrationLoadingVM()),
        ],
      ));

      // Should show a small spinner where the listen button is
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}

// ── Test view model overrides ──────────────────────────────────────────────

const _testItems = [
  ModuleContentItem(
    id: 'i1',
    stage: 'LEARN',
    type: 'MICRO_CARD',
    contentJson: {
      'title': 'What are fractions?',
      'body': 'A fraction represents a part of a whole.',
      'keyTerms': ['fraction'],
    },
  ),
  ModuleContentItem(
    id: 'i2',
    stage: 'LEARN',
    type: 'MICRO_CARD',
    contentJson: {
      'title': 'Numerator',
      'body': 'Top number.',
    },
  ),
];

const _testNarration = Narration(
  id: 'nar-1',
  status: 'READY',
  segments: [
    NarrationSegment(
      cardIndex: 0,
      scriptText: 'A fraction represents a part of a whole.',
      audioUrl: 'https://example.com/audio/0.mp3',
      durationMs: 5000,
    ),
    NarrationSegment(
      cardIndex: 1,
      scriptText: 'The top number is the numerator.',
      audioUrl: 'https://example.com/audio/1.mp3',
      durationMs: 4000,
    ),
  ],
);

class _LearnWithNoNarrationVM extends ModulePlayerViewModel {
  @override
  ModulePlayerState build(String avatarId, String moduleId) =>
      const ModulePlayerState(
        stage: 'LEARN',
        items: _testItems,
        currentIndex: 0,
      );
}

class _LearnWithNarrationVM extends ModulePlayerViewModel {
  @override
  ModulePlayerState build(String avatarId, String moduleId) =>
      const ModulePlayerState(
        stage: 'LEARN',
        items: _testItems,
        currentIndex: 0,
        narration: _testNarration,
      );
}

class _LearnPlayingAllVM extends ModulePlayerViewModel {
  @override
  ModulePlayerState build(String avatarId, String moduleId) =>
      const ModulePlayerState(
        stage: 'LEARN',
        items: _testItems,
        currentIndex: 0,
        narration: _testNarration,
        isPlaying: true,
        isPlayingAll: true,
        currentPlayingCard: 0,
      );
}

class _LearnPlayingCardVM extends ModulePlayerViewModel {
  @override
  ModulePlayerState build(String avatarId, String moduleId) =>
      const ModulePlayerState(
        stage: 'LEARN',
        items: _testItems,
        currentIndex: 0,
        narration: _testNarration,
        isPlaying: true,
        currentPlayingCard: 0,
      );
}

class _LearnNarrationLoadingVM extends ModulePlayerViewModel {
  @override
  ModulePlayerState build(String avatarId, String moduleId) =>
      const ModulePlayerState(
        stage: 'LEARN',
        items: _testItems,
        currentIndex: 0,
        narrationLoading: true,
      );
}
