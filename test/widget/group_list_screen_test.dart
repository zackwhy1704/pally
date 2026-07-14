import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/groups/presentation/group_list_screen.dart';
import 'package:pally/features/groups/presentation/groups_view_model.dart';

/// FIX 2 guard: Groups is public. The old client pilot gate rendered a
/// "Coming soon" wall whenever the feature flag wasn't present — including the
/// stuck-gate failure mode where a single failed /me/flags fetch latched it all
/// session. This pins that the real screen renders unconditionally, with NO
/// feature-flags override in play (flags default empty here — the exact failure
/// state that used to show the wall).
class _EmptyGroupsVM extends GroupListViewModel {
  @override
  Future<List<StudyGroup>> build() async => const [];
}

void main() {
  testWidgets('renders the real Study Groups screen even with no flags (no stuck gate)',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          groupListViewModelProvider.overrideWith(_EmptyGroupsVM.new),
        ],
        child: const MaterialApp(home: GroupListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Real screen chrome + join-by-code card present…
    expect(find.text('Study Groups'), findsOneWidget);
    expect(find.text('Have an invite code?'), findsOneWidget);
    // …and the retired coming-soon wall is gone for good.
    expect(find.textContaining('Coming soon'), findsNothing);
    expect(find.textContaining('in pilot'), findsNothing);
  });
}
