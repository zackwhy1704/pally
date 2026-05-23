// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiki_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WikiPageImpl _$$WikiPageImplFromJson(Map<String, dynamic> json) =>
    _$WikiPageImpl(
      id: json['id'] as String,
      avatarId: json['avatarId'] as String? ?? '',
      title: json['title'] as String,
      content: json['content'] as String,
      certainty: json['certainty'] as String? ?? 'inferred',
      hasConflict: json['hasConflict'] as bool? ?? false,
      sourceFileIds: (json['sourceFileIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      slug: json['slug'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      compiledAt: json['compiledAt'] == null
          ? null
          : DateTime.parse(json['compiledAt'] as String),
      qualityScore: (json['qualityScore'] as num?)?.toInt() ?? 0,
      humanVerified: json['humanVerified'] as bool? ?? false,
      humanCorrection: json['humanCorrection'] as String?,
    );

Map<String, dynamic> _$$WikiPageImplToJson(_$WikiPageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'avatarId': instance.avatarId,
      'title': instance.title,
      'content': instance.content,
      'certainty': instance.certainty,
      'hasConflict': instance.hasConflict,
      'sourceFileIds': instance.sourceFileIds,
      'slug': instance.slug,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'compiledAt': instance.compiledAt?.toIso8601String(),
      'qualityScore': instance.qualityScore,
      'humanVerified': instance.humanVerified,
      'humanCorrection': instance.humanCorrection,
    };
