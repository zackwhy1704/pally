import 'package:freezed_annotation/freezed_annotation.dart';

part 'referral.freezed.dart';
part 'referral.g.dart';

@freezed
class ReferralSummary with _$ReferralSummary {
  const factory ReferralSummary({
    @Default('') String code,
    @Default(0) int totalReferred,
    @Default(0) int activatedCount,
    @Default(0) int rewardsEarned,
    @Default(0) int nextTierAt,
    /// Real server-paid star bonus for reaching [nextTierAt] friends. Drives the
    /// "refer N more → +X⭐" copy so the tier ladder reflects actual rewards.
    @Default(0) int nextTierBonus,
  }) = _ReferralSummary;

  factory ReferralSummary.fromJson(Map<String, dynamic> json) =>
      _$ReferralSummaryFromJson(json);
}

@freezed
class ReferralRedemption with _$ReferralRedemption {
  const factory ReferralRedemption({
    @Default('') String displayName,
    @Default('pending') String status, // pending | activated
    @Default('') String joinedAt,
    String? activatedAt,
  }) = _ReferralRedemption;

  factory ReferralRedemption.fromJson(Map<String, dynamic> json) =>
      _$ReferralRedemptionFromJson(json);
}
