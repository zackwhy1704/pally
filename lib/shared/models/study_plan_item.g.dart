// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_plan_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudyPlanItemImpl _$$StudyPlanItemImplFromJson(Map<String, dynamic> json) =>
    _$StudyPlanItemImpl(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: _typeFromJson(json['type']),
      isDone: json['isDone'] as bool? ?? false,
      avatarId: json['avatarId'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      scheduledDate: json['scheduledDate'] == null
          ? null
          : DateTime.parse(json['scheduledDate'] as String),
    );

Map<String, dynamic> _$$StudyPlanItemImplToJson(_$StudyPlanItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': _typeToJson(instance.type),
      'isDone': instance.isDone,
      'avatarId': instance.avatarId,
      'reason': instance.reason,
      'scheduledDate': instance.scheduledDate?.toIso8601String(),
    };
