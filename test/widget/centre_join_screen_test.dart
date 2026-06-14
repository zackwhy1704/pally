import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/centre/presentation/centre_join_screen.dart';

Widget _host({Size size = const Size(320, 568), double textScale = 1.3}) {
  return ProviderScope(
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: const CentreJoinScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('renders code prompt, single code field and Join button',
      (tester) async {
    await tester.pumpWidget(_host());
    await tester.pump();

    expect(find.text('Join a class'), findsOneWidget);
    expect(find.text('Enter the class code'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Join class'), findsOneWidget);
  });

  testWidgets('typed code is upper-cased', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'pfdm4cyb');
    await tester.pump();

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.controller.text, 'PFDM4CYB');
  });

  testWidgets('no overflow on a small device at large text scale',
      (tester) async {
    await tester.pumpWidget(_host(size: const Size(320, 568), textScale: 1.3));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
