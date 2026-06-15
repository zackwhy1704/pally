import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/ui/no_notes_cta.dart';

Widget _wrap({required bool isCentre}) => ProviderScope(
      overrides: [
        avatarIsCentreClassProvider('a1').overrideWith((ref) async => isCentre),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: NoNotesCta(
            avatarId: 'a1',
            personalDescription: 'Upload notes for this Mochi.',
          ),
        ),
      ),
    );

/// Provider backed by a Completer that is never resolved — simulates a genuine
/// loading state without leaving a pending timer in the fake clock.
Widget _wrapLoading() {
  final completer = Completer<bool>();
  return ProviderScope(
      overrides: [
        avatarIsCentreClassProvider('a1').overrideWith((_) => completer.future),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: NoNotesCta(
            avatarId: 'a1',
            personalDescription: 'Upload notes for this Mochi.',
          ),
        ),
      ),
    );
}

void main() {
  group('NoNotesCta', () {
    testWidgets('personal avatar shows the upload button and description',
        (tester) async {
      await tester.pumpWidget(_wrap(isCentre: false));
      await tester.pumpAndSettle();

      expect(find.text('Upload notes for this Mochi.'), findsOneWidget);
      expect(find.text('Upload notes'), findsOneWidget);
      expect(find.byIcon(Icons.upload_file_rounded), findsOneWidget);
    });

    testWidgets('centre class shows the ask-teacher reminder and NO upload button',
        (tester) async {
      await tester.pumpWidget(_wrap(isCentre: true));
      await tester.pumpAndSettle();

      expect(find.textContaining('Ask your teacher'), findsOneWidget);
      expect(find.text('Upload notes'), findsNothing);
      expect(find.byIcon(Icons.upload_file_rounded), findsNothing);
    });

    testWidgets(
        'while kind is still resolving, shows nothing — no personal text, no upload button',
        (tester) async {
      await tester.pumpWidget(_wrapLoading());
      await tester.pump(); // one frame — provider has not resolved yet

      // The null-guard in NoNotesCta must render SizedBox.shrink(): no text, no button.
      expect(find.text('Upload notes for this Mochi.'), findsNothing);
      expect(find.text('Upload notes'), findsNothing);
      expect(find.byIcon(Icons.upload_file_rounded), findsNothing);
      expect(find.textContaining('Ask your teacher'), findsNothing);
    });
  });
}
