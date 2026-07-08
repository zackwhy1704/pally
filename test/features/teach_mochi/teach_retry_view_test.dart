import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/teach_mochi/presentation/teach_mochi_screen.dart';
import 'package:pally/features/teach_mochi/presentation/teach_mochi_view_model.dart';

void main() {
  group('TeachEvaluation.fromJson status', () {
    test('EVAL_FAILED status → evalFailed true, never a score card', () {
      final e = TeachEvaluation.fromJson({
        'score': 0,
        'totalConcepts': 0,
        'feedback': 'Could not parse feedback.',
        'status': 'EVAL_FAILED',
      });
      expect(e.evalFailed, isTrue);
    });

    test('missing status defaults to OK (back-compat with old servers)', () {
      final e = TeachEvaluation.fromJson({'score': 2, 'totalConcepts': 2});
      expect(e.evalFailed, isFalse);
    });
  });

  group('TeachRetryView', () {
    testWidgets('shows a retry, not a score; tap fires onTryAgain', (tester) async {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TeachRetryView(
            feedback: 'Could not parse feedback.',
            onTryAgain: () => tapped = true,
          ),
        ),
      ));

      expect(find.text("Mochi couldn't check this one"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      // No score-card language.
      expect(find.textContaining('Great'), findsNothing);
      expect(find.textContaining('%'), findsNothing);

      await tester.tap(find.text('Try again'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
