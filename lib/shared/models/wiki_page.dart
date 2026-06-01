import 'package:freezed_annotation/freezed_annotation.dart';

part 'wiki_page.freezed.dart';
part 'wiki_page.g.dart';

@freezed
class WikiPage with _$WikiPage {
  const factory WikiPage({
    @Default('') String id,
    @Default('') String avatarId,
    @Default('') String title,
    @Default('') String content,
    @Default('inferred') String certainty,
    @Default(false) bool hasConflict,
    @Default([]) List<String> sourceFileIds,
    String? slug,
    DateTime? updatedAt,
    DateTime? compiledAt,
    @Default(0) int qualityScore,
    @Default(false) bool humanVerified,
    String? humanCorrection,
  }) = _WikiPage;

  factory WikiPage.fromJson(Map<String, dynamic> json) =>
      _$WikiPageFromJson(json);
}
