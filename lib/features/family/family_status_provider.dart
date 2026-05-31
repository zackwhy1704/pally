import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/features/family/family_service.dart';

part 'family_status_provider.g.dart';

/// What this account is in the family graph.
///
/// SOLO   → no parent/child link yet (default for new accounts).
/// CHILD  → has generated a code; may or may not be claimed by a parent yet.
/// PARENT → has claimed at least one child's code.
enum AccountType { solo, child, parent }

/// Live snapshot of the caller's position in the family graph.
///
/// Fetched from GET /account/family. The parent-mode button and link-parents
/// row are driven exclusively from this state so the UI stays consistent.
class FamilyStatus {
  const FamilyStatus({
    required this.accountType,
    this.children = const [],
    this.parentName,
    this.parentLinked = false,
  });

  final AccountType accountType;

  /// Non-empty only when [accountType] == PARENT.
  final List<Map<String, dynamic>> children;

  /// Display name of the linked parent (CHILD accounts only).
  final String? parentName;

  /// True when this CHILD account has an active parent link.
  final bool parentLinked;

  bool get isParent => accountType == AccountType.parent;
  bool get isChild => accountType == AccountType.child;
  bool get isSolo => accountType == AccountType.solo;

  /// True when the parent is a PARENT type AND has at least one child linked.
  /// Only when both are true should "Parent Mode" be shown.
  bool get canAccessParentMode =>
      accountType == AccountType.parent && children.isNotEmpty;

  /// Show the "Link parents / Connect to parent" row.
  /// Hidden once a parent is linked, or if this account IS a parent.
  bool get showLinkParentRow => !isParent && !parentLinked;

  static const empty = FamilyStatus(accountType: AccountType.solo);
}

@riverpod
Future<FamilyStatus> familyStatus(Ref ref) async {
  try {
    final svc = ref.read(familyServiceProvider);
    final data = await svc.family();

    final rawType = (data['accountType'] as String? ?? 'SOLO').toUpperCase();
    final accountType = switch (rawType) {
      'PARENT' => AccountType.parent,
      'CHILD' => AccountType.child,
      _ => AccountType.solo,
    };

    final children = ((data['children'] as List?) ?? [])
        .whereType<Map>()
        .map((c) => Map<String, dynamic>.from(c))
        .toList();

    final parentMap = data['parent'];
    final parentId = parentMap is Map ? parentMap['id'] as String? : null;
    final parentLinked = parentId != null && parentId.isNotEmpty;
    final parentName = parentMap is Map
        ? (parentMap['displayName'] as String?)
        : null;

    return FamilyStatus(
      accountType: accountType,
      children: children,
      parentLinked: parentLinked,
      parentName: parentName?.isNotEmpty == true ? parentName : null,
    );
  } catch (_) {
    // Fail open — default to solo so we never block the screen.
    return FamilyStatus.empty;
  }
}
