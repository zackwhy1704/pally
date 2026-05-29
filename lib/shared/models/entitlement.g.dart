// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EntitlementImpl _$$EntitlementImplFromJson(Map<String, dynamic> json) =>
    _$EntitlementImpl(
      isPremium: json['isPremium'] as bool,
      source: json['source'] as String,
      plan: json['plan'] as String?,
      status: json['status'] as String?,
      trialEndsAt: json['trialEndsAt'] as String?,
    );

Map<String, dynamic> _$$EntitlementImplToJson(_$EntitlementImpl instance) =>
    <String, dynamic>{
      'isPremium': instance.isPremium,
      'source': instance.source,
      'plan': instance.plan,
      'status': instance.status,
      'trialEndsAt': instance.trialEndsAt,
    };
