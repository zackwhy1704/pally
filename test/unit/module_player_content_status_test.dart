import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';

/// Pins the client half of the module-PLAYABILITY fix: a stage that serves no
/// usable content must land in the transient `isContentUpdating` (bounce-to-
/// Library) state — NEVER a red error whose "Try again" re-POSTs /start into the
/// identical empty result (the retry-spin). Two ways the server can signal it:
///  1. the authoritative `contentStatus` field (CONTENT_UPDATING / UNAVAILABLE);
///  2. items served but all substantively blank (skipped client-side).
class _RouteAdapter implements HttpClientAdapter {
  _RouteAdapter(this.startBody);
  final Map<String, dynamic> startBody;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    // GET module-detail → a minimal module; POST /start → the scenario payload.
    final body = options.path.contains('/start')
        ? startBody
        : <String, dynamic>{'id': 'test-mod', 'title': 'Test Module', 'stage': 'TEST'};
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<ModulePlayerState> _runStart(Map<String, dynamic> startBody) async {
  final dio = Dio()..httpClientAdapter = _RouteAdapter(startBody);
  final container = ProviderContainer(
    overrides: [dioProvider.overrideWithValue(dio)],
  );
  addTearDown(container.dispose);

  final provider = modulePlayerViewModelProvider('av-1', 'test-mod');
  // Hold a subscription so the autoDispose provider isn't torn down before its
  // async build()→_loadModule→startStage chain runs (a bare read would dispose it
  // immediately and the state updates would land on a dead notifier).
  container.listen(provider, (_, __) {}, fireImmediately: true);
  // Let the async GET→POST chain settle.
  for (var i = 0; i < 60 && container.read(provider).isLoading; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  return container.read(provider);
}

void main() {
  test('contentStatus CONTENT_UPDATING → isContentUpdating, no error (bounce, not retry)',
      () async {
    final s = await _runStart({
      'stage': 'TEST',
      'items': <dynamic>[],
      'contentStatus': 'CONTENT_UPDATING',
    });
    expect(s.isContentUpdating, isTrue);
    expect(s.error, isNull);
    expect(s.isLoading, isFalse);
  });

  test('contentStatus CONTENT_UNAVAILABLE → isContentUpdating, no error', () async {
    final s = await _runStart({
      'stage': 'TEST',
      'items': <dynamic>[],
      'contentStatus': 'CONTENT_UNAVAILABLE',
    });
    expect(s.isContentUpdating, isTrue);
    expect(s.error, isNull);
  });

  test('items served but ALL blank → isContentUpdating, NOT a retryable error', () async {
    // A HOT_TAKE with an empty explanation is a blank reveal → skipped → items
    // empty. Pre-fix this became a red "Try again" that re-POSTed forever.
    final s = await _runStart({
      'stage': 'TEST',
      'items': [
        {
          'id': 'blank-1',
          'stage': 'TEST',
          'type': 'HOT_TAKE',
          'contentJson': {'statement': 's', 'isTrue': true},
          'answerJson': {'explanation': ''},
          'sortOrder': 0,
        }
      ],
    });
    expect(s.isContentUpdating, isTrue,
        reason: 'all-blank must be the transient bounce state, not a retry-spin');
    expect(s.error, isNull);
  });

  test('normal servable items → plays, not the updating state', () async {
    final s = await _runStart({
      'stage': 'TEST',
      'items': [
        {
          'id': 'ok-1',
          'stage': 'TEST',
          'type': 'HOT_TAKE',
          'contentJson': {'statement': 's', 'isTrue': true, 'explanation': 'e'},
          'answerJson': {'explanation': 'because e'},
          'sortOrder': 0,
        }
      ],
    });
    expect(s.isContentUpdating, isFalse);
    expect(s.error, isNull);
    expect(s.totalItems, 1);
  });
}
