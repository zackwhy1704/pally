import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/groups/presentation/group_detail_screen.dart';
import 'package:pally/features/groups/presentation/groups_view_model.dart';

// ── Stub helpers ──────────────────────────────────────────────────────────────

class _StubGroupDetail extends GroupDetailViewModel {
  _StubGroupDetail(this._detail);
  final GroupDetail _detail;
  @override
  Future<GroupDetail> build(String groupId) async => _detail;
}

class _StubGroupList extends GroupListViewModel {
  _StubGroupList(this._groups);
  final List<StudyGroup> _groups;
  @override
  Future<List<StudyGroup>> build() async => _groups;
}

Widget _wrap(GroupDetail detail) {
  return ProviderScope(
    overrides: [
      groupDetailViewModelProvider('g1').overrideWith(
        () => _StubGroupDetail(detail),
      ),
      groupListViewModelProvider.overrideWith(
        () => _StubGroupList(const []),
      ),
    ],
    child: const MaterialApp(
      home: GroupDetailScreen(groupId: 'g1'),
    ),
  );
}

const _baseGroup = StudyGroup(
  id: 'g1',
  name: 'Science Squad',
  subject: 'Science',
  inviteCode: 'AB12CD',
  memberCount: 1,
);

const _member = GroupMember(
  userId: 'u1',
  displayName: 'Alex',
  role: 'OWNER',
);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('shows back button in AppBar', (tester) async {
    await tester.pumpWidget(_wrap(const GroupDetail(
      group: _baseGroup,
      members: [_member],
      sharedNotes: [],
    )));
    await tester.pump();
    // BackButton is present — G2 fix
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('shows invite code and copy affordance', (tester) async {
    await tester.pumpWidget(_wrap(const GroupDetail(
      group: _baseGroup,
      members: [_member],
      sharedNotes: [],
    )));
    await tester.pump();
    expect(find.text('AB12CD'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('empty notes shows guidance + library button', (tester) async {
    await tester.pumpWidget(_wrap(const GroupDetail(
      group: _baseGroup,
      members: [_member],
      sharedNotes: [],
    )));
    await tester.pump();
    expect(find.text('No notes shared yet'), findsOneWidget);
    expect(find.text('Go to Library'), findsOneWidget);
  });

  testWidgets('shared note appears as a tappable row', (tester) async {
    final note = SharedNote(
      id: 'n1',
      wikiPageId: 'wp1',
      avatarId: 'av1',
      title: 'Photosynthesis',
      sharedBy: 'Alex',
      sharedAt: DateTime(2025),
    );
    await tester.pumpWidget(_wrap(GroupDetail(
      group: _baseGroup,
      members: const [_member],
      sharedNotes: [note],
    )));
    await tester.pump();
    expect(find.text('Photosynthesis'), findsOneWidget);
    // Chevron signals it's tappable
    expect(find.byIcon(Icons.chevron_right_rounded), findsAtLeastNWidgets(1));
  });

  testWidgets('note with empty avatarId renders title but is not navigable',
      (tester) async {
    final note = SharedNote(
      id: 'n2',
      wikiPageId: 'wp2',
      avatarId: '',
      title: 'Orphaned note',
      sharedBy: 'Bob',
      sharedAt: DateTime(2025),
    );
    await tester.pumpWidget(_wrap(GroupDetail(
      group: _baseGroup,
      members: const [_member],
      sharedNotes: [note],
    )));
    await tester.pump();
    expect(find.text('Orphaned note'), findsOneWidget);
    // _ShareNudge (shown when notes list is non-empty) contributes exactly one
    // chevron; the note tile itself must NOT add a second one.
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
  });

  testWidgets('purpose line is visible', (tester) async {
    await tester.pumpWidget(_wrap(const GroupDetail(
      group: _baseGroup,
      members: [_member],
      sharedNotes: [],
    )));
    await tester.pump();
    expect(
      find.textContaining('Share your best notes'),
      findsOneWidget,
    );
  });
}
