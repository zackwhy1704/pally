import 'package:freezed_annotation/freezed_annotation.dart';

part 'flash_card.freezed.dart';
part 'flash_card.g.dart';

enum CardRating { hard, okay, easy }

String _cardRatingToJson(CardRating? r) => r?.name.toUpperCase() ?? 'OKAY';

CardRating? _cardRatingFromJson(Object? json) {
  if (json == null) return null;
  final s = (json as String).toUpperCase();
  return CardRating.values.firstWhere(
    (e) => e.name.toUpperCase() == s,
    orElse: () => CardRating.okay,
  );
}

@freezed
class FlashCard with _$FlashCard {
  const factory FlashCard({
    @Default('') String id,
    @Default('') String front,
    @Default('') String back,
    @Default('') String sourceFile,
    @JsonKey(fromJson: _cardRatingFromJson, toJson: _cardRatingToJson)
    CardRating? lastRating,
    DateTime? nextReview,
  }) = _FlashCard;

  factory FlashCard.fromJson(Map<String, dynamic> json) =>
      _$FlashCardFromJson(json);
}
