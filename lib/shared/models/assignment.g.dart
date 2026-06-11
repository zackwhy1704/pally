// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssignmentImpl _$$AssignmentImplFromJson(Map<String, dynamic> json) =>
    _$AssignmentImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String? ?? 'PRE_CLASS',
      dueDate: json['dueDate'] as String,
      status: json['status'] as String? ?? 'PENDING',
      modules: (json['modules'] as List<dynamic>?)
              ?.map((e) => AssignmentModule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$AssignmentImplToJson(_$AssignmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': instance.type,
      'dueDate': instance.dueDate,
      'status': instance.status,
      'modules': instance.modules,
    };

_$AssignmentModuleImpl _$$AssignmentModuleImplFromJson(
        Map<String, dynamic> json) =>
    _$AssignmentModuleImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      stage: json['stage'] as String? ?? 'LEARN',
    );

Map<String, dynamic> _$$AssignmentModuleImplToJson(
        _$AssignmentModuleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'stage': instance.stage,
    };
