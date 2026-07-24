import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/modules/presentation/widgets/proof_chips.dart';
import 'package:pally/features/modules/presentation/widgets/test_body.dart';

/// feat/test-provenance-chip: the ProvenanceChip renders on all three TEST cards when
/// the item carries a sourcePageTitle, and is ABSENT on old content (null title).
void main() {
  // SpotMistakeCard's field now carries a VoiceInputButton (voice-input
  // feature), which reads a Riverpod provider — every render needs a
  // ProviderScope ancestor now.
  Widget host(Widget child) => ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: child),
          ),
        ),
      );

  final cards = <String, Widget Function({String? title, VoidCallback? onOpen})>{
    'HotTakeCard': ({title, onOpen}) => HotTakeCard(
          statement: 'The sky is green',
          verdict: null,
          verdictPending: false,
          isRevealed: false,
          answer: null,
          onAnswer: (_) {},
          sourcePageTitle: title,
          onOpenNotes: onOpen,
        ),
    'SpotMistakeCard': ({title, onOpen}) => SpotMistakeCard(
          problem: 'Solve 2x=4',
          wrongSolution: 'x=3',
          errorDescription: '',
          correctSolution: '',
          isRevealed: false,
          diagnosis: '',
          selfCheck: null,
          onReveal: (_) {},
          onSelfCheck: (_) {},
          sourcePageTitle: title,
          onOpenNotes: onOpen,
        ),
    'ChallengeCard': ({title, onOpen}) => ChallengeCard(
          question: 'Explain osmosis',
          explanation: '',
          isRevealed: false,
          answer: '',
          onSubmit: (_) {},
          sourcePageTitle: title,
          onOpenNotes: onOpen,
        ),
  };

  cards.forEach((name, build) {
    testWidgets('$name shows the provenance chip when sourcePageTitle is present',
        (tester) async {
      await tester.pumpWidget(host(build(title: 'Sales Game')));
      expect(find.byType(ProvenanceChip), findsOneWidget);
      expect(find.textContaining('From your notes: Sales Game'), findsOneWidget);
    });

    testWidgets('ABSENCE: $name shows no chip when sourcePageTitle is null (old content)',
        (tester) async {
      await tester.pumpWidget(host(build(title: null)));
      expect(find.byType(ProvenanceChip), findsNothing);
    });
  });

  testWidgets('the chip is tappable → onOpenNotes fires (HotTakeCard)', (tester) async {
    var opened = false;
    await tester.pumpWidget(
        host(cards['HotTakeCard']!(title: 'Sales Game', onOpen: () => opened = true)));
    await tester.tap(find.byType(ProvenanceChip));
    expect(opened, isTrue);
  });
}
