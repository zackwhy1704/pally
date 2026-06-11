// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_module.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LearningModuleImpl _$$LearningModuleImplFromJson(Map<String, dynamic> json) =>
    _$LearningModuleImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      wikiSlug: json['wikiSlug'] as String? ?? '',
      stage: json['stage'] as String? ?? 'LEARN',
      masteryPct: (json['masteryPct'] as num?)?.toDouble() ?? 0,
      itemCounts: (json['itemCounts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$$LearningModuleImplToJson(
        _$LearningModuleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'wikiSlug': instance.wikiSlug,
      'stage': instance.stage,
      'masteryPct': instance.masteryPct,
      'itemCounts': instance.itemCounts,
    };

_$ModuleContentItemImpl _$$ModuleContentItemImplFromJson(
        Map<String, dynamic> json) =>
    _$ModuleContentItemImpl(
      id: json['id'] as String,
      stage: json['stage'] as String,
      type: json['type'] as String,
      contentJson: json['contentJson'] as Map<String, dynamic>,
      answerJson: json['answerJson'] as Map<String, dynamic>?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ModuleContentItemImplToJson(
        _$ModuleContentItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stage': instance.stage,
      'type': instance.type,
      'contentJson': instance.contentJson,
      'answerJson': instance.answerJson,
      'sortOrder': instance.sortOrder,
    };

_$ModuleResultsImpl _$$ModuleResultsImplFromJson(Map<String, dynamic> json) =>
    _$ModuleResultsImpl(
      concepts: (json['concepts'] as List<dynamic>?)
              ?.map((e) => ConceptMastery.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ModuleResultsImplToJson(_$ModuleResultsImpl instance) =>
    <String, dynamic>{
      'concepts': instance.concepts,
      'xpEarned': instance.xpEarned,
    };

_$ConceptMasteryImpl _$$ConceptMasteryImplFromJson(Map<String, dynamic> json) =>
    _$ConceptMasteryImpl(
      concept: json['concept'] as String? ?? '',
      mastery: (json['mastery'] as num?)?.toDouble() ?? 0,
      feedback: json['feedback'] as String? ?? '',
      passed: json['passed'] as bool? ?? false,
    );

Map<String, dynamic> _$$ConceptMasteryImplToJson(
        _$ConceptMasteryImpl instance) =>
    <String, dynamic>{
      'concept': instance.concept,
      'mastery': instance.mastery,
      'feedback': instance.feedback,
      'passed': instance.passed,
    };
