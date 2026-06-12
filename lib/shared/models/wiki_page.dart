import 'package:freezed_annotation/freezed_annotation.dart';

part 'wiki_page.freezed.dart';
part 'wiki_page.g.dart';

/// Backend review lifecycle for a wiki page. Mirrors the `reviewState` field
/// on the wiki-page DTO. Parsed null-tolerantly (PART 16): an unknown or
/// missing value falls back to [unverified] so the UI never crashes on a
/// contract drift, and shows a neutral "Unverified" chip instead.
enum WikiReviewState {
  flagged,
  verified,
  lowConfidence,
  unverified;

  static WikiReviewState fromName(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'FLAGGED':
        return WikiReviewState.flagged;
      case 'VERIFIED':
        return WikiReviewState.verified;
      case 'LOW_CONFIDENCE':
        return WikiReviewState.lowConfidence;
      case 'UNVERIFIED':
        return WikiReviewState.unverified;
      default:
        return WikiReviewState.unverified;
    }
  }
}

WikiReviewState _reviewStateFromJson(Object? raw) =>
    WikiReviewState.fromName(raw is String ? raw : null);

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
    // Fix 3: provenance — names of knowledge files that contributed to this page
    @Default([]) List<String> sourceFileNames,
    // Review lifecycle — see [WikiReviewState]. Null-tolerant: a missing or
    // unknown value parses to UNVERIFIED rather than throwing.
    @JsonKey(fromJson: _reviewStateFromJson)
    @Default(WikiReviewState.unverified)
    WikiReviewState reviewState,
    // Display name of whoever verified/flagged the page (e.g. "Mum", a tutor).
    // Null when never reviewed.
    String? verifiedBy,
    // Present (and non-empty) only when [reviewState] == flagged — the
    // reviewer's note on what looked wrong.
    String? flagNote,
  }) = _WikiPage;

  factory WikiPage.fromJson(Map<String, dynamic> json) =>
      _$WikiPageFromJson(json);
}
