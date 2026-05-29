// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeakTopicImpl _$$WeakTopicImplFromJson(Map<String, dynamic> json) =>
    _$WeakTopicImpl(
      topic: json['topic'] as String,
      mastery: (json['mastery'] as num).toDouble(),
    );

Map<String, dynamic> _$$WeakTopicImplToJson(_$WeakTopicImpl instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'mastery': instance.mastery,
    };

_$ProgressSummaryImpl _$$ProgressSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$ProgressSummaryImpl(
      level: (json['level'] as num).toInt(),
      xp: (json['xp'] as num).toInt(),
      xpToNextLevel: (json['xpToNextLevel'] as num).toInt(),
      xpIntoLevel: (json['xpIntoLevel'] as num?)?.toInt() ?? 0,
      xpSpanForLevel: (json['xpSpanForLevel'] as num?)?.toInt() ?? 100,
      maxLevel: (json['maxLevel'] as num?)?.toInt() ?? 30,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      weekMinutes: (json['weekMinutes'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      weakTopics: (json['weakTopics'] as List<dynamic>?)
              ?.map((e) => WeakTopic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      nextUnlockLevel: (json['nextUnlockLevel'] as num?)?.toInt(),
      nextUnlockLabel: json['nextUnlockLabel'] as String?,
    );

Map<String, dynamic> _$$ProgressSummaryImplToJson(
        _$ProgressSummaryImpl instance) =>
    <String, dynamic>{
      'level': instance.level,
      'xp': instance.xp,
      'xpToNextLevel': instance.xpToNextLevel,
      'xpIntoLevel': instance.xpIntoLevel,
      'xpSpanForLevel': instance.xpSpanForLevel,
      'maxLevel': instance.maxLevel,
      'streakDays': instance.streakDays,
      'weekMinutes': instance.weekMinutes,
      'weakTopics': instance.weakTopics,
      'badges': instance.badges,
      'nextUnlockLevel': instance.nextUnlockLevel,
      'nextUnlockLabel': instance.nextUnlockLabel,
    };
