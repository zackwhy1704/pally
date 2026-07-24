import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/modules/presentation/widgets/proof_chips.dart';
import 'package:pally/features/modules/presentation/widgets/prove_body.dart';

/// feat/proof-chips: provenance chip, targeting badge, comeback line — plus the
/// silent-degrade rule (untagged content renders none of them).
void main() {
  // ProveQuestion's field now carries a VoiceInputButton (voice-input
  // feature), which reads a Riverpod provider — every render needs a
  // ProviderScope ancestor now.
  Widget host(Widget child) => ProviderScope(
      child: MaterialApp(home: Scaffold(body: Center(child: child))));

  group('helpers', () {
    test('weakTopicConcept parses WEAK_TOPIC:{concept}, else null', () {
      expect(weakTopicConcept('WEAK_TOPIC:Compliment bridging'), 'Compliment bridging');
      expect(weakTopicConcept('WEAK_TOPIC:'), isNull); // empty concept
      expect(weakTopicConcept(null), isNull);
      expect(weakTopicConcept('something else'), isNull);
    });

    test('isWeaknessScore: <0.5 true, >=0.5 false, null false', () {
      expect(isWeaknessScore(0.0), isTrue);
      expect(isWeaknessScore(0.49), isTrue);
      expect(isWeaknessScore(0.5), isFalse);
      expect(isWeaknessScore(0.9), isFalse);
      expect(isWeaknessScore(null), isFalse);
    });
  });

  group('widgets render', () {
    testWidgets('ProvenanceChip shows "From your notes: {title}" and is tappable',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(host(
          ProvenanceChip(pageTitle: 'Closing the Sale', onTap: () => tapped = true)));
      expect(find.textContaining('From your notes: Closing the Sale'), findsOneWidget);
      await tester.tap(find.byType(ProvenanceChip));
      expect(tapped, isTrue);
    });

    testWidgets('TargetingBadge renders its text', (tester) async {
      await tester.pumpWidget(host(
          const TargetingBadge(text: 'Reviewing your weak spot: Closing.')));
      expect(find.textContaining('Reviewing your weak spot: Closing'), findsOneWidget);
    });

    testWidgets('ComebackLine renders the payoff', (tester) async {
      await tester.pumpWidget(host(const ComebackLine(concept: 'Closing')));
      expect(find.textContaining("That's a comeback — Closing got you last time"),
          findsOneWidget);
    });
  });

  group('ProveQuestion wiring', () {
    Widget prove({String? title, String? concept, double? priorScore}) => host(
          ProveQuestion(
            questionNumber: 1,
            question: 'Explain the idea',
            answer: '',
            onChanged: (_) {},
            sourcePageTitle: title,
            targetConcept: concept,
            priorScore: priorScore,
          ),
        );

    testWidgets('tagged weak PROVE item shows chip + targeting badge', (tester) async {
      await tester.pumpWidget(
          prove(title: 'Sales Game', concept: 'Closing', priorScore: 0.0));
      expect(find.byType(ProvenanceChip), findsOneWidget);
      expect(find.textContaining('From your notes: Sales Game'), findsOneWidget);
      expect(find.byType(TargetingBadge), findsOneWidget);
      expect(find.textContaining('Focusing on Closing — this tripped you up in the Test'),
          findsOneWidget);
    });

    testWidgets('ABSENCE: untagged PROVE item renders no chip and no badge',
        (tester) async {
      await tester.pumpWidget(prove()); // all null
      expect(find.byType(ProvenanceChip), findsNothing);
      expect(find.byType(TargetingBadge), findsNothing);
    });

    testWidgets('a NON-weak PROVE item (priorScore >= 0.5) shows the chip but no badge',
        (tester) async {
      await tester.pumpWidget(
          prove(title: 'Sales Game', concept: 'Closing', priorScore: 0.8));
      expect(find.byType(ProvenanceChip), findsOneWidget);
      expect(find.byType(TargetingBadge), findsNothing);
    });
  });
}
