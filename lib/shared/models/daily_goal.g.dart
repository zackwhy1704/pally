// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyGoalImpl _$$DailyGoalImplFromJson(Map<String, dynamic> json) =>
    _$DailyGoalImpl(
      goalType: json['goalType'] as String,
      goalTarget: (json['goalTarget'] as num).toInt(),
      goalProgress: (json['goalProgress'] as num).toInt(),
      met: json['met'] as bool,
    );

Map<String, dynamic> _$$DailyGoalImplToJson(_$DailyGoalImpl instance) =>
    <String, dynamic>{
      'goalType': instance.goalType,
      'goalTarget': instance.goalTarget,
      'goalProgress': instance.goalProgress,
      'met': instance.met,
    };
