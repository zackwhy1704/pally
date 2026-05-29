// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StreakStatusImpl _$$StreakStatusImplFromJson(Map<String, dynamic> json) =>
    _$StreakStatusImpl(
      streakDays: (json['streakDays'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      freezes: (json['freezes'] as num).toInt(),
      last7: (json['last7'] as List<dynamic>).map((e) => e as bool).toList(),
      nextMilestone: (json['nextMilestone'] as num).toInt(),
      daysToMilestone: (json['daysToMilestone'] as num).toInt(),
      milestonesReached: (json['milestonesReached'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      ladder: (json['ladder'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[3, 7, 14, 30, 60, 100, 365],
    );

Map<String, dynamic> _$$StreakStatusImplToJson(_$StreakStatusImpl instance) =>
    <String, dynamic>{
      'streakDays': instance.streakDays,
      'longestStreak': instance.longestStreak,
      'freezes': instance.freezes,
      'last7': instance.last7,
      'nextMilestone': instance.nextMilestone,
      'daysToMilestone': instance.daysToMilestone,
      'milestonesReached': instance.milestonesReached,
      'ladder': instance.ladder,
    };
