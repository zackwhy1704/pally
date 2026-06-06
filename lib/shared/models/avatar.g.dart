// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AvatarImpl _$$AvatarImplFromJson(Map<String, dynamic> json) => _$AvatarImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      character: _characterFromJson(json['characterType']),
      subject: _subjectFromJson(json['subject']),
      wikiPageCount: json['wikiPageCount'] == null
          ? 0
          : _wikiPageCountFromJson(json['wikiPageCount']),
      fileCount: (json['fileCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      pedagogyMode: json['pedagogyMode'] == null
          ? PedagogyMode.socratic
          : _pedagogyFromJson(json['pedagogyMode']),
      gradeLevel: json['gradeLevel'] as String?,
      curriculumType: json['curriculumType'] as String?,
      testDate: _testDateFromJson(json['testDate']),
      brainState: json['brainState'] as String? ?? 'READY',
      isActive: json['isActive'] as bool? ?? true,
      teacherPreferences: json['teacherPreferences'] as String?,
      centreManaged: json['centreManaged'] as bool? ?? false,
      centreId: json['centreId'] as String?,
      centreBrandName: json['centreBrandName'] as String?,
      centreAccentColor: json['centreAccentColor'] as String?,
    );

Map<String, dynamic> _$$AvatarImplToJson(_$AvatarImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'characterType': _characterToJson(instance.character),
      'subject': _subjectToJson(instance.subject),
      'wikiPageCount': instance.wikiPageCount,
      'fileCount': instance.fileCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'pedagogyMode': _pedagogyToJson(instance.pedagogyMode),
      'gradeLevel': instance.gradeLevel,
      'curriculumType': instance.curriculumType,
      'testDate': _testDateToJson(instance.testDate),
      'brainState': instance.brainState,
      'isActive': instance.isActive,
      'teacherPreferences': instance.teacherPreferences,
      'centreManaged': instance.centreManaged,
      'centreId': instance.centreId,
      'centreBrandName': instance.centreBrandName,
      'centreAccentColor': instance.centreAccentColor,
    };

_$CreateAvatarRequestImpl _$$CreateAvatarRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateAvatarRequestImpl(
      name: json['name'] as String,
      character: _characterFromJson(json['characterType']),
      subject: _subjectFromJson(json['subject']),
      gradeLevel: json['gradeLevel'] as String?,
      curriculumType: json['curriculumType'] as String?,
    );

Map<String, dynamic> _$$CreateAvatarRequestImplToJson(
        _$CreateAvatarRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'characterType': _characterToJson(instance.character),
      'subject': _subjectToJson(instance.subject),
      'gradeLevel': instance.gradeLevel,
      'curriculumType': instance.curriculumType,
    };
