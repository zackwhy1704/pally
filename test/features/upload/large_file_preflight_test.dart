import 'package:flutter_test/flutter_test.dart';
import 'package:pally/features/upload/presentation/upload_view_model.dart';

/// Prompt A: a large file must trigger a PRE-UPLOAD confirm (expectations up
/// front for the genuinely-slow compile); a small file must not. The threshold
/// is the same 5MB cutoff the in-progress "large" copy uses, so preflight and
/// progress copy agree.
void main() {
  const mb = 1024 * 1024;

  group('needsLargeFilePreflight', () {
    test('a >5MB file needs the preflight confirm', () {
      expect(needsLargeFilePreflight(6 * mb), isTrue);
      expect(needsLargeFilePreflight(19 * mb), isTrue); // the 19MB prod case
    });

    test('a small file does NOT — it uploads straight through', () {
      expect(needsLargeFilePreflight(1 * mb), isFalse);
      expect(needsLargeFilePreflight(4 * mb), isFalse);
    });

    test('exactly 5MB is not "large" (strict >, matches isLargeFile)', () {
      expect(needsLargeFilePreflight(5 * mb), isFalse);
    });
  });

  group('UploadState.isLargeFile + estimatedCompileTime agree with preflight', () {
    test('a preflight-triggering size is also flagged large in-progress', () {
      const large = UploadState(pendingFileSizeBytes: 19 * mb);
      expect(needsLargeFilePreflight(large.pendingFileSizeBytes), isTrue);
      expect(large.isLargeFile, isTrue);
      // The confirm copy quotes a real, non-trivial estimate for a 19MB doc.
      expect(large.estimatedCompileTime, '3–5 min');
    });

    test('a small file is neither preflighted nor flagged large', () {
      const small = UploadState(pendingFileSizeBytes: 2 * mb);
      expect(needsLargeFilePreflight(small.pendingFileSizeBytes), isFalse);
      expect(small.isLargeFile, isFalse);
    });
  });
}
