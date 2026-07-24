import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/core/local_db/pally_database.dart';
import 'package:pally/features/chat/presentation/chat_view_model.dart';
import 'package:pally/shared/models/chat_message.dart';

/// Pins a live pre-existing bug fix (unrelated to the report-content feature):
/// `_syncFeedbackToBackend` posted the feedback type under JSON key `type`,
/// but the backend record field is `feedbackType` (bare record, no @JsonAlias).
/// Every feedback POST bound null server-side → 400, silently swallowed by the
/// fire-and-forget catch. This asserts the POST body uses key `feedbackType`.
class _Adapter implements HttpClientAdapter {
  Map<String, dynamic>? feedbackBody;
  String? feedbackPath;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.path.contains('/feedback')) {
      feedbackPath = options.path;
      final chunks =
          requestStream == null ? <Uint8List>[] : await requestStream.toList();
      final bytes = chunks.expand((c) => c).toList();
      feedbackBody = bytes.isEmpty
          ? null
          : jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      return _json({'ok': true});
    }
    // Every other call ChatViewModel.build() fires (avatar load, history,
    // session-start) is wrapped in its own try/catch and degrades
    // gracefully — fail them so the test doesn't need to model their
    // response shapes.
    throw DioException(requestOptions: options, type: DioExceptionType.unknown);
  }

  ResponseBody _json(Map<String, dynamic> b) => ResponseBody.fromString(
        jsonEncode(b),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        },
      );

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
      'feedback sync posts the type under key feedbackType (matches backend record field)',
      () async {
    final adapter = _Adapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final db = PallyDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(overrides: [
      dioProvider.overrideWithValue(dio),
      pallyDatabaseProvider.overrideWithValue(db),
    ]);
    addTearDown(container.dispose);
    addTearDown(db.close);

    final provider = chatViewModelProvider('av-1');
    container.listen(provider, (_, __) {}, fireImmediately: true);

    await container
        .read(provider.notifier)
        .submitFeedback('msg-1', FeedbackType.wrong);

    // submitFeedback fires the backend sync unawaited — poll for it to land.
    for (var i = 0; i < 40 && adapter.feedbackBody == null; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }

    expect(adapter.feedbackPath, '/api/v1/avatars/av-1/chat/msg-1/feedback');
    expect(adapter.feedbackBody, {'feedbackType': 'WRONG'});
  });
}
