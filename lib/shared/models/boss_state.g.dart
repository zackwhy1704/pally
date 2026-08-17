// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boss_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BossStateImpl _$$BossStateImplFromJson(Map<String, dynamic> json) =>
    _$BossStateImpl(
      active: json['active'] as bool? ?? false,
      id: json['id'] as String?,
      topicSlug: json['topicSlug'] as String?,
      hpRemaining: (json['hpRemaining'] as num?)?.toInt() ?? 0,
      hpMax: (json['hpMax'] as num?)?.toInt() ?? 0,
      defeated: json['defeated'] as bool? ?? false,
      rewardUnlocked: json['rewardUnlocked'] as bool? ?? false,
      currentQuestion: json['currentQuestion'] == null
          ? null
          : QuizQuestion.fromJson(
              json['currentQuestion'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$BossStateImplToJson(_$BossStateImpl instance) =>
    <String, dynamic>{
      'active': instance.active,
      'id': instance.id,
      'topicSlug': instance.topicSlug,
      'hpRemaining': instance.hpRemaining,
      'hpMax': instance.hpMax,
      'defeated': instance.defeated,
      'rewardUnlocked': instance.rewardUnlocked,
      'currentQuestion': instance.currentQuestion,
    };

_$BossAttackResultImpl _$$BossAttackResultImplFromJson(
        Map<String, dynamic> json) =>
    _$BossAttackResultImpl(
      state: BossState.fromJson(json['state'] as Map<String, dynamic>),
      hitLanded: json['hitLanded'] as bool? ?? false,
    );

Map<String, dynamic> _$$BossAttackResultImplToJson(
        _$BossAttackResultImpl instance) =>
    <String, dynamic>{
      'state': instance.state,
      'hitLanded': instance.hitLanded,
    };
