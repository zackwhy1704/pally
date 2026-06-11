// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'narration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NarrationImpl _$$NarrationImplFromJson(Map<String, dynamic> json) =>
    _$NarrationImpl(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      segments: (json['segments'] as List<dynamic>?)
              ?.map((e) => NarrationSegment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$NarrationImplToJson(_$NarrationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'segments': instance.segments,
    };

_$NarrationSegmentImpl _$$NarrationSegmentImplFromJson(
        Map<String, dynamic> json) =>
    _$NarrationSegmentImpl(
      cardIndex: (json['cardIndex'] as num?)?.toInt() ?? 0,
      scriptText: json['scriptText'] as String? ?? '',
      audioUrl: json['audioUrl'] as String? ?? '',
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$NarrationSegmentImplToJson(
        _$NarrationSegmentImpl instance) =>
    <String, dynamic>{
      'cardIndex': instance.cardIndex,
      'scriptText': instance.scriptText,
      'audioUrl': instance.audioUrl,
      'durationMs': instance.durationMs,
    };
