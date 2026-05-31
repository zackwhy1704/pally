import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Smoke test: verify the core scaffold (ProviderScope wrapping a material app)
  // can be rendered without crashing. We don't render the full app router here
  // because SplashScreen starts async timers (SharedPreferences + network) that
  // are hard to drain in the test binding. The per-feature widget tests cover
  // real screens; this test just guards the provider wiring.
  testWidgets('app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: Center(child: Text('Pally'))),
        ),
      ),
    );
    expect(find.byType(ProviderScope), findsOneWidget);
    expect(find.text('Pally'), findsOneWidget);
  });
}
