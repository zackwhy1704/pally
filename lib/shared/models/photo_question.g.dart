// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhotoQuestionImpl _$$PhotoQuestionImplFromJson(Map<String, dynamic> json) =>
    _$PhotoQuestionImpl(
      id: json['id'] as String,
      rawText: json['rawText'] as String,
      questionIndex: (json['questionIndex'] as num).toInt(),
      isSelected: json['isSelected'] as bool? ?? true,
    );

Map<String, dynamic> _$$PhotoQuestionImplToJson(_$PhotoQuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rawText': instance.rawText,
      'questionIndex': instance.questionIndex,
      'isSelected': instance.isSelected,
    };

_$QuestionAnswerImpl _$$QuestionAnswerImplFromJson(Map<String, dynamic> json) =>
    _$QuestionAnswerImpl(
      questionId: json['questionId'] as String,
      questionText: json['questionText'] as String,
      answer: json['answer'] as String,
      steps:
          (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      explanation: json['explanation'] as String? ?? '',
      visualType: json['visualType'] as String? ?? 'NONE',
      calculatorVerified: json['calculatorVerified'] as bool? ?? false,
    );

Map<String, dynamic> _$$QuestionAnswerImplToJson(
        _$QuestionAnswerImpl instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'questionText': instance.questionText,
      'answer': instance.answer,
      'steps': instance.steps,
      'explanation': instance.explanation,
      'visualType': instance.visualType,
      'calculatorVerified': instance.calculatorVerified,
    };

_$HomeworkScanResultImpl _$$HomeworkScanResultImplFromJson(
        Map<String, dynamic> json) =>
    _$HomeworkScanResultImpl(
      messageId: json['messageId'] as String,
      imageLocalPath: json['imageLocalPath'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => PhotoQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) => QuestionAnswer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 5,
      sourceWikiPage: json['sourceWikiPage'] as String?,
      status:
          $enumDecodeNullable(_$HomeworkScanStatusEnumMap, json['status']) ??
              HomeworkScanStatus.complete,
    );

Map<String, dynamic> _$$HomeworkScanResultImplToJson(
        _$HomeworkScanResultImpl instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'imageLocalPath': instance.imageLocalPath,
      'questions': instance.questions,
      'answers': instance.answers,
      'xpEarned': instance.xpEarned,
      'sourceWikiPage': instance.sourceWikiPage,
      'status': _$HomeworkScanStatusEnumMap[instance.status]!,
    };

const _$HomeworkScanStatusEnumMap = {
  HomeworkScanStatus.pending: 'pending',
  HomeworkScanStatus.ocrProcessing: 'ocrProcessing',
  HomeworkScanStatus.claudeProcessing: 'claudeProcessing',
  HomeworkScanStatus.complete: 'complete',
  HomeworkScanStatus.error: 'error',
};
