import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/upload/presentation/upload_screen.dart';
import 'package:pally/features/upload/presentation/upload_view_model.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/mochi_character.dart';
import 'package:pally/shared/models/upload_result.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );

void main() {
  group('UploadScreen tab bar', () {
    testWidgets('renders Type, Photo, and File tabs', (tester) async {
      await tester.pumpWidget(_wrap(
        const UploadScreen(avatarId: 'test-avatar'),
        overrides: [
          uploadViewModelProvider('test-avatar')
              .overrideWith(() => _IdleUploadVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Photo'), findsOneWidget);
      expect(find.text('File'), findsOneWidget);
    });

    testWidgets('Type tab shows text field and Add to Mochi button',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const UploadScreen(avatarId: 'test-avatar'),
        overrides: [
          uploadViewModelProvider('test-avatar')
              .overrideWith(() => _IdleUploadVM()),
        ],
      ));
      await tester.pumpAndSettle();

      // Type tab is the default/first tab
      expect(find.text('Paste or type your notes here...'), findsOneWidget);
      expect(find.text('Add to Mochi'), findsOneWidget);
      expect(find.text('Paste from clipboard'), findsOneWidget);
    });

    testWidgets('Type tab character count shows correct value',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const UploadScreen(avatarId: 'test-avatar'),
        overrides: [
          uploadViewModelProvider('test-avatar')
              .overrideWith(() => _IdleUploadVM()),
        ],
      ));
      await tester.pumpAndSettle();

      // Initially 0 chars
      expect(find.text('0 chars (min 50)'), findsOneWidget);

      // Type some text
      await tester.enterText(
          find.byType(TextField).first, 'Hello world');
      await tester.pump();

      expect(find.text('11 chars (min 50)'), findsOneWidget);
    });

    testWidgets('Type tab submit button disabled when under 50 chars',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const UploadScreen(avatarId: 'test-avatar'),
        overrides: [
          uploadViewModelProvider('test-avatar')
              .overrideWith(() => _IdleUploadVM()),
        ],
      ));
      await tester.pumpAndSettle();

      // Button should be disabled (null onPressed)
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Add to Mochi'),
      );
      expect(button.onPressed, isNull);

      // Enter 50+ characters
      await tester.enterText(
        find.byType(TextField).first,
        'A' * 60,
      );
      await tester.pump();

      // Now button should be enabled
      final enabledButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Add to Mochi'),
      );
      expect(enabledButton.onPressed, isNotNull);
    });

    testWidgets('Type tab shows subject label when avatar loaded',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const UploadScreen(avatarId: 'test-avatar'),
        overrides: [
          uploadViewModelProvider('test-avatar')
              .overrideWith(() => _WithSubjectVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Adding notes to Maths'), findsOneWidget);
    });

    testWidgets('Photo tab shows camera upload tile', (tester) async {
      await tester.pumpWidget(_wrap(
        const UploadScreen(avatarId: 'test-avatar'),
        overrides: [
          uploadViewModelProvider('test-avatar')
              .overrideWith(() => _IdleUploadVM()),
        ],
      ));
      await tester.pumpAndSettle();

      // Switch to Photo tab
      await tester.tap(find.text('Photo'));
      await tester.pumpAndSettle();

      expect(find.text('Take a photo'), findsOneWidget);
      expect(find.text('Snap your notes or textbook'), findsOneWidget);
    });

    testWidgets('File tab shows PDF upload tile', (tester) async {
      await tester.pumpWidget(_wrap(
        const UploadScreen(avatarId: 'test-avatar'),
        overrides: [
          uploadViewModelProvider('test-avatar')
              .overrideWith(() => _IdleUploadVM()),
        ],
      ));
      await tester.pumpAndSettle();

      // Switch to File tab
      await tester.tap(find.text('File'));
      await tester.pumpAndSettle();

      expect(find.text('Upload PDF'), findsOneWidget);
      expect(find.text('Choose a PDF from your device'), findsOneWidget);
    });

    testWidgets('Type tab tip text is displayed', (tester) async {
      await tester.pumpWidget(_wrap(
        const UploadScreen(avatarId: 'test-avatar'),
        overrides: [
          uploadViewModelProvider('test-avatar')
              .overrideWith(() => _IdleUploadVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(
        find.text(
            'Typed notes give the best results. Paste from Google Docs or type from your textbook.'),
        findsOneWidget,
      );
    });

    testWidgets('shows file count when files are present', (tester) async {
      await tester.pumpWidget(_wrap(
        const UploadScreen(avatarId: 'test-avatar'),
        overrides: [
          uploadViewModelProvider('test-avatar')
              .overrideWith(() => _WithFilesVM()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('2 files uploaded'), findsOneWidget);
    });
  });
}

// ── Test view model overrides ──────────────────────────────────────────────

class _IdleUploadVM extends UploadViewModel {
  @override
  UploadState build(String avatarId) => const UploadState();
}

class _WithSubjectVM extends UploadViewModel {
  @override
  UploadState build(String avatarId) => UploadState(
        avatar: Avatar(
          id: 'test-avatar',
          name: 'Test Mochi',
          subject: 'Maths',
          character: MochiCharacter.mochi,
          wikiPageCount: 0,
          createdAt: DateTime.now(),
        ),
      );
}

class _WithFilesVM extends UploadViewModel {
  @override
  UploadState build(String avatarId) => UploadState(
        files: [
          _fakeFile('file-1', 'notes.pdf'),
          _fakeFile('file-2', 'chapter-2.pdf'),
        ],
      );
}

UploadResult _fakeFile(String id, String name) => UploadResult(
      id: id,
      avatarId: 'test-avatar',
      fileName: name,
      status: UploadStatus.ready,
      pageCount: 3,
      wikiPageTitles: const [],
      uploadedAt: DateTime(2026),
    );
