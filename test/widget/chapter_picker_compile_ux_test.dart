import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/chapters/domain/chapter.dart';
import 'package:pally/features/chapters/presentation/chapter_picker_sheet.dart';
import 'package:pally/features/chapters/presentation/chapter_picker_view_model.dart';

/// Pins the chapter-compile "no dead ends" UX contract:
///  • the Compile button's spinner/disabled state is REACTIVE (the prior plain
///    `_compiling` field never triggered a rebuild → dead spinner);
///  • single-flight — a second tap while in flight fires no second compile;
///  • EVERY DioException clears the spinner, RE-ENABLES the button, and shows an
///    honest per-cause message (never a disabled-forever button);
///  • a successful compile confirms with the "Mochi is reading" dialog that
///    points at the Library progress indicator.
class _ControlVM extends ChapterPickerViewModel {
  _ControlVM(this._result, {this.onCompile});
  final ChaptersResult _result;
  final Future<void> Function(List<String>)? onCompile;
  int compileCalls = 0;

  @override
  Future<ChaptersResult> build(String avatarId) async => _result;

  @override
  Future<void> compileSelected(List<String> ids) async {
    compileCalls++;
    if (onCompile != null) await onCompile!(ids);
  }
}

ChaptersResult _result() => const ChaptersResult(
      allowanceUsed: 3,
      allowanceLimit: 5,
      chapters: [
        Chapter(chunkId: 'c1', parentFileId: 'p', title: 'Chapter 1', pageFrom: 1, pageTo: 25, pageCount: 25, state: ChapterState.locked),
        Chapter(chunkId: 'c2', parentFileId: 'p', title: 'Chapter 2', pageFrom: 26, pageTo: 50, pageCount: 25, state: ChapterState.locked),
      ],
    );

DioException _dio(DioExceptionType type, {int? status}) {
  final ro = RequestOptions(path: '/compile');
  return DioException(
    requestOptions: ro,
    type: type,
    response: status == null ? null : Response(requestOptions: ro, statusCode: status),
  );
}

/// Opens the sheet through the REAL `showChapterPicker` entry point (a modal
/// route) so a success-`pop(true)` returns cleanly to the launcher and the
/// dialog can surface — mirroring the main-app callers.
Future<_ControlVM> _openSheet(
  WidgetTester tester, {
  Future<void> Function(List<String>)? onCompile,
  bool pointToLibrary = false,
}) async {
  late _ControlVM vm;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        chapterPickerViewModelProvider('av1').overrideWith(() {
          vm = _ControlVM(_result(), onCompile: onCompile);
          return vm;
        }),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showChapterPicker(context,
                  avatarId: 'av1', pointToLibraryOnSuccess: pointToLibrary),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return vm;
}

Finder get _compileButton => find.ancestor(
      of: find.text('Compile (1)'),
      matching: find.byType(ElevatedButton),
    );

Future<void> _selectFirstChapter(WidgetTester tester) async {
  await tester.tap(find.text('Chapter 1'));
  await tester.pump();
}

void main() {
  testWidgets('in-flight → the Compile button disables and shows a spinner (reactive)',
      (tester) async {
    final gate = Completer<void>();
    await _openSheet(tester, onCompile: (_) => gate.future);
    await _selectFirstChapter(tester);

    await tester.tap(_compileButton);
    await tester.pump(); // let setState(_compiling=true) rebuild

    // Spinner is inside the button and the button is disabled — the exact state
    // the old plain-field `_compiling` never rendered.
    expect(
      find.descendant(
          of: find.byType(ElevatedButton), matching: find.byType(CircularProgressIndicator)),
      findsOneWidget,
    );
    final btn = tester.widget<ElevatedButton>(find.ancestor(
      of: find.byType(CircularProgressIndicator),
      matching: find.byType(ElevatedButton),
    ));
    expect(btn.onPressed, isNull, reason: 'button must be disabled while compiling');

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('double-tap fires exactly one compile (single-flight guard)', (tester) async {
    final gate = Completer<void>();
    final vm = await _openSheet(tester, onCompile: (_) => gate.future);
    await _selectFirstChapter(tester);

    // Two taps with NO pump between → both hit the still-enabled button; the
    // sheet's `if (_compiling) return` guard must drop the second.
    await tester.tap(_compileButton);
    await tester.tap(_compileButton, warnIfMissed: false);
    await tester.pump();

    expect(vm.compileCalls, 1);

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('success → sheet dismisses and the "Mochi is reading" dialog appears',
      (tester) async {
    await _openSheet(tester, pointToLibrary: true); // onCompile null → succeeds
    await _selectFirstChapter(tester);

    await tester.tap(_compileButton);
    await tester.pumpAndSettle();

    expect(find.text('Mochi is reading your chapters!'), findsOneWidget);
    expect(find.text('Go to Library'), findsOneWidget);
    // Dialog is dismissible to a live screen — no all-inputs-disabled state.
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Mochi is reading your chapters!'), findsNothing);
  });

  // Every failure mode: spinner cleared, button re-enabled, honest copy shown.
  // Copy comes from the central PallyError.forCompile mapper (the widget never
  // inspects DioException). 503 maps to `server` (>=500), 409 to the friendly
  // in-progress note, timeouts point to Library.
  final cases = <String, (DioException, String)>{
    'timeout points to Library, stays retryable': (
      _dio(DioExceptionType.receiveTimeout),
      'check Library',
    ),
    'network drop asks to check WiFi': (
      _dio(DioExceptionType.connectionError),
      "You're offline",
    ),
    '5xx blames the server, not the user': (
      _dio(DioExceptionType.badResponse, status: 503),
      "Mochi's having trouble right now",
    ),
    '409 renders the friendly already-running note, not an error': (
      _dio(DioExceptionType.badResponse, status: 409),
      'Mochi is already reading these chapters',
    ),
  };

  cases.forEach((name, data) {
    final (err, expectedCopy) = data;
    testWidgets('error: $name', (tester) async {
      await _openSheet(tester, onCompile: (_) async => throw err);
      await _selectFirstChapter(tester);

      await tester.tap(_compileButton);
      await tester.pumpAndSettle();

      // Honest, per-cause copy shown.
      expect(find.textContaining(expectedCopy), findsOneWidget);
      // Spinner gone.
      expect(
        find.descendant(
            of: find.byType(ElevatedButton), matching: find.byType(CircularProgressIndicator)),
        findsNothing,
      );
      // Button RE-ENABLED — never a dead spinner / disabled-forever button.
      final btn = tester.widget<ElevatedButton>(_compileButton);
      expect(btn.onPressed, isNotNull, reason: 'retry must be available after $name');
    });
  });
}
