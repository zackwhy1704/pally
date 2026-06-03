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

  bool get isOnTrial => trialActive && source == 'TRIAL';
  bool get isTrialExpired => trialStatus == 'EXPIRED';
  bool get canSwapSlot => slotCooldownSecondsRemaining == 0;

  static const empty = TrialStatus(
    isPremium: false,
    source: 'NONE',
    trialActive: false,
    trialStatus: 'NONE',
    trialDaysLeft: 0,
    trialHoursLeft: 0,
    freeTutorCap: 1,
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
    );
  } catch (e) {
    appLog.w('[Trial] /usage/today failed: $e');
    return TrialStatus.empty;
  }
}
