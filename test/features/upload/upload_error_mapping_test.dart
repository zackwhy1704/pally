import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/upload/presentation/upload_error_localizer.dart';
import 'package:pally/features/upload/presentation/upload_view_model.dart';
import 'package:pally/l10n/app_localizations.dart';

/// Pins the honest-error fix: a 400 is often a server-side WRITE failure (e.g. a
/// value-too-long on a chapter title) — the client must SURFACE the backend's
/// non-blaming message, never override it with "your file is corrupted".
///
/// The decision now lives in the error's KIND (identity), resolved to wording at
/// display via [localizedUploadError]. serverMessage carries the backend copy
/// verbatim; corrupted400 is the bodyless fallback.
DioException _dio(int status, Object? body) => DioException(
      requestOptions: RequestOptions(path: '/files'),
      response: Response(
        requestOptions: RequestOptions(path: '/files'),
        statusCode: status,
        data: body,
      ),
    );

UploadViewModel _vm() {
  final container = ProviderContainer(
    overrides: [dioProvider.overrideWithValue(Dio())],
  );
  addTearDown(container.dispose);
  return container.read(uploadViewModelProvider('a1').notifier);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('400 with a server message surfaces it verbatim, not "corrupted"',
      () async {
    const serverMsg =
        'Part of this file (like a chapter title) was too long to save. '
        "We've logged it — this is on us, not your file.";
    final err =
        _vm().friendlyUploadError(_dio(400, {'error': serverMsg}), 'book.pdf');

    // Identity: it's the backend's own message, not the corrupted-file copy.
    expect(err.kind, UploadErrorKind.serverMessage);
    expect(err.detail, serverMsg);

    // Wording: the resolver passes it through verbatim in every locale.
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final zh = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(localizedUploadError(en, err), serverMsg);
    expect(localizedUploadError(zh, err), serverMsg);
    expect(localizedUploadError(en, err).toLowerCase(),
        isNot(contains('corrupt')));
  });

  test('400 with NO body falls back to the corrupted-file kind + copy',
      () async {
    final err = _vm().friendlyUploadError(_dio(400, null), 'book.pdf');
    expect(err.kind, UploadErrorKind.corrupted400);
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(localizedUploadError(en, err), contains("couldn't be read"));
  });
}
