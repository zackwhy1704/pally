import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/upload/presentation/upload_view_model.dart';

/// Pins the honest-error fix: a 400 is often a server-side WRITE failure (e.g. a
/// value-too-long on a chapter title) — the client must SURFACE the backend's
/// non-blaming message, never override it with "your file is corrupted".
DioException _dio(int status, Object? body) => DioException(
      requestOptions: RequestOptions(path: '/files'),
      response: Response(
        requestOptions: RequestOptions(path: '/files'),
        statusCode: status,
        data: body,
      ),
    );

UploadViewModel _vm() {
  // Override dioProvider so the notifier's build() side-effects don't hit the network.
  final container = ProviderContainer(
    overrides: [dioProvider.overrideWithValue(Dio())],
  );
  addTearDown(container.dispose);
  return container.read(uploadViewModelProvider('a1').notifier);
}

void main() {
  test('400 with a server message surfaces that message, not "corrupted"', () {
    final vm = _vm();
    const serverMsg =
        'Part of this file (like a chapter title) was too long to save. '
        "We've logged it — this is on us, not your file.";
    final msg = vm.friendlyUploadError(_dio(400, {'error': serverMsg}), 'book.pdf');

    expect(msg, serverMsg);
    expect(msg.toLowerCase(), isNot(contains('corrupt')));
  });

  test('400 with NO body falls back to the generic copy', () {
    final msg = _vm().friendlyUploadError(_dio(400, null), 'book.pdf');
    expect(msg, contains("couldn't be read"));
  });
}
