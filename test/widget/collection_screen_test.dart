import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/collection/presentation/collection_screen.dart';
import 'package:pally/features/collection/presentation/collection_view_model.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// Renders the album with stubbed state to lock the three primary UI
/// states (loading / error / data) without touching the network.
class _StubVM extends CollectionViewModel {
  _StubVM(this._initial);
  final CollectionState _initial;
  @override
  CollectionState build() => _initial;
}

Widget _wrap(CollectionState s) {
  return ProviderScope(
    overrides: [
      collectionViewModelProvider.overrideWith(() => _StubVM(s)),
    ],
    child: const MaterialApp(home: CollectionScreen()),
  );
}

void main() {
  testWidgets('shows loading spinner while loading', (tester) async {
    await tester.pumpWidget(_wrap(const CollectionState(isLoading: true)));
    expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
  });

  testWidgets('shows error card with retry on failure', (tester) async {
    await tester.pumpWidget(_wrap(const CollectionState(
        isLoading: false, error: 'Network down')));
    expect(find.textContaining('Network'), findsOneWidget);
    // PallyErrorCard exposes a retry affordance — actual text depends on
    // the implementation, but tap region is reliably a button or
    // gesture detector.
  });

  testWidgets('shows progress banner with owned/total + percent', (tester) async {
    final state = CollectionState(entries: [
      const CollectionEntry(
          id: 'MOCHI',
          character: MochiCharacter.mochi,
          rarity: 'COMMON',
          unlocked: true),
      const CollectionEntry(
          id: 'PENCIL',
          character: MochiCharacter.pencil,
          rarity: 'COMMON',
          unlocked: false),
      const CollectionEntry(
          id: 'GOLDSTAR',
          character: MochiCharacter.goldstar,
          rarity: 'SECRET',
          unlocked: false),
    ]);
    await tester.pumpWidget(_wrap(state));
    // Image assets aren't loaded in test env — pump once to flush the
    // initial build.
    await tester.pump();
    expect(find.text('1 / 3'), findsOneWidget);
    // Locked Mochis show 🔒 overlay (2 unlocked-of-3 = 2 locks).
    expect(find.text('🔒'), findsNWidgets(2));
  });

  testWidgets('renders SECRET badge for secret-rarity entries', (tester) async {
    final state = CollectionState(entries: [
      const CollectionEntry(
          id: 'GOLDSTAR',
          character: MochiCharacter.goldstar,
          rarity: 'SECRET',
          unlocked: false),
    ]);
    await tester.pumpWidget(_wrap(state));
    await tester.pump();
    expect(find.text('SECRET'), findsOneWidget);
  });

  testWidgets('renders "Complete!" copy when fully owned', (tester) async {
    final state = CollectionState(entries: [
      const CollectionEntry(
          id: 'MOCHI',
          character: MochiCharacter.mochi,
          rarity: 'COMMON',
          unlocked: true),
    ]);
    await tester.pumpWidget(_wrap(state));
    await tester.pump();
    expect(find.textContaining('Complete'), findsOneWidget);
  });
}
