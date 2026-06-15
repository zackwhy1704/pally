import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/core/ui/no_notes_cta.dart';
import 'package:pally/features/brain_map/presentation/brain_map_screen.dart';
import 'package:pally/features/brain_map/presentation/brain_map_view_model.dart';

// Stub notifier used to satisfy the AsyncNotifierProvider contract.
class _FakeBrainMapNotifier extends BrainMapViewModel {
  _FakeBrainMapNotifier(this._state);
  final BrainMapState _state;

  @override
  Future<BrainMapState> build(String avatarId) async => _state;
}

Widget _wrap({
  required String avatarId,
  required BrainMapState brainMapState,
  required bool isCentre,
}) =>
    ProviderScope(
      overrides: [
        brainMapViewModelProvider(avatarId).overrideWith(
          () => _FakeBrainMapNotifier(brainMapState),
        ),
        avatarIsCentreClassProvider(avatarId)
            .overrideWith((ref) async => isCentre),
      ],
      child: MaterialApp(
        home: BrainMapScreen(avatarId: avatarId),
      ),
    );

void main() {
  const emptyState = BrainMapState(nodes: [], isLoading: false);

  group('BrainMapScreen empty state via NoNotesCta', () {
    testWidgets(
        'centre class shows ask-teacher message and no upload button',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          avatarId: 'avatar1',
          brainMapState: emptyState,
          isCentre: true,
        ),
      );
      await tester.pumpAndSettle();

      // Centre class: no upload affordance, ever.
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.textContaining('Upload'), findsNothing);
      expect(find.byIcon(Icons.upload_file_rounded), findsNothing);
    });

    testWidgets(
        'personal Mochi shows Upload button in the empty state',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          avatarId: 'avatar1',
          brainMapState: emptyState,
          isCentre: false,
        ),
      );
      await tester.pumpAndSettle();

      // Personal avatar: the upload button must be present.
      expect(find.textContaining('Upload'), findsWidgets);
      expect(find.byIcon(Icons.upload_file_rounded), findsOneWidget);
    });
  });
}
