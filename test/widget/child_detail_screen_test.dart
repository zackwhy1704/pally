import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/parent/presentation/child_dashboard_view_model.dart';
import 'package:pally/features/parent/presentation/child_detail_screen.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(400, 1400)),
          child: child,
        ),
      ),
    );

const _kDash = ChildDashboard(
  childName: 'Alice',
  sessionsThisWeek: 12,
  minutesThisWeek: 90,
  xpThisWeek: 350,
  streakDays: 4,
  subjects: [],
  weakAreas: [],
  modulesCompleted: 5,
  modulesTotal: 10,
);

void main() {
  group('ChildDetailScreen', () {
    testWidgets('shows loading spinner initially', (tester) async {
      final completer = Completer<ChildDashboard>();
      await tester.pumpWidget(_wrap(
        const ChildDetailScreen(childId: 'c1'),
        overrides: [
          childDashboardProvider('c1')
              .overrideWith((ref) => completer.future),
        ],
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('shows error view when provider throws', (tester) async {
      await tester.pumpWidget(_wrap(
        const ChildDetailScreen(childId: 'c1'),
        overrides: [
          childDashboardProvider('c1').overrideWith(
              (ref) async => throw Exception('Network error')),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Could not load data.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('shows child name and action buttons on success',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ChildDetailScreen(childId: 'c1'),
        overrides: [
          childDashboardProvider('c1').overrideWith((ref) async => _kDash),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Assign Revision'), findsOneWidget);
      expect(find.text('Award Stars'), findsOneWidget);
      expect(find.text('Set Weekly Goal'), findsOneWidget);
    });

    testWidgets('shows module progress bar on success', (tester) async {
      await tester.pumpWidget(_wrap(
        const ChildDetailScreen(childId: 'c1'),
        overrides: [
          childDashboardProvider('c1').overrideWith((ref) async => _kDash),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('5 / 10 completed'), findsOneWidget);
    });
  });
}
