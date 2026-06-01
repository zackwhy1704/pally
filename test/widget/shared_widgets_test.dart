import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/shared/widgets/app_button.dart';
import 'package:pally/shared/widgets/app_card.dart';
import 'package:pally/shared/widgets/app_error_view.dart';
import 'package:pally/shared/widgets/app_empty_view.dart';
import 'package:pally/shared/widgets/app_async.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(home: Scaffold(body: child)));

void main() {
  group('AppButton', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppButton(label: 'Tap me'),
      ));
      expect(find.text('Tap me'), findsOneWidget);
    });

    testWidgets('isLoading shows spinner and disables tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Submit',
          isLoading: true,
          onPressed: () => tapped = true,
        ),
      ));
      // Spinner present, label absent while loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(tapped, isFalse);
    });

    testWidgets('enabled=false disables tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Disabled',
          enabled: false,
          onPressed: () => tapped = true,
        ),
      ));
      await tester.tap(find.byType(AppButton));
      expect(tapped, isFalse);
    });

    testWidgets('onPressed fires when enabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Go',
          onPressed: () => tapped = true,
        ),
      ));
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });
  });

  group('AppCard', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppCard(child: Text('Card content')),
      ));
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('onTap fires', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        AppCard(onTap: () => tapped = true, child: const Text('Tap')),
      ));
      await tester.tap(find.byType(AppCard));
      expect(tapped, isTrue);
    });
  });

  group('AppErrorView', () {
    testWidgets('shows message', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppErrorView(message: 'Network error'),
      ));
      expect(find.text('Network error'), findsOneWidget);
    });

    testWidgets('retry button fires callback', (tester) async {
      var retried = false;
      await tester.pumpWidget(_wrap(
        AppErrorView(
          message: 'Oops',
          onRetry: () => retried = true,
        ),
      ));
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });

    testWidgets('no retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppErrorView(message: 'Error'),
      ));
      expect(find.text('Try again'), findsNothing);
    });
  });

  group('AppEmptyView', () {
    testWidgets('renders message and emoji', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppEmptyView(message: 'Nothing here'),
      ));
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('🧠'), findsOneWidget);
    });
  });

  group('AppAsync', () {
    testWidgets('loading state shows spinner', (tester) async {
      await tester.pumpWidget(_wrap(
        AppAsync<String>(
          value: const AsyncLoading(),
          data: (s) => Text(s),
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('data state calls data builder', (tester) async {
      await tester.pumpWidget(_wrap(
        AppAsync<String>(
          value: const AsyncData('hello'),
          data: (s) => Text(s),
        ),
      ));
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('error state shows AppErrorView', (tester) async {
      await tester.pumpWidget(_wrap(
        AppAsync<String>(
          value: AsyncError(Exception('boom'), StackTrace.empty),
          data: (s) => Text(s),
        ),
      ));
      expect(find.byType(AppErrorView), findsOneWidget);
    });

    testWidgets('retry callback in error state', (tester) async {
      var retried = false;
      await tester.pumpWidget(_wrap(
        AppAsync<String>(
          value: AsyncError(Exception('fail'), StackTrace.empty),
          data: (s) => Text(s),
          onRetry: () => retried = true,
        ),
      ));
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });

    testWidgets('empty state when isEmpty returns true', (tester) async {
      await tester.pumpWidget(_wrap(
        AppAsync<List<String>>(
          value: const AsyncData([]),
          data: (list) => ListView(children: list.map(Text.new).toList()),
          isEmpty: (list) => list.isEmpty,
          emptyMessage: 'Nothing to show',
        ),
      ));
      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text('Nothing to show'), findsOneWidget);
    });
  });
}
