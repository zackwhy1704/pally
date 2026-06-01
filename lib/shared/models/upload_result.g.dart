// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UploadResultImpl _$$UploadResultImplFromJson(Map<String, dynamic> json) =>
    _$UploadResultImpl(
      id: json['id'] as String? ?? '',
      avatarId: json['avatarId'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      status: $enumDecodeNullable(_$UploadStatusEnumMap, json['status']) ??
          UploadStatus.processing,
      pageCount: (json['pageCount'] as num?)?.toInt() ?? 0,
      wikiPageTitles: (json['wikiPageTitles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      errorMessage: json['errorMessage'] as String?,
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
    );

Map<String, dynamic> _$$UploadResultImplToJson(_$UploadResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'avatarId': instance.avatarId,
      'fileName': instance.fileName,
      'status': _$UploadStatusEnumMap[instance.status]!,
      'pageCount': instance.pageCount,
      'wikiPageTitles': instance.wikiPageTitles,
      'errorMessage': instance.errorMessage,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
    };

const _$UploadStatusEnumMap = {
  UploadStatus.pending: 'pending',
  UploadStatus.processing: 'processing',
  UploadStatus.ready: 'ready',
  UploadStatus.failed: 'failed',
};

_$RelevanceCheckResponseImpl _$$RelevanceCheckResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$RelevanceCheckResponseImpl(
      isRelevant: json['isRelevant'] as bool? ?? true,
      score: (json['score'] as num?)?.toDouble() ?? 1.0,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$RelevanceCheckResponseImplToJson(
        _$RelevanceCheckResponseImpl instance) =>
    <String, dynamic>{
      'isRelevant': instance.isRelevant,
      'score': instance.score,
      'reason': instance.reason,
    };
