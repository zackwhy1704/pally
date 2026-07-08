import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/chapters/domain/chapter.dart';
import 'package:pally/features/chapters/presentation/chapter_lock_banner.dart';
import 'package:pally/features/chapters/presentation/chapter_picker_view_model.dart';

// Simulates an OLD backend: GET /chapters 404s → the provider lands in error.
class _ErrorVM extends ChapterPickerViewModel {
  @override
  Future<ChaptersResult> build(String avatarId) => throw Exception('simulated 404');
}

class _StubVM extends ChapterPickerViewModel {
  _StubVM(this._result);
  final ChaptersResult _result;
  @override
  Future<ChaptersResult> build(String avatarId) async => _result;
}

Future<void> _pump(WidgetTester tester, ChapterPickerViewModel vm) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [chapterPickerViewModelProvider('av').overrideWith(() => vm)],
      child: const MaterialApp(home: Scaffold(body: ChapterLockBanner(avatarId: 'av'))),
    ),
  );
  await tester.pumpAndSettle();
}

ChaptersResult _withLocked(int n) => ChaptersResult(
      allowanceUsed: 0,
      allowanceLimit: 5,
      chapters: List.generate(
        n,
        (i) => Chapter(
            chunkId: 'c$i', parentFileId: 'p', title: 'Ch $i',
            pageFrom: 1, pageTo: 25, pageCount: 25, state: ChapterState.locked),
      ),
    );

void main() {
  testWidgets('SKEW ARMOR: /chapters error (old backend 404) → hidden, NO error dialog',
      (tester) async {
    await _pump(tester, _ErrorVM());

    // No crash, no error dialog/exception surfaced — just a clean hide.
    expect(tester.takeException(), isNull);
    expect(find.textContaining('not compiled yet'), findsNothing);
    expect(find.text('Choose'), findsNothing);
    // The banner is a zero-size shrink — it occupies no visible row.
    expect(find.byType(ChapterLockBanner), findsOneWidget); // present but renders nothing
  });

  testWidgets('data with locked chapters → shows the return-loop card', (tester) async {
    await _pump(tester, _StubVM(_withLocked(2)));
    expect(find.textContaining('2 chapters not compiled yet'), findsOneWidget);
    expect(find.text('Choose'), findsOneWidget);
  });

  testWidgets('data with no locked chapters → hidden', (tester) async {
    await _pump(tester, _StubVM(_withLocked(0)));
    expect(find.text('Choose'), findsNothing);
    expect(find.textContaining('not compiled'), findsNothing);
  });
}
