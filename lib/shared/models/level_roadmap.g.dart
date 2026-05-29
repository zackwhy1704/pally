// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_roadmap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LevelRewardImpl _$$LevelRewardImplFromJson(Map<String, dynamic> json) =>
    _$LevelRewardImpl(
      level: (json['level'] as num).toInt(),
      label: json['label'] as String,
      kind: json['kind'] as String,
      unlocked: json['unlocked'] as bool,
    );

Map<String, dynamic> _$$LevelRewardImplToJson(_$LevelRewardImpl instance) =>
    <String, dynamic>{
      'level': instance.level,
      'label': instance.label,
      'kind': instance.kind,
      'unlocked': instance.unlocked,
    };

_$LevelRoadmapImpl _$$LevelRoadmapImplFromJson(Map<String, dynamic> json) =>
    _$LevelRoadmapImpl(
      currentLevel: (json['currentLevel'] as num).toInt(),
      maxLevel: (json['maxLevel'] as num).toInt(),
      rewards: (json['rewards'] as List<dynamic>)
          .map((e) => LevelReward.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$LevelRoadmapImplToJson(_$LevelRoadmapImpl instance) =>
    <String, dynamic>{
      'currentLevel': instance.currentLevel,
      'maxLevel': instance.maxLevel,
      'rewards': instance.rewards,
    };
