import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/features/library/presentation/library_screen.dart';
import 'package:pally/features/library/presentation/library_view_model.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// Pins the Library de-clutter: rows are a clean front door (tap → hub) and the
/// two swipe flows (personal delete, centre leave) survive the simplification.
class _StubLibraryVM extends LibraryViewModel {
  _StubLibraryVM(this.avatars);
  final List<Avatar> avatars;
  @override
  Future<List<Avatar>> build() async => avatars;
}

final _personal = Avatar(
  id: 'p1',
  name: 'Sakura',
  character: MochiCharacter.mochi,
  subject: 'MATHS',
  wikiPageCount: 2,
);

final _classAvatar = Avatar(
  id: 'c1',
  name: 'P5 Science',
  character: MochiCharacter.science,
  subject: 'SCIENCE',
  kind: AvatarKind.centreClass,
  classId: 'class-1',
  appearance: const ClassAppearance(
      bandColorHex: '#7042ED', subjectGlyph: 'sci', initials: 'P5'),
);

Future<void> _pump(WidgetTester tester, List<Avatar> avatars) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(420, 1200);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(initialLocation: '/library', routes: [
    GoRoute(path: '/library', builder: (c, s) => const LibraryScreen()),
    GoRoute(
      path: '/avatar/:avatarId',
      builder: (c, s) => Scaffold(body: Text('HUB_${s.pathParameters['avatarId']}')),
    ),
  ]);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        libraryViewModelProvider.overrideWith(() => _StubLibraryVM(avatars)),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('(d) tapping a library row opens the avatar hub', (tester) async {
    await _pump(tester, [_personal]);
    expect(find.text('Sakura'), findsOneWidget);
    // Chips are gone — the row is minimal now.
    expect(find.text('Chat'), findsNothing);
    expect(find.text('Quiz'), findsNothing);

    await tester.tap(find.text('Sakura'));
    await tester.pumpAndSettle();
    expect(find.text('HUB_p1'), findsOneWidget);
  });

  testWidgets('(e) swiping a personal row still triggers the delete dialog',
      (tester) async {
    await _pump(tester, [_personal]);

    await tester.drag(find.text('Sakura'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // PallyDeleteTutorDialog's confirmation — the flow survived the refactor.
    expect(find.text('Delete Sakura?'), findsOneWidget);
  });

  testWidgets('(e) swiping a centre-class row still triggers the leave dialog',
      (tester) async {
    await _pump(tester, [_classAvatar]);

    await tester.drag(find.text('P5 Science'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Leave this class?'), findsOneWidget);
  });
}
