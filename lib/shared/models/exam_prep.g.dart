// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_prep.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExamPrepImpl _$$ExamPrepImplFromJson(Map<String, dynamic> json) =>
    _$ExamPrepImpl(
      testDate: json['testDate'] as String?,
      daysRemaining: (json['daysRemaining'] as num?)?.toInt(),
      concepts: (json['concepts'] as List<dynamic>?)
              ?.map(
                  (e) => ExamConceptMastery.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recommendedOrder: (json['recommendedOrder'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dailyTarget: (json['dailyTarget'] as num?)?.toInt() ?? 2,
    );

Map<String, dynamic> _$$ExamPrepImplToJson(_$ExamPrepImpl instance) =>
    <String, dynamic>{
      'testDate': instance.testDate,
      'daysRemaining': instance.daysRemaining,
      'concepts': instance.concepts,
      'recommendedOrder': instance.recommendedOrder,
      'dailyTarget': instance.dailyTarget,
    };

_$ExamConceptMasteryImpl _$$ExamConceptMasteryImplFromJson(
        Map<String, dynamic> json) =>
    _$ExamConceptMasteryImpl(
      concept: json['concept'] as String? ?? '',
      mastery: (json['mastery'] as num?)?.toDouble() ?? 0,
      moduleId: json['moduleId'] as String?,
      moduleTitle: json['moduleTitle'] as String?,
    );

Map<String, dynamic> _$$ExamConceptMasteryImplToJson(
        _$ExamConceptMasteryImpl instance) =>
    <String, dynamic>{
      'concept': instance.concept,
      'mastery': instance.mastery,
      'moduleId': instance.moduleId,
      'moduleTitle': instance.moduleTitle,
    };
