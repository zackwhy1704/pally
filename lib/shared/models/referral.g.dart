// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReferralSummaryImpl _$$ReferralSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$ReferralSummaryImpl(
      code: json['code'] as String? ?? '',
      totalReferred: (json['totalReferred'] as num?)?.toInt() ?? 0,
      activatedCount: (json['activatedCount'] as num?)?.toInt() ?? 0,
      rewardsEarned: (json['rewardsEarned'] as num?)?.toInt() ?? 0,
      nextTierAt: (json['nextTierAt'] as num?)?.toInt() ?? 0,
      nextTierBonus: (json['nextTierBonus'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ReferralSummaryImplToJson(
        _$ReferralSummaryImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'totalReferred': instance.totalReferred,
      'activatedCount': instance.activatedCount,
      'rewardsEarned': instance.rewardsEarned,
      'nextTierAt': instance.nextTierAt,
      'nextTierBonus': instance.nextTierBonus,
    };

_$ReferralRedemptionImpl _$$ReferralRedemptionImplFromJson(
        Map<String, dynamic> json) =>
    _$ReferralRedemptionImpl(
      displayName: json['displayName'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      joinedAt: json['joinedAt'] as String? ?? '',
      activatedAt: json['activatedAt'] as String?,
    );

Map<String, dynamic> _$$ReferralRedemptionImplToJson(
        _$ReferralRedemptionImpl instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'status': instance.status,
      'joinedAt': instance.joinedAt,
      'activatedAt': instance.activatedAt,
    };
