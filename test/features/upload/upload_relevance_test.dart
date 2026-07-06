import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/upload/presentation/upload_view_model.dart';
import 'package:pally/shared/models/upload_result.dart';

/// Pins the two invariants behind the "sales-book upload silently fails" fix:
/// (1) once the client has run its own /relevance check, proceeding to upload ALWAYS
///     tells the server to skip its re-check — so the two non-deterministic Claude
///     calls can never diverge and drop an on-topic file; and
/// (2) a server RelevanceWarning is recognised as a warning (→ add-anyway dialog),
///     never parsed as a silent 0-page "success".
void main() {
  group('planAfterRelevance — client owns the relevance decision', () {
    test('on-topic study material → upload now, ALWAYS skip the server re-check', () {
      final plan = planAfterRelevance(const RelevanceCheckResponse(
          isRelevant: true, studyMaterial: true, score: 0.9));
      expect(plan.uploadNow, isTrue);
      // The core fix: the server must NOT re-adjudicate (the divergence that scored
      // a passed 0.45 file as 0.25 and dropped it).
      expect(plan.skipServerRelevance, isTrue);
      expect(plan.askAddAnyway, isFalse);
    });

    test('off-topic → ask add-anyway; if the user proceeds, still skip the re-check', () {
      final plan = planAfterRelevance(const RelevanceCheckResponse(
          isRelevant: false, studyMaterial: true, score: 0.25));
      expect(plan.uploadNow, isFalse);
      expect(plan.askAddAnyway, isTrue);
      expect(plan.skipServerRelevance, isTrue);
    });

    test('relevant but not study material (e.g. a selfie) → ask add-anyway', () {
      final plan = planAfterRelevance(const RelevanceCheckResponse(
          isRelevant: true, studyMaterial: false, score: 0.6));
      expect(plan.uploadNow, isFalse);
      expect(plan.askAddAnyway, isTrue);
    });
  });

  group('relevanceWarningFrom — a warning is never a silent success', () {
    test('a RelevanceWarning body (reason + score) is detected as off-topic', () {
      final w = relevanceWarningFrom(
          {'fileId': 'f1', 'score': 0.25, 'reason': 'not a school subject'});
      expect(w, isNotNull);
      expect(w!.isRelevant, isFalse);
      expect(w.studyMaterial, isFalse);
      expect(w.score, 0.25);
      expect(w.reason, 'not a school subject');
    });

    test('a normal Success (titles + pageCount, no reason) is NOT a warning', () {
      expect(
        relevanceWarningFrom(
            {'fileId': 'f1', 'pageCount': 12, 'wikiPageTitles': ['A', 'B']}),
        isNull,
      );
    });

    test('an async-compile Success (no titles yet, no reason) is NOT a warning', () {
      expect(relevanceWarningFrom({'fileId': 'f1', 'pageCount': 0}), isNull);
    });

    test('empty / malformed body is NOT a warning', () {
      expect(relevanceWarningFrom(const {}), isNull);
      expect(relevanceWarningFrom({'reason': ''}), isNull); // blank reason
      expect(relevanceWarningFrom({'reason': 'x'}), isNull); // no score
    });
  });
}
