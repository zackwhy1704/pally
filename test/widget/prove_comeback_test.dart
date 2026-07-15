import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';
import 'package:pally/features/modules/presentation/widgets/proof_chips.dart';
import 'package:pally/features/modules/presentation/widgets/self_assess_body.dart';

/// feat/prove-comeback: the comeback line shows on a POSITIVE self-report (YES) of a PROVE
/// concept the student got wrong in the Test (priorScore < 0.5) — render-only, never on
/// Partly/No, never when the concept wasn't a prior weakness.
void main() {
  SelfAssessItem item({double? priorScore, String? concept = 'Closing'}) =>
      SelfAssessItem(
        itemId: 'i1',
        question: 'Explain closing',
        yourAnswer: 'my answer',
        reference: 'the reference',
        priorScore: priorScore,
        targetConcept: concept,
      );

  Widget host(SelfAssessItem it, Map<String, String> reports) => MaterialApp(
        home: Scaffold(
          body: SelfAssessBody(
            items: [it],
            reports: reports,
            onReport: (_, __) {},
            onDone: () {},
          ),
        ),
      );

  testWidgets('YES on a weak concept shows the comeback line', (tester) async {
    await tester.pumpWidget(host(item(priorScore: 0.0), {'i1': 'YES'}));
    expect(find.byType(ComebackLine), findsOneWidget);
    expect(find.textContaining("That's a comeback — Closing got you last time"),
        findsOneWidget);
  });

  testWidgets('ABSENCE: PARTLY → no comeback', (tester) async {
    await tester.pumpWidget(host(item(priorScore: 0.0), {'i1': 'PARTLY'}));
    expect(find.byType(ComebackLine), findsNothing);
  });

  testWidgets('ABSENCE: NO → no comeback', (tester) async {
    await tester.pumpWidget(host(item(priorScore: 0.0), {'i1': 'NO'}));
    expect(find.byType(ComebackLine), findsNothing);
  });

  testWidgets('ABSENCE: no report yet → no comeback', (tester) async {
    await tester.pumpWidget(host(item(priorScore: 0.0), const {}));
    expect(find.byType(ComebackLine), findsNothing);
  });

  testWidgets('ABSENCE: YES but priorScore >= 0.5 (not a prior weakness) → no comeback',
      (tester) async {
    await tester.pumpWidget(host(item(priorScore: 0.9), {'i1': 'YES'}));
    expect(find.byType(ComebackLine), findsNothing);
  });

  testWidgets('ABSENCE: YES but priorScore null (reinforcement/old content) → no comeback',
      (tester) async {
    await tester.pumpWidget(host(item(priorScore: null), {'i1': 'YES'}));
    expect(find.byType(ComebackLine), findsNothing);
  });
}
