// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flash_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlashCardImpl _$$FlashCardImplFromJson(Map<String, dynamic> json) =>
    _$FlashCardImpl(
      id: json['id'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      sourceFile: json['sourceFile'] as String? ?? '',
      lastRating: _cardRatingFromJson(json['lastRating']),
      nextReview: json['nextReview'] == null
          ? null
          : DateTime.parse(json['nextReview'] as String),
    );

Map<String, dynamic> _$$FlashCardImplToJson(_$FlashCardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'front': instance.front,
      'back': instance.back,
      'sourceFile': instance.sourceFile,
      'lastRating': _cardRatingToJson(instance.lastRating),
      'nextReview': instance.nextReview?.toIso8601String(),
    };
