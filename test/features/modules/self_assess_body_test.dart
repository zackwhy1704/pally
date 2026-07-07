import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';
import 'package:pally/features/modules/presentation/widgets/self_assess_body.dart';

void main() {
  const items = [
    SelfAssessItem(
      itemId: 'i1',
      question: 'Explain photosynthesis.',
      yourAnswer: 'Plants make food from light.',
      reference: '• light reaction\n• Calvin cycle',
      feedback: 'Good start!',
    ),
  ];

  Widget harness({
    Map<String, String> reports = const {},
    void Function(String, String)? onReport,
    VoidCallback? onDone,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SelfAssessBody(
          items: items,
          reports: reports,
          onReport: onReport ?? (_, __) {},
          onDone: onDone ?? () {},
        ),
      ),
    );
  }

  testWidgets('renders the question, reference, and the three self-report choices',
      (tester) async {
    await tester.pumpWidget(harness());

    expect(find.text('Explain photosynthesis.'), findsOneWidget);
    expect(find.textContaining('Calvin cycle'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('Partly'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
  });

  testWidgets('tapping a choice reports the mapped YES/PARTLY/NO value with itemId',
      (tester) async {
    final calls = <List<String>>[];
    await tester.pumpWidget(harness(onReport: (id, r) => calls.add([id, r])));

    await tester.tap(find.text('Partly'));
    await tester.pump();

    expect(calls, [
      ['i1', 'PARTLY'],
    ]);
  });

  testWidgets('Continue is always enabled (self-assessment is non-blocking)',
      (tester) async {
    var done = false;
    await tester.pumpWidget(harness(onDone: () => done = true));

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(done, isTrue);
  });

  testWidgets('no overflow at 320dp width and 2.0x text scale', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: Scaffold(
          body: SelfAssessBody(
            items: items,
            reports: const {},
            onReport: (_, __) {},
            onDone: () {},
          ),
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
  });
}
