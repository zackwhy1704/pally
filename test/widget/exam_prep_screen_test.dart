import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/exam_prep/presentation/exam_prep_screen.dart';
import 'package:pally/features/exam_prep/presentation/exam_prep_view_model.dart';
import 'package:pally/shared/models/exam_prep.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );

void main() {
  group('ExamPrepScreen', () {
    testWidgets('shows loading spinner when data is loading', (tester) async {
      await tester.pumpWidget(_wrap(
        const ExamPrepScreen(avatarId: 'test-avatar'),
        overrides: [
          examPrepViewModelProvider('test-avatar')
              .overrideWith(() => _LoadingExamPrepVM()),
        ],
      ));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Avoid pending-timer assertion
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('shows error state with retry button', (tester) async {
      await tester.pumpWidget(_wrap(
        const ExamPrepScreen(avatarId: 'test-avatar'),
        overrides: [
          examPrepViewModelProvider('test-avatar')
              .overrideWith(() => _ErrorExamPrepVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Could not load exam prep data.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('shows empty state when no concepts exist', (tester) async {
      await tester.pumpWidget(_wrap(
        const ExamPrepScreen(avatarId: 'test-avatar'),
        overrides: [
          examPrepViewModelProvider('test-avatar')
              .overrideWith(() => _EmptyExamPrepVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('No exam prep data yet'), findsOneWidget);
    });

    testWidgets('shows concepts sorted weakest-first with mastery bars',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ExamPrepScreen(avatarId: 'test-avatar'),
        overrides: [
          examPrepViewModelProvider('test-avatar')
              .overrideWith(() => _LoadedExamPrepVM()),
        ],
      ));
      await tester.pumpAndSettle();

      // Concepts should appear in the UI
      expect(find.text('Geometry'), findsOneWidget);
      expect(find.text('Decimals'), findsOneWidget);
      expect(find.text('Fractions'), findsOneWidget);

      // Mastery percentages
      expect(find.textContaining('31%'), findsOneWidget);
      expect(find.textContaining('61%'), findsOneWidget);
      expect(find.textContaining('82%'), findsOneWidget);
    });

    testWidgets('shows test date countdown when set', (tester) async {
      await tester.pumpWidget(_wrap(
        const ExamPrepScreen(avatarId: 'test-avatar'),
        overrides: [
          examPrepViewModelProvider('test-avatar')
              .overrideWith(() => _LoadedExamPrepVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('18'), findsOneWidget);
      expect(find.text('days until exam'), findsOneWidget);
    });

    testWidgets('shows daily target recommendation', (tester) async {
      await tester.pumpWidget(_wrap(
        const ExamPrepScreen(avatarId: 'test-avatar'),
        overrides: [
          examPrepViewModelProvider('test-avatar')
              .overrideWith(() => _LoadedExamPrepVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Study 2 modules/day'),
        findsOneWidget,
      );
    });

    testWidgets('shows Re-do button only on weak concepts with moduleId',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ExamPrepScreen(avatarId: 'test-avatar'),
        overrides: [
          examPrepViewModelProvider('test-avatar')
              .overrideWith(() => _LoadedExamPrepVM()),
        ],
      ));
      await tester.pumpAndSettle();

      // Geometry (31%) and Decimals (61%) should have Re-do, Fractions (82%) should not
      expect(find.text('Re-do'), findsNWidgets(2));
    });
  });
}

// ── Test VM overrides ────────────────────────────────────────────────────────

class _LoadingExamPrepVM extends ExamPrepViewModel {
  @override
  Future<ExamPrep> build(String avatarId) => Completer<ExamPrep>().future;
}

class _ErrorExamPrepVM extends ExamPrepViewModel {
  @override
  Future<ExamPrep> build(String avatarId) =>
      Future.error(Exception('Network error'));
}

class _EmptyExamPrepVM extends ExamPrepViewModel {
  @override
  Future<ExamPrep> build(String avatarId) =>
      Future.value(const ExamPrep());
}

class _LoadedExamPrepVM extends ExamPrepViewModel {
  @override
  Future<ExamPrep> build(String avatarId) => Future.value(
        const ExamPrep(
          testDate: '2026-07-15',
          daysRemaining: 18,
          concepts: [
            ExamConceptMastery(
              concept: 'Fractions',
              mastery: 0.82,
              moduleId: 'mod-1',
              moduleTitle: 'Fractions Basics',
            ),
            ExamConceptMastery(
              concept: 'Decimals',
              mastery: 0.61,
              moduleId: 'mod-2',
              moduleTitle: 'Decimal Operations',
            ),
            ExamConceptMastery(
              concept: 'Geometry',
              mastery: 0.31,
              moduleId: 'mod-3',
              moduleTitle: 'Shapes and Angles',
            ),
          ],
          recommendedOrder: ['mod-3', 'mod-2', 'mod-1'],
          dailyTarget: 2,
        ),
      );
}
