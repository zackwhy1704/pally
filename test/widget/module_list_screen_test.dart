import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/ui/no_notes_cta.dart';
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
          moduleAvatarInfoProvider('test-avatar').overrideWith((ref) =>
              const ModuleAvatarInfo(hasNotes: true, isCentreClass: false)),
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
          // Personal avatar, no notes → exactly one CTA: "Upload notes".
          moduleAvatarInfoProvider('test-avatar').overrideWith(
              (ref) => const ModuleAvatarInfo(hasNotes: false, isCentreClass: false)),
          // No-notes branch delegates to NoNotesCta, which resolves kind here.
          avatarIsCentreClassProvider('test-avatar')
              .overrideWith((ref) async => false),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('No lessons yet'), findsOneWidget);
      expect(find.text('Upload notes'), findsOneWidget);
      // The contradictory "already added notes?" CTA is gone — single CTA only.
      expect(find.text('Build my first lesson'), findsNothing);
    });

    testWidgets('empty state shows the build CTA when notes already exist',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ModuleListScreen(avatarId: 'test-avatar'),
        overrides: [
          moduleListViewModelProvider('test-avatar')
              .overrideWith(() => _EmptyModuleListVM()),
          moduleAvatarInfoProvider('test-avatar').overrideWith(
              (ref) => const ModuleAvatarInfo(hasNotes: true, isCentreClass: false)),
        ],
      ));
      await tester.pumpAndSettle();

      // Notes exist but no modules → single CTA is "Build my first lesson".
      expect(find.text('Build my first lesson'), findsOneWidget);
      expect(find.text('Upload notes'), findsNothing);
    });

    testWidgets('empty centre class shows ask-teacher message and NO button',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ModuleListScreen(avatarId: 'test-avatar'),
        overrides: [
          moduleListViewModelProvider('test-avatar')
              .overrideWith(() => _EmptyModuleListVM()),
          moduleAvatarInfoProvider('test-avatar').overrideWith(
              (ref) => const ModuleAvatarInfo(hasNotes: false, isCentreClass: true)),
          avatarIsCentreClassProvider('test-avatar')
              .overrideWith((ref) async => true),
        ],
      ));
      await tester.pumpAndSettle();

      // Centre + no notes → static "ask your teacher" text, ZERO tap action.
      expect(find.textContaining('Ask your teacher'), findsOneWidget);
      expect(find.text('Generate lessons'), findsNothing);
      expect(find.text('Upload notes'), findsNothing);
    });

    testWidgets('centre class WITH notes offers Generate lessons (no upload)',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ModuleListScreen(avatarId: 'test-avatar'),
        overrides: [
          moduleListViewModelProvider('test-avatar')
              .overrideWith(() => _EmptyModuleListVM()),
          moduleAvatarInfoProvider('test-avatar').overrideWith(
              (ref) => const ModuleAvatarInfo(hasNotes: true, isCentreClass: true)),
        ],
      ));
      await tester.pumpAndSettle();

      // Notes exist → generation works, so the Generate button is valid.
      expect(find.text('Generate lessons'), findsOneWidget);
      expect(find.text('Upload notes'), findsNothing);
    });

    testWidgets('shows module cards when modules exist', (tester) async {
      await tester.pumpWidget(_wrap(
        const ModuleListScreen(avatarId: 'test-avatar'),
        overrides: [
          moduleListViewModelProvider('test-avatar')
              .overrideWith(() => _LoadedModuleListVM()),
          moduleAvatarInfoProvider('test-avatar').overrideWith((ref) =>
              const ModuleAvatarInfo(hasNotes: true, isCentreClass: false)),
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
          moduleAvatarInfoProvider('test-avatar').overrideWith((ref) =>
              const ModuleAvatarInfo(hasNotes: true, isCentreClass: false)),
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
          moduleAvatarInfoProvider('test-avatar').overrideWith((ref) =>
              const ModuleAvatarInfo(hasNotes: true, isCentreClass: false)),
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
