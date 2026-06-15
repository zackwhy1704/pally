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

void main() {
  group('NoNotesCta', () {
    testWidgets('personal avatar shows the upload button and description',
        (tester) async {
      await tester.pumpWidget(_wrap(isCentre: false));
      await tester.pumpAndSettle();

      // Individual use: the child owns the knowledge base → may upload.
      expect(find.text('Upload notes for this Mochi.'), findsOneWidget);
      expect(find.text('Upload notes'), findsOneWidget);
      expect(find.byIcon(Icons.upload_file_rounded), findsOneWidget);
    });

    testWidgets('centre class shows the ask-teacher reminder and NO upload button',
        (tester) async {
      await tester.pumpWidget(_wrap(isCentre: true));
      await tester.pumpAndSettle();

      // Centre use: students cannot upload → reminder only, never the button.
      expect(find.textContaining('Ask your teacher'), findsOneWidget);
      expect(find.text('Upload notes'), findsNothing);
      expect(find.byIcon(Icons.upload_file_rounded), findsNothing);
    });

    testWidgets('while kind is loading, defaults to NOT showing upload button',
        (tester) async {
      // valueOrNull is null during load → treated as personal=false default,
      // i.e. no premature upload button before we know the avatar type.
      await tester.pumpWidget(_wrap(isCentre: true));
      await tester.pump(); // first frame, provider still resolving
      expect(find.text('Upload notes'), findsNothing);
    });
  });
}
