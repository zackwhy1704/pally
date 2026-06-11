import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/parent/presentation/parent_home_screen.dart';
import 'package:pally/features/parent/presentation/parent_home_view_model.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );

void main() {
  group('ParentHomeScreen', () {
    testWidgets('shows loading spinner when data is loading', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParentHomeScreen(),
        overrides: [
          parentHomeViewModelProvider
              .overrideWith(() => _LoadingParentHomeVM()),
        ],
      ));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Clean up
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('shows empty state when no children are linked',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ParentHomeScreen(),
        overrides: [
          parentHomeViewModelProvider
              .overrideWith(() => _EmptyParentHomeVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(
          find.text('Link your first child to see their progress'),
          findsOneWidget);
      expect(find.text('Link a child'), findsOneWidget);
    });

    testWidgets('shows child card with name and stats', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParentHomeScreen(),
        overrides: [
          parentHomeViewModelProvider
              .overrideWith(() => _LoadedParentHomeVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('5 days'), findsOneWidget);
      expect(find.text('120 min'), findsOneWidget);
      expect(find.text('On track'), findsOneWidget);
    });

    testWidgets('shows green status chip for on_track child',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ParentHomeScreen(),
        overrides: [
          parentHomeViewModelProvider
              .overrideWith(() => _LoadedParentHomeVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('On track'), findsOneWidget);
    });

    testWidgets('shows amber status chip for behind child', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParentHomeScreen(),
        overrides: [
          parentHomeViewModelProvider
              .overrideWith(() => _BehindChildVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Behind'), findsOneWidget);
    });

    testWidgets('shows coral status chip for needs_attention child',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ParentHomeScreen(),
        overrides: [
          parentHomeViewModelProvider
              .overrideWith(() => _NeedsAttentionChildVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Needs attention'), findsOneWidget);
    });
  });
}

class _LoadingParentHomeVM extends ParentHomeViewModel {
  @override
  ParentHomeState build() =>
      const ParentHomeState(isLoading: true, parentName: 'Parent');
}

class _EmptyParentHomeVM extends ParentHomeViewModel {
  @override
  ParentHomeState build() =>
      const ParentHomeState(parentName: 'Parent', children: []);
}

class _LoadedParentHomeVM extends ParentHomeViewModel {
  @override
  ParentHomeState build() => const ParentHomeState(
        parentName: 'Parent',
        children: [
          ParentChildSummary(
            childId: 'c1',
            name: 'Alice',
            subject: 'Maths',
            level: 5,
            streakDays: 5,
            minutesThisWeek: 120,
            modulesCompleted: 8,
            statusChip: 'on_track',
          ),
        ],
      );
}

class _BehindChildVM extends ParentHomeViewModel {
  @override
  ParentHomeState build() => const ParentHomeState(
        parentName: 'Parent',
        children: [
          ParentChildSummary(
            childId: 'c2',
            name: 'Bob',
            subject: 'Science',
            level: 3,
            streakDays: 1,
            minutesThisWeek: 30,
            modulesCompleted: 2,
            statusChip: 'behind',
          ),
        ],
      );
}

class _NeedsAttentionChildVM extends ParentHomeViewModel {
  @override
  ParentHomeState build() => const ParentHomeState(
        parentName: 'Parent',
        children: [
          ParentChildSummary(
            childId: 'c3',
            name: 'Charlie',
            subject: 'English',
            level: 2,
            streakDays: 0,
            minutesThisWeek: 5,
            modulesCompleted: 0,
            statusChip: 'needs_attention',
          ),
        ],
      );
}
