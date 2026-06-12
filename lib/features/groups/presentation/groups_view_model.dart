import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

part 'groups_view_model.g.dart';

@immutable
class StudyGroup {
  const StudyGroup({
    required this.id,
    required this.name,
    required this.subject,
    required this.inviteCode,
    required this.memberCount,
    this.groupType = 'PEER',
    this.classId,
  });
  final String id;
  final String name;
  final String? subject;
  final String inviteCode;
  final int memberCount;

  /// "PEER" (student-run study group) or "CLASS" (centre-managed class group).
  /// CLASS groups hide join/leave/kick controls — students get 403 on those.
  final String groupType;

  /// Set only for CLASS groups; links the group to a centre class.
  final String? classId;

  /// True for a centre-managed class group (members can't join/leave/kick).
  bool get isClassGroup => groupType.toUpperCase() == 'CLASS';

  static StudyGroup fromJson(Map<String, dynamic> j) => StudyGroup(
        id: j['id'] as String,
        name: (j['name'] as String?) ?? '',
        subject: j['subject'] as String?,
        inviteCode: (j['inviteCode'] as String?) ?? '',
        memberCount: (j['memberCount'] as num?)?.toInt() ?? 0,
        // Defensive: peer groups omit groupType, so default to PEER.
        groupType: (j['groupType'] as String?) ?? 'PEER',
        classId: j['classId'] as String?,
      );
}

@immutable
class GroupMember {
  const GroupMember(
      {required this.userId, required this.displayName, required this.role});
  final String userId;
  final String displayName;
  final String role;
}

@immutable
class SharedNote {
  const SharedNote({
    required this.id,
    required this.wikiPageId,
    required this.avatarId,
    required this.title,
    required this.sharedBy,
    required this.sharedAt,
    this.relevanceStatus = 'OK',
  });
  final String id;
  final String wikiPageId;
  final String avatarId;
  final String title;
  final String sharedBy;
  final DateTime sharedAt;
  final String relevanceStatus;
}

@immutable
class ShareResult {
  const ShareResult({
    required this.id,
    required this.relevanceStatus,
    required this.xpGranted,
    required this.starsGranted,
  });
  final String id;
  final String relevanceStatus;
  final int xpGranted;
  final int starsGranted;

  bool get wasBlocked => relevanceStatus == 'BLOCKED';
  bool get earnedReward => xpGranted > 0;
}

@immutable
class GroupDetail {
  const GroupDetail({
    required this.group,
    required this.members,
    required this.sharedNotes,
  });
  final StudyGroup group;
  final List<GroupMember> members;
  final List<SharedNote> sharedNotes;
}

@riverpod
class GroupListViewModel extends _$GroupListViewModel {
  @override
  Future<List<StudyGroup>> build() async => _fetch();

  Future<List<StudyGroup>> _fetch() async {
    try {
      final dio = ref.read(dioProvider);
      final response =
          await dio.get<Map<String, dynamic>>('/api/v1/groups');
      final data = (response.data?['data'] is Map
              ? response.data!['data']
              : response.data) as Map<String, dynamic>;
      final list = (data['groups'] as List?) ?? const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(StudyGroup.fromJson)
          .toList();
    } on DioException catch (e) {
      appLog.w('[Groups] list failed: ${e.message}');
      return const [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncValue.data(await _fetch());
  }

  Future<StudyGroup?> create({
    required String name,
    String? subject,
  }) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/groups',
        data: {'name': name, if (subject != null) 'subject': subject},
      );
      final data = (response.data?['data'] is Map
              ? response.data!['data']
              : response.data) as Map<String, dynamic>;
      await refresh();
      return StudyGroup.fromJson(data);
    } on DioException catch (e) {
      appLog.w('[Groups] create failed: ${e.message}');
      return null;
    }
  }

  Future<StudyGroup?> join(String inviteCode) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/groups/join',
        data: {'inviteCode': inviteCode},
      );
      final data = (response.data?['data'] is Map
              ? response.data!['data']
              : response.data) as Map<String, dynamic>;
      await refresh();
      return StudyGroup.fromJson(data);
    } on DioException catch (e) {
      appLog.w('[Groups] join failed: ${e.message}');
      return null;
    }
  }

  Future<void> leave(String groupId) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete<void>('/api/v1/groups/$groupId/leave');
      await refresh();
    } on DioException catch (e) {
      appLog.w('[Groups] leave failed: ${e.message}');
    }
  }

  /// Share a wiki page to a specific group. Returns a [ShareResult] so the
  /// caller can toast the reward and handle the BLOCKED case gracefully.
  Future<ShareResult> shareToGroup({
    required String groupId,
    required String wikiPageId,
    required String title,
  }) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/groups/$groupId/share',
        data: {'wikiPageId': wikiPageId, 'title': title},
      );
      final data = (response.data?['data'] is Map
              ? response.data!['data']
              : response.data) as Map<String, dynamic>;
      return ShareResult(
        id: (data['id'] as String?) ?? '',
        relevanceStatus: (data['relevanceStatus'] as String?) ?? 'OK',
        xpGranted: (data['xpGranted'] as num?)?.toInt() ?? 0,
        starsGranted: (data['starsGranted'] as num?)?.toInt() ?? 0,
      );
    } on DioException catch (e) {
      appLog.w('[Groups] shareToGroup failed: ${e.message}');
      rethrow;
    }
  }
}

@riverpod
class GroupDetailViewModel extends _$GroupDetailViewModel {
  @override
  Future<GroupDetail> build(String groupId) async {
    final dio = ref.read(dioProvider);
    final response =
        await dio.get<Map<String, dynamic>>('/api/v1/groups/$groupId');
    final data = (response.data?['data'] is Map
            ? response.data!['data']
            : response.data) as Map<String, dynamic>;
    final group = StudyGroup.fromJson(data);
    final members = ((data['members'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((m) => GroupMember(
              userId: (m['userId'] as String?) ?? '',
              displayName: (m['displayName'] as String?) ?? 'Member',
              role: (m['role'] as String?) ?? 'MEMBER',
            ))
        .toList();
    final notes = ((data['sharedNotes'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((n) => SharedNote(
              id: (n['id'] as String?) ?? '',
              wikiPageId: (n['wikiPageId'] as String?) ?? '',
              avatarId: (n['avatarId'] as String?) ?? '',
              title: (n['title'] as String?) ?? '',
              sharedBy: (n['sharedBy'] as String?) ?? '',
              sharedAt: n['sharedAt'] != null
                  ? DateTime.tryParse(n['sharedAt'] as String) ??
                      DateTime.now()
                  : DateTime.now(),
              relevanceStatus: (n['relevanceStatus'] as String?) ?? 'OK',
            ))
        .toList();
    return GroupDetail(group: group, members: members, sharedNotes: notes);
  }

  Future<void> shareWikiPage({
    required String wikiPageId,
    required String title,
  }) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post<Map<String, dynamic>>(
        '/api/v1/groups/$groupId/share',
        data: {'wikiPageId': wikiPageId, 'title': title},
      );
      ref.invalidateSelf();
    } on DioException catch (e) {
      appLog.w('[Groups] share failed: ${e.message}');
      rethrow;
    }
  }
}
