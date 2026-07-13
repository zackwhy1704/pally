import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pally/core/ui/no_notes_cta.dart';
import 'package:pally/features/avatar_hub/presentation/avatar_hub_screen.dart';
import 'package:pally/features/avatar_hub/presentation/avatar_hub_view_model.dart';
import 'package:pally/features/quiz/providers/quiz_status_provider.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// Stubs the hub VM so the screen renders synchronously from fixed data.
class _StubHubVM extends AvatarHubViewModel {
  _StubHubVM(this.data);
  final AvatarHubData data;
  @override
  Future<AvatarHubData> build(String avatarId) async => data;
}

Avatar _avatar({
  int wikiPageCount = 3, // knowledge-bearing by default
  bool centreManaged = false,
  bool centreClass = false, // drives isCentreClass (needs appearance)
}) =>
    Avatar(
      id: 'av1',
      name: 'Sakura',
      character: MochiCharacter.mochi,
      subject: 'MATHS',
      wikiPageCount: wikiPageCount,
      centreManaged: centreManaged,
      kind: centreClass ? AvatarKind.centreClass : AvatarKind.personal,
      appearance: centreClass
          ? const ClassAppearance(
              bandColorHex: '#7042ED', subjectGlyph: 'math', initials: 'P5')
          : null,
    );

/// The 7 journey destinations → a stub path so we can prove each row pushes the
/// right typed route via the ambient GoRouter.
const _dests = {
  'modules': 'DEST_modules',
  'quiz': 'DEST_quiz',
  'flashcards': 'DEST_flashcards',
  'teach': 'DEST_teach',
  'chat': 'DEST_chat',
  'wiki': 'DEST_wiki',
  'upload': 'DEST_upload',
};

GoRouter _router() => GoRouter(
      initialLocation: '/avatar/av1',
      routes: [
        GoRoute(
          path: '/avatar/:avatarId',
          builder: (c, s) =>
              AvatarHubScreen(avatarId: s.pathParameters['avatarId']!),
        ),
        for (final e in _dests.entries)
          GoRoute(
            path: '/avatar/:avatarId/${e.key}',
            builder: (c, s) => Scaffold(body: Text(e.value)),
          ),
      ],
    );

Future<void> _pump(
  WidgetTester tester, {
  required Avatar avatar,
  int moduleCount = 3,
  int avgMastery = 40,
  bool centreClassResolved = false,
  QuizStatus? quiz,
}) async {
  // Tall viewport so the lazy ListView builds every row (Tools sits below the
  // fold on the default 800×600 test surface).
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(420, 1600);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final data = AvatarHubData(
      avatar: avatar, moduleCount: moduleCount, avgMasteryPct: avgMastery);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        avatarHubViewModelProvider(avatar.id).overrideWith(() => _StubHubVM(data)),
        quizStatusProvider(avatar.id).overrideWith(
            (ref) async => quiz ??
                const QuizStatus(
                    takenToday: false, totalTopics: 0, masteredTopics: 0)),
        // NoNotesCta's centre resolver (only consulted in the !hasKnowledge path).
        avatarIsCentreClassProvider(avatar.id)
            .overrideWith((ref) async => centreClassResolved),
      ],
      child: MaterialApp.router(routerConfig: _router()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('(a) knowledge personal avatar renders every journey section + hero stat',
      (tester) async {
    await _pump(tester, avatar: _avatar(), moduleCount: 3, avgMastery: 40);

    // Hero + all seven rows present.
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('3 modules · 40% mastery'), findsOneWidget);
    for (final t in ['Quiz', 'Cards', 'Teach', 'Chat', 'Notes', 'Upload']) {
      expect(find.text(t), findsOneWidget, reason: '$t row must render');
    }
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Prove it'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);
  });

  // (a) each row pushes its correct typed route.
  final rowToDest = {
    'Learn': 'DEST_modules',
    'Quiz': 'DEST_quiz',
    'Cards': 'DEST_flashcards',
    'Teach': 'DEST_teach',
    'Chat': 'DEST_chat',
    'Notes': 'DEST_wiki',
    'Upload': 'DEST_upload',
  };
  rowToDest.forEach((row, dest) {
    testWidgets('(a) tapping "$row" pushes $dest', (tester) async {
      await _pump(tester, avatar: _avatar());
      await tester.tap(find.text(row));
      await tester.pumpAndSettle();
      expect(find.text(dest), findsOneWidget);
    });
  });

  testWidgets('(b) !hasKnowledge disables practice/prove + shows one NoNotesCta',
      (tester) async {
    await _pump(tester, avatar: _avatar(wikiPageCount: 0), moduleCount: 0);

    // Shared unlock affordance (personal → upload button).
    expect(find.byType(NoNotesCta), findsOneWidget);
    expect(find.textContaining('Upload your notes to unlock'), findsOneWidget);

    // Quiz / Cards / Teach are disabled → tapping does not navigate.
    for (final entry in {
      'Quiz': 'DEST_quiz',
      'Cards': 'DEST_flashcards',
      'Teach': 'DEST_teach',
    }.entries) {
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsNothing,
          reason: '${entry.key} must be disabled without knowledge');
    }

    // The hero stays invitational (not disabled) and still routes to modules.
    expect(find.text('Start your first module'), findsOneWidget);
    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();
    expect(find.text('DEST_modules'), findsOneWidget);
  });

  testWidgets('(c) centre-class avatar shows the Class badge and hides Teach + Upload',
      (tester) async {
    await _pump(
      tester,
      avatar: _avatar(centreManaged: true, centreClass: true),
      centreClassResolved: true,
    );

    expect(find.text('Class'), findsOneWidget); // badge (isCentreClass)
    expect(find.text('Teach'), findsNothing); // hidden (centreManaged)
    expect(find.text('Upload'), findsNothing); // hidden (centreManaged)
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
  });

  // Sharpening 3: badge keys on isCentreClass, Teach/Upload on centreManaged —
  // pinned mechanically with the two flags DIVERGING, asserted independently.
  testWidgets('(3) centreManaged WITHOUT isCentreClass → no badge, but Teach/Upload hidden',
      (tester) async {
    await _pump(tester,
        avatar: _avatar(centreManaged: true, centreClass: false));
    expect(find.text('Class'), findsNothing); // isCentreClass false → no badge
    expect(find.text('Teach'), findsNothing); // centreManaged → hidden
    expect(find.text('Upload'), findsNothing); // centreManaged → hidden
  });

  testWidgets('(3) isCentreClass WITHOUT centreManaged → badge shown AND Teach/Upload visible',
      (tester) async {
    await _pump(tester,
        avatar: _avatar(centreManaged: false, centreClass: true));
    expect(find.text('Class'), findsOneWidget); // isCentreClass → badge
    expect(find.text('Teach'), findsOneWidget); // centreManaged false → visible
    expect(find.text('Upload'), findsOneWidget); // centreManaged false → visible
  });

  testWidgets('no overflow at 320dp and 1.3x text scale', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 720);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          avatarHubViewModelProvider('av1').overrideWith(() => _StubHubVM(
              AvatarHubData(
                  avatar: _avatar(), moduleCount: 3, avgMasteryPct: 40))),
          quizStatusProvider('av1').overrideWith((ref) async =>
              const QuizStatus(
                  takenToday: false, totalTopics: 0, masteredTopics: 0)),
        ],
        child: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: MaterialApp.router(routerConfig: _router()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
