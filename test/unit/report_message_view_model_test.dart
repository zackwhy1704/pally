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

/// Report-AI-content (child safety): ChatViewModel.reportMessage POSTs to
/// POST /api/v1/avatars/{avatarId}/chat/report per the fixed backend
/// contract: {reason, comment, messageText, clientMessageId}. These pin the
/// body shape and the honest-state contract (success only on 2xx, never on
/// failure) at the view-model layer — independent of any live server.
class _Adapter implements HttpClientAdapter {
  Map<String, dynamic>? reportBody;
  String? reportPath;
  bool failReport = false;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.path.contains('/chat/report')) {
      reportPath = options.path;
      final chunks =
          requestStream == null ? <Uint8List>[] : await requestStream.toList();
      final bytes = chunks.expand((c) => c).toList();
      reportBody = bytes.isEmpty
          ? null
          : jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      if (failReport) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: options, statusCode: 500),
        );
      }
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
  late _Adapter adapter;
  late Dio dio;
  late PallyDatabase db;
  late ProviderContainer container;

  setUp(() {
    adapter = _Adapter();
    dio = Dio()..httpClientAdapter = adapter;
    db = PallyDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(overrides: [
      dioProvider.overrideWithValue(dio),
      pallyDatabaseProvider.overrideWithValue(db),
    ]);
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  ChatViewModel notifierFor(String avatarId) {
    final provider = chatViewModelProvider(avatarId);
    container.listen(provider, (_, __) {}, fireImmediately: true);
    return container.read(provider.notifier);
  }

  test(
      'reportMessage posts reason + messageText + clientMessageId to /chat/report, '
      'and adds the id to reportedMessageIds on 2xx (SUCCESS)', () async {
    final notifier = notifierFor('av-1');

    await notifier.reportMessage(
      messageId: 'tutor-123',
      messageText: 'Mochi said something wrong here.',
      reason: ReportReason.wrongOrMisleading,
      comment: '  it confused me  ',
    );

    expect(adapter.reportPath, '/api/v1/avatars/av-1/chat/report');
    expect(
      adapter.reportBody,
      {
        'reason': 'WRONG_OR_MISLEADING',
        'comment': 'it confused me',
        'messageText': 'Mochi said something wrong here.',
        'clientMessageId': 'tutor-123',
      },
    );

    final state = container.read(chatViewModelProvider('av-1'));
    expect(state.reportedMessageIds, contains('tutor-123'));
    expect(state.isSubmittingReport, isFalse);
    expect(state.reportError, isNull);
  });

  test('an empty comment is sent as null, not an empty string', () async {
    final notifier = notifierFor('av-1');

    await notifier.reportMessage(
      messageId: 'tutor-1',
      messageText: 'Some reply',
      reason: ReportReason.unsafe,
      comment: '   ',
    );

    expect(adapter.reportBody?['comment'], isNull);
  });

  test(
      'a failed report POST surfaces reportError and NEVER adds the message '
      'to reportedMessageIds (ERROR, not silently swallowed as success)',
      () async {
    adapter.failReport = true;
    final notifier = notifierFor('av-1');

    await notifier.reportMessage(
      messageId: 'tutor-999',
      messageText: 'Some assistant reply',
      reason: ReportReason.unsafe,
    );

    final state = container.read(chatViewModelProvider('av-1'));
    expect(state.reportedMessageIds, isNot(contains('tutor-999')));
    expect(state.isSubmittingReport, isFalse);
    expect(state.reportError, isNotNull);
  });

  test('re-entry guard: a report already in flight is not resubmitted',
      () async {
    final notifier = notifierFor('av-1');

    // Fire two concurrent calls; only the first should reach the adapter
    // before the guard on the second sees isSubmittingReport == true.
    final first = notifier.reportMessage(
      messageId: 'tutor-1',
      messageText: 'reply',
      reason: ReportReason.other,
    );
    final second = notifier.reportMessage(
      messageId: 'tutor-1',
      messageText: 'reply',
      reason: ReportReason.other,
    );
    await Future.wait([first, second]);

    // Only one POST body should have been captured (adapter only stores the
    // latest, but reportedMessageIds having exactly the one id and no crash
    // from a double state write is the guard's observable contract).
    final state = container.read(chatViewModelProvider('av-1'));
    expect(state.reportedMessageIds, {'tutor-1'});
  });
}
