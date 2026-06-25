import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/wiki_viewer/presentation/get_it_checked_sheet.dart';
import 'package:pally/features/wiki_viewer/presentation/review_view_model.dart';
import 'package:pally/shared/models/wiki_page.dart';

// Stub notifier — returns a static ReviewState without making any network calls.
class _FakeReviewNotifier extends ReviewViewModel {
  @override
  ReviewState build(String pageId) => const ReviewState();
}

const _stubPage = WikiPage(
  id: 'page-1',
  title: 'Chapter 1',
  slug: 'chapter-1',
  content: 'Some content',
);

Widget _wrap({required bool canEditNotes}) =>
    ProviderScope(
      overrides: [
        reviewViewModelProvider(_stubPage.id).overrideWith(
          () => _FakeReviewNotifier(),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: GetItCheckedSheet(
            avatarId: 'avatar-1',
            page: _stubPage,
            canEditNotes: canEditNotes,
          ),
        ),
      ),
    );

void main() {
  group('GetItCheckedSheet — canEditNotes guard', () {
    testWidgets(
        'centre class (canEditNotes=false): "Fix my notes" is absent',
        (tester) async {
      await tester.pumpWidget(_wrap(canEditNotes: false));
      await tester.pump();

      expect(find.text('Fix my notes'), findsNothing);
    });

    testWidgets(
        'centre class (canEditNotes=false): "Share review link" is still present',
        (tester) async {
      await tester.pumpWidget(_wrap(canEditNotes: false));
      await tester.pump();

      expect(find.text('Share review link'), findsOneWidget);
    });

    testWidgets(
        'personal Mochi (canEditNotes=true): "Fix my notes" is present',
        (tester) async {
      await tester.pumpWidget(_wrap(canEditNotes: true));
      await tester.pump();

      expect(find.text('Fix my notes'), findsOneWidget);
    });

    testWidgets(
        'personal Mochi (canEditNotes=true): "Share review link" is also present',
        (tester) async {
      await tester.pumpWidget(_wrap(canEditNotes: true));
      await tester.pump();

      expect(find.text('Share review link'), findsOneWidget);
    });
  });
}
