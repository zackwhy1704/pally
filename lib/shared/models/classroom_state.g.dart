// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classroom_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassroomStateImpl _$$ClassroomStateImplFromJson(Map<String, dynamic> json) =>
    _$ClassroomStateImpl(
      sessionId: json['sessionId'] as String,
      status: json['status'] as String,
      topicSlug: json['topicSlug'] as String,
      hpRemaining: (json['hpRemaining'] as num).toInt(),
      hpMax: (json['hpMax'] as num).toInt(),
      defeated: json['defeated'] as bool? ?? false,
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      currentQuestion: json['currentQuestion'] == null
          ? null
          : QuizQuestion.fromJson(
              json['currentQuestion'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ClassroomStateImplToJson(
        _$ClassroomStateImpl instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'status': instance.status,
      'topicSlug': instance.topicSlug,
      'hpRemaining': instance.hpRemaining,
      'hpMax': instance.hpMax,
      'defeated': instance.defeated,
      'participantCount': instance.participantCount,
      'currentQuestion': instance.currentQuestion,
    };
