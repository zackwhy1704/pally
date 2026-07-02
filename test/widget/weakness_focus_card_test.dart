import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/weakness/data/weakness_focus.dart';
import 'package:pally/features/weakness/data/weakness_service.dart';
import 'package:pally/features/weakness/presentation/weakness_focus_card.dart';

Future<void> _pump(WidgetTester tester, WeaknessFocus focus) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      weaknessFocusProvider('MATHS').overrideWith((ref) async => focus),
    ],
    child: const MaterialApp(
      home: Scaffold(body: WeaknessFocusCard(backendSubject: 'MATHS')),
    ),
  ));
  await tester.pump(); // resolve the future
  await tester.pump();
}

void main() {
  testWidgets('shows focus areas and wins when enabled with content',
      (tester) async {
    await _pump(
      tester,
      const WeaknessFocus(
        enabled: true,
        focusAreas: [WeaknessArea(title: 'Dividing fractions', summary: 's')],
        recentWins: ['multiplying-fractions'],
      ),
    );

    expect(find.textContaining("Let's focus on"), findsOneWidget);
    expect(find.text('Dividing fractions'), findsOneWidget);
    expect(find.textContaining('improved on'), findsOneWidget);
  });

  testWidgets('renders nothing when the pilot flag is off', (tester) async {
    await _pump(tester, WeaknessFocus.empty); // enabled: false

    expect(find.textContaining("Let's focus on"), findsNothing);
    expect(find.byType(WeaknessFocusCard), findsOneWidget); // present but empty
  });

  testWidgets('renders nothing when enabled but no content', (tester) async {
    await _pump(tester,
        const WeaknessFocus(enabled: true, focusAreas: [], recentWins: []));
    expect(find.textContaining("Let's focus on"), findsNothing);
    expect(find.textContaining('improved on'), findsNothing);
  });
}
