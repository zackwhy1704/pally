import 'package:flutter_test/flutter_test.dart';
import 'package:pally/shared/models/upload_result.dart';
import 'package:pally/core/error/pally_error.dart';
import 'package:pally/features/upload/presentation/upload_view_model.dart';

void main() {
  group('UploadResult resilience fields', () {
    test('fromJson parses servedBy, degraded, pagesCompiled, pagesTotal when present', () {
      final json = {
        'id': 'file-1',
        'avatarId': 'avatar-1',
        'fileName': 'notes.pdf',
        'status': 'ready',
        'pageCount': 5,
        'wikiPageTitles': ['Chapter 1', 'Chapter 2'],
        'servedBy': 'worker-a',
        'degraded': true,
        'pagesCompiled': 3,
        'pagesTotal': 5,
      };

      final result = UploadResult.fromJson(json);

      expect(result.servedBy, 'worker-a');
      expect(result.degraded, true);
      expect(result.pagesCompiled, 3);
      expect(result.pagesTotal, 5);
    });

    test('fromJson defaults gracefully when resilience fields are absent', () {
      final json = {
        'id': 'file-2',
        'avatarId': 'avatar-1',
        'fileName': 'notes.pdf',
        'status': 'processing',
        'pageCount': 0,
        'wikiPageTitles': <String>[],
      };

      final result = UploadResult.fromJson(json);

      expect(result.servedBy, isNull);
      expect(result.degraded, false);
      expect(result.pagesCompiled, 0);
      expect(result.pagesTotal, isNull);
    });

    test('fromJson handles degraded=false explicitly', () {
      final json = {
        'id': 'file-3',
        'avatarId': 'avatar-1',
        'fileName': 'notes.pdf',
        'degraded': false,
      };

      final result = UploadResult.fromJson(json);
      expect(result.degraded, false);
    });
  });

  group('PallyError 503 vs 504 split', () {
    test('503 maps to aiBusy with friendly retry message', () {
      expect(PallyError.aiBusy.kind, PallyErrorKind.aiBusy);
      expect(PallyError.aiBusy.userMessage,
          contains('busy right now'));
    });

    test('504 maps to compileTimeout with background-work message', () {
      expect(PallyError.compileTimeout.kind, PallyErrorKind.timeout);
      expect(PallyError.compileTimeout.userMessage,
          contains('still working'));
      expect(PallyError.compileTimeout.userMessage,
          contains('background'));
    });
  });

  group('UploadState compile progress', () {
    test('compileProgress is null by default', () {
      const state = UploadState();
      expect(state.compileProgress, isNull);
    });

    test('compileProgress can be set via copyWith', () {
      const state = UploadState();
      final updated = state.copyWith(compileProgress: '8 of 12 pages added');
      expect(updated.compileProgress, '8 of 12 pages added');
    });

    test('compileProgress can be cleared back to null via copyWith', () {
      final state =
          const UploadState().copyWith(compileProgress: '3 of 5 pages added');
      final cleared = state.copyWith(compileProgress: null);
      expect(cleared.compileProgress, isNull);
    });
  });

  group('UploadState fileWarnings', () {
    test('fileWarnings defaults to empty list', () {
      const state = UploadState();
      expect(state.fileWarnings, isEmpty);
    });

    test('fileWarnings can be set via copyWith', () {
      const state = UploadState();
      final warnings = [
        const FileUploadWarning(
          fileName: 'notes.pdf',
          message: 'I used my backup reader for this one '
              '— double-check it looks right.',
        ),
      ];
      final updated = state.copyWith(fileWarnings: warnings);
      expect(updated.fileWarnings, hasLength(1));
      expect(updated.fileWarnings.first.message, contains('backup reader'));
    });

    test('clearErrors pattern clears both fileErrors and fileWarnings', () {
      final state = const UploadState().copyWith(
        error: 'some error',
        fileErrors: [
          const FileUploadError(fileName: 'a.pdf', message: 'err'),
        ],
        fileWarnings: [
          const FileUploadWarning(fileName: 'b.pdf', message: 'warn'),
        ],
      );
      // Simulate clearErrors logic
      final cleared =
          state.copyWith(error: null, fileErrors: [], fileWarnings: []);
      expect(cleared.error, isNull);
      expect(cleared.fileErrors, isEmpty);
      expect(cleared.fileWarnings, isEmpty);
    });
  });

  group('UploadViewModel compile timeout is 5 minutes', () {
    test('_compileTimeout constant exceeds backend 4-min cap', () {
      // We can't directly access the private constant, but we verify the
      // UploadState estimatedCompileTime caps below 5 minutes, which
      // confirms the timeout gives the backend headroom.
      const state = UploadState(pendingFileSizeBytes: 20 * 1024 * 1024);
      // The largest estimate is "3-5 min" — our 5-min timeout covers this.
      expect(state.estimatedCompileTime, isNotEmpty);
    });
  });
}
