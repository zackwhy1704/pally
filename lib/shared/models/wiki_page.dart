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
    // Knowledge-graph edges: slugs of pages this page depends on (its
    // prerequisites). Null-tolerant (PART 16): a missing array → empty list,
    // so an older backend that omits the field renders as a root node.
    @Default([]) List<String> prerequisiteSlugs,
    // Mochi's confidence in this page, 0.0–1.0. Drives the graph node's
    // border weight. Missing → 0.0 (treated as no extra confidence signal).
    @Default(0.0) double certaintyScore,
    // How many times this page has been used to generate a quiz question.
    // Drives the graph node's size. Missing → 0.
    @Default(0) int quizUseCount,
    // A short human-readable note about the contradiction Mochi found on this
    // page. Present (non-null) only when [hasConflict] is true. Shown in the
    // topic sheet as "Mochi noticed: …".
    String? conflictNote,
  }) = _WikiPage;

  factory WikiPage.fromJson(Map<String, dynamic> json) =>
      _$WikiPageFromJson(json);
}
