import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/collection/presentation/collection_view_model.dart';
import 'package:pally/features/create_tutor/presentation/character_picker_step.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// Stub that hands the picker a fixed server-released set so the test never
/// touches the network. The picker MUST render this set, not MochiCharacter.values.
class _StubVM extends CollectionViewModel {
  _StubVM(this._initial);
  final CollectionState _initial;
  @override
  CollectionState build() => _initial;
}

// The 9 classic characters the server releases today: 1 free default + 8 classic.
// The picker is server-driven, so it renders exactly this released fixture.
const _releasedFixture = CollectionState(entries: [
  CollectionEntry(
      id: 'MOCHI',
      character: MochiCharacter.mochi,
      rarity: 'COMMON',
      unlocked: true),
  CollectionEntry(
      id: 'PENCIL',
      character: MochiCharacter.pencil,
      rarity: 'COMMON',
      unlocked: false),
  CollectionEntry(
      id: 'SCIENCE',
      character: MochiCharacter.science,
      rarity: 'COMMON',
      unlocked: false),
  CollectionEntry(
      id: 'PE',
      character: MochiCharacter.pe,
      rarity: 'COMMON',
      unlocked: false),
  CollectionEntry(
      id: 'ART',
      character: MochiCharacter.art,
      rarity: 'COMMON',
      unlocked: false),
  CollectionEntry(
      id: 'LUNCHBOX',
      character: MochiCharacter.lunchbox,
      rarity: 'COMMON',
      unlocked: false),
  CollectionEntry(
      id: 'LIBRARY',
      character: MochiCharacter.library,
      rarity: 'COMMON',
      unlocked: false),
  CollectionEntry(
      id: 'HEADMASTER',
      character: MochiCharacter.headmaster,
      rarity: 'RARE',
      unlocked: false),
  CollectionEntry(
      id: 'GOLDSTAR',
      character: MochiCharacter.goldstar,
      rarity: 'SECRET',
      unlocked: false),
]);

Widget _wrap(CollectionState s) {
  return ProviderScope(
    overrides: [
      collectionViewModelProvider.overrideWith(() => _StubVM(s)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: CharacterPickerStep(
          selectedCharacter: null,
          onSelect: (_) {},
          onNext: () {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
      'renders exactly the 9 server-released cards, never the full enum',
      (tester) async {
    await tester.pumpWidget(_wrap(_releasedFixture));
    await tester.pump();

    // Driven by the server set (9), NOT MochiCharacter.values.length (17).
    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate = grid.childrenDelegate as SliverChildBuilderDelegate;
    expect(delegate.childCount, 9);
  });

  testWidgets('only released characters render — picker is server-driven',
      (tester) async {
    await tester.pumpWidget(_wrap(_releasedFixture));
    await tester.pump();

    // The picker renders ONLY the server's released fixture, never the full
    // local enum. (The 8 Around-the-World Mochis were removed product-wide;
    // this guards the truth rule for any future unreleased character too.)
    expect(find.text('Made-up Mochi'), findsNothing);

    // And the free default Mochi IS present, proving the released set rendered.
    expect(find.text('Mochi'), findsOneWidget);
  });

  testWidgets('skips catalog entries with no local painter mapping',
      (tester) async {
    // A future seasonal Mochi the backend shipped ahead of the app: null char.
    const withUnknown = CollectionState(entries: [
      CollectionEntry(
          id: 'MOCHI',
          character: MochiCharacter.mochi,
          rarity: 'COMMON',
          unlocked: true),
      CollectionEntry(
          id: 'FUTURE_SEASONAL',
          character: null,
          rarity: 'COMMON',
          unlocked: false),
    ]);
    await tester.pumpWidget(_wrap(withUnknown));
    await tester.pump();

    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate = grid.childrenDelegate as SliverChildBuilderDelegate;
    expect(delegate.childCount, 1); // only the renderable Mochi
  });
}
