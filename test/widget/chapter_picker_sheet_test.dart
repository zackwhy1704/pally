import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/chapters/domain/chapter.dart';
import 'package:pally/features/chapters/presentation/chapter_picker_sheet.dart';
import 'package:pally/features/chapters/presentation/chapter_picker_view_model.dart';

class _StubVM extends ChapterPickerViewModel {
  _StubVM(this._result);
  final ChaptersResult _result;
  @override
  Future<ChaptersResult> build(String avatarId) async => _result;
}

ChaptersResult _result({int used = 3, int limit = 5}) => ChaptersResult(
      allowanceUsed: used,
      allowanceLimit: limit,
      chapters: const [
        Chapter(chunkId: 'c1', parentFileId: 'p', title: 'Chapter 1', pageFrom: 1, pageTo: 25, pageCount: 25, state: ChapterState.locked),
        Chapter(chunkId: 'c2', parentFileId: 'p', title: 'Chapter 2', pageFrom: 26, pageTo: 50, pageCount: 25, state: ChapterState.locked),
        Chapter(chunkId: 'c3', parentFileId: 'p', title: 'Chapter 3', pageFrom: 51, pageTo: 60, pageCount: 10, state: ChapterState.compiled),
      ],
    );

Future<void> _pump(WidgetTester tester, ChaptersResult r,
    {Size size = const Size(390, 800), double textScale = 1.0}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        chapterPickerViewModelProvider('av1').overrideWith(() => _StubVM(r)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
              child: const ChapterPickerSheet(avatarId: 'av1'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(); // resolve the async build
}

void main() {
  testWidgets('renders chapters + the allowance counter, nothing pre-selected', (tester) async {
    await _pump(tester, _result());

    expect(find.text('Chapter 1'), findsOneWidget);
    expect(find.text('Chapter 2'), findsOneWidget);
    expect(find.text('2 of 5 compiles left this month'), findsOneWidget); // one source
    // none pre-selected → the Compile CTA is disabled
    final compile = tester.widget<ElevatedButton>(
      find.ancestor(of: find.text('Compile'), matching: find.byType(ElevatedButton)),
    );
    expect(compile.onPressed, isNull);
  });

  testWidgets('unlimited tier shows the unlimited counter (the tier centre students resolve to)',
      (tester) async {
    await _pump(tester, _result(limit: -1));
    expect(find.text('Unlimited chapter compiles'), findsOneWidget);
  });

  testWidgets('the sheet carries NO price string and no external purchase CTA (iOS-safe)',
      (tester) async {
    await _pump(tester, _result());
    // The paywall (gated) is the ONLY place an upgrade path appears. The sheet
    // itself must never show a price or a purchase link.
    expect(find.textContaining(r'$'), findsNothing);
    expect(find.textContaining('Upgrade'), findsNothing);
    expect(find.byType(TextButton), findsNothing); // no in-sheet upgrade link
  });

  testWidgets('no overflow at 320dp and 2.0x text scale', (tester) async {
    await _pump(tester, _result(), size: const Size(320, 640), textScale: 2.0);
    expect(tester.takeException(), isNull);
  });
}
