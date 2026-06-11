import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/modules/presentation/module_list_screen.dart';
import 'package:pally/features/modules/presentation/module_list_view_model.dart';
import 'package:pally/shared/models/learning_module.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );

void main() {
  group('ModuleListScreen', () {
    testWidgets('shows loading spinner when modules are loading',
        (tester) async {
      // Override with a Completer-based provider that stays in loading
      await tester.pumpWidget(_wrap(
        const ModuleListScreen(avatarId: 'test-avatar'),
        overrides: [
          moduleListViewModelProvider('test-avatar').overrideWith(
            () => _LoadingModuleListVM(),
          ),
        ],
      ));
      // Pump once to render the initial loading state (don't settle —
      // the future never completes).
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Avoid pending-timer assertion by discarding the widget tree
      // before the test finishes.
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('shows empty state when no modules exist', (tester) async {
      await tester.pumpWidget(_wrap(
        const ModuleListScreen(avatarId: 'test-avatar'),
        overrides: [
          moduleListViewModelProvider('test-avatar')
              .overrideWith(() => _EmptyModuleListVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('No modules yet'), findsOneWidget);
      expect(find.text('Generate modules'), findsOneWidget);
    });

    testWidgets('shows module cards when modules exist', (tester) async {
      await tester.pumpWidget(_wrap(
        const ModuleListScreen(avatarId: 'test-avatar'),
        overrides: [
          moduleListViewModelProvider('test-avatar')
              .overrideWith(() => _LoadedModuleListVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Fractions'), findsOneWidget);
      expect(find.text('Decimals'), findsOneWidget);
    });

    testWidgets('stage badge shows correct label per stage', (tester) async {
      await tester.pumpWidget(_wrap(
        const ModuleListScreen(avatarId: 'test-avatar'),
        overrides: [
          moduleListViewModelProvider('test-avatar')
              .overrideWith(() => _LoadedModuleListVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('TEST'), findsOneWidget);
      expect(find.text('COMPLETE'), findsOneWidget);
    });

    testWidgets('shows error state on load failure', (tester) async {
      await tester.pumpWidget(_wrap(
        const ModuleListScreen(avatarId: 'test-avatar'),
        overrides: [
          moduleListViewModelProvider('test-avatar')
              .overrideWith(() => _ErrorModuleListVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Could not load modules.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });
}

// ── Test view model overrides ──────────────────────────────────────────────

class _LoadingModuleListVM extends ModuleListViewModel {
  @override
  Future<List<LearningModule>> build(String avatarId) {
    // Use a Completer that never completes to stay in loading state
    return Completer<List<LearningModule>>().future;
  }
}

class _EmptyModuleListVM extends ModuleListViewModel {
  @override
  Future<List<LearningModule>> build(String avatarId) async => [];
}

class _LoadedModuleListVM extends ModuleListViewModel {
  @override
  Future<List<LearningModule>> build(String avatarId) async => const [
        LearningModule(
          id: 'mod-1',
          title: 'Fractions',
          stage: 'TEST',
          masteryPct: 0.65,
          itemCounts: {'learn': 4, 'test': 3},
        ),
        LearningModule(
          id: 'mod-2',
          title: 'Decimals',
          stage: 'COMPLETE',
          masteryPct: 1.0,
        ),
      ];
}

class _ErrorModuleListVM extends ModuleListViewModel {
  @override
  Future<List<LearningModule>> build(String avatarId) async =>
      throw Exception('Network error');
}
