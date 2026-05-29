import 'package:freezed_annotation/freezed_annotation.dart';

part 'referral.freezed.dart';
part 'referral.g.dart';

@freezed
class ReferralSummary with _$ReferralSummary {
  const factory ReferralSummary({
    required String code,
    required int totalReferred,
    required int activatedCount,
    required int rewardsEarned,
    required int nextTierAt,
  }) = _ReferralSummary;

  factory ReferralSummary.fromJson(Map<String, dynamic> json) =>
      _$ReferralSummaryFromJson(json);
}

@freezed
class ReferralRedemption with _$ReferralRedemption {
  const factory ReferralRedemption({
    required String displayName,
    required String status, // pending | activated
    required String joinedAt,
    String? activatedAt,
  }) = _ReferralRedemption;

  factory ReferralRedemption.fromJson(Map<String, dynamic> json) =>
      _$ReferralRedemptionFromJson(json);
}
