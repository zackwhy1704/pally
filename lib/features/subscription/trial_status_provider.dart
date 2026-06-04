import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/utils/logger.dart';

part 'trial_status_provider.g.dart';

/// Rich trial/entitlement snapshot read from GET /usage/today.
/// This is the single frontend source of truth — never compute
/// entitlement or trial state client-side.
class TrialStatus {
  const TrialStatus({
    required this.isPremium,
    required this.source,
    required this.trialActive,
    required this.trialStatus,
    this.trialEndsAt,
    required this.trialDaysLeft,
    required this.trialHoursLeft,
    this.freeTutorCap,
    this.slotCooldownSecondsRemaining = 0,
    this.subscriptionTier = 'FREE',
    this.mochiCap = 1,
    this.chatLimit = 20,
    this.chatUsed = 0,
    this.chatRemaining = 20,
  });

  final bool isPremium;
  final String source; // SELF | PARENT | TRIAL | NONE
  final bool trialActive;
  final String trialStatus; // NONE | ACTIVE | EXPIRED | CONVERTED
  final DateTime? trialEndsAt;
  final int trialDaysLeft;
  final int trialHoursLeft;
  final int? freeTutorCap; // null = unlimited (premium)
  final int slotCooldownSecondsRemaining; // 0 = can swap now
  // Subscription tier fields — populated from backend UsageController
  final String subscriptionTier; // FREE | PRO | MAX | FAMILY | CENTRE
  final int mochiCap;       // -1 = unlimited
  final int chatLimit;      // -1 = unlimited
  final int chatUsed;
  final int chatRemaining;  // -1 = unlimited

  bool get isOnTrial => trialActive && source == 'TRIAL';
  bool get isTrialExpired => trialStatus == 'EXPIRED';
  bool get canSwapSlot => slotCooldownSecondsRemaining == 0;
  bool get hasUnlimitedChat => chatLimit == -1;
  bool get isLowOnMessages =>
      !hasUnlimitedChat && chatRemaining <= 5 && chatRemaining >= 0;

  static const empty = TrialStatus(
    isPremium: false,
    source: 'NONE',
    trialActive: false,
    trialStatus: 'NONE',
    trialDaysLeft: 0,
    trialHoursLeft: 0,
    freeTutorCap: 1,
    subscriptionTier: 'FREE',
    mochiCap: 1,
    chatLimit: 20,
    chatUsed: 0,
    chatRemaining: 20,
  );
}

@riverpod
Future<TrialStatus> trialStatus(Ref ref) async {
  try {
    final dio = ref.read(dioProvider);
    final res = await dio.get<dynamic>('/api/v1/usage/today');
    final body = res.data is Map ? res.data as Map : {};
    final data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : Map<String, dynamic>.from(body);

    final endsAtStr = data['trialEndsAt'] as String?;
    final chatLimit = (data['chatLimit'] as num?)?.toInt() ?? 20;
    final chatUsed = (data['chatUsed'] as num?)?.toInt() ?? 0;
    final chatRemaining = (data['chatRemaining'] as num?)?.toInt() ??
        (chatLimit == -1 ? -1 : (chatLimit - chatUsed).clamp(0, chatLimit));

    return TrialStatus(
      isPremium: data['isPremium'] as bool? ?? false,
      source: data['source'] as String? ?? 'NONE',
      trialActive: data['trialActive'] as bool? ?? false,
      trialStatus: data['trialStatus'] as String? ?? 'NONE',
      trialEndsAt: endsAtStr != null ? DateTime.tryParse(endsAtStr) : null,
      trialDaysLeft: (data['trialDaysLeft'] as num?)?.toInt() ?? 0,
      trialHoursLeft: (data['trialHoursLeft'] as num?)?.toInt() ?? 0,
      freeTutorCap: (data['freeTutorCap'] as num?)?.toInt(),
      slotCooldownSecondsRemaining:
          (data['slotCooldownSecondsRemaining'] as num?)?.toInt() ?? 0,
      subscriptionTier: data['subscriptionTier'] as String? ?? 'FREE',
      mochiCap: (data['mochiCap'] as num?)?.toInt() ?? 1,
      chatLimit: chatLimit,
      chatUsed: chatUsed,
      chatRemaining: chatRemaining,
    );
  } catch (e) {
    appLog.w('[Trial] /usage/today failed: $e');
    return TrialStatus.empty;
  }
}
