// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AchievementImpl _$$AchievementImplFromJson(Map<String, dynamic> json) =>
    _$AchievementImpl(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'MILESTONE',
      rarity: json['rarity'] as String? ?? 'COMMON',
      target: (json['target'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      earned: json['earned'] as bool? ?? false,
      earnedAt: json['earnedAt'] as String?,
    );

Map<String, dynamic> _$$AchievementImplToJson(_$AchievementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'rarity': instance.rarity,
      'target': instance.target,
      'progress': instance.progress,
      'earned': instance.earned,
      'earnedAt': instance.earnedAt,
    };

_$AchievementListImpl _$$AchievementListImplFromJson(
        Map<String, dynamic> json) =>
    _$AchievementListImpl(
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      earnedCount: (json['earnedCount'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$AchievementListImplToJson(
        _$AchievementListImpl instance) =>
    <String, dynamic>{
      'achievements': instance.achievements,
      'earnedCount': instance.earnedCount,
      'totalCount': instance.totalCount,
    };
