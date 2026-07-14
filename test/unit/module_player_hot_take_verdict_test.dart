import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';

/// Client half of the TEST reveal fix (option B). HOT_TAKE — the only secret+graded
/// type — fetches its verdict via a single-item submit; the reveal renders the SERVER
/// verdict, never a fabricated one. The end-of-stage submit stays the sole owner of
/// advancement, so the per-item fetch is SKIPPED for the last item of the stage.
class _RouteAdapter implements HttpClientAdapter {
  _RouteAdapter({required this.startItems, this.failSingleSubmit = false});
  final List<dynamic> startItems;
  final bool failSingleSubmit;

  /// Parsed `submissions` list from every POST /submit (order preserved).
  final List<List<dynamic>> submitCalls = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final path = options.path;
    if (path.endsWith('/start')) {
      return _json({'stage': 'TEST', 'items': startItems});
    }
    if (path.endsWith('/submit')) {
      final body = await _readBody(requestStream);
      final submissions = (body?['submissions'] as List?) ?? const [];
      submitCalls.add(submissions);
      final single = submissions.length == 1;
      if (single && failSingleSubmit) {
        return _json({'error': 'boom'}, status: 500);
      }
      if (single) {
        final itemId = (submissions.first as Map)['itemId'];
        // A WRONG hot-take: server verdict correct=false + the real explanation.
        return _json({
          'results': [
            {
              'itemId': itemId,
              'correct': false,
              'graded': true,
              'answerJson': '{"isTrue":false,"explanation":"They photosynthesise"}',
            }
          ],
          'stageComplete': false,
          'nextStage': null,
        });
      }
      // Multi-item = the end-of-stage submit → advance.
      return _json({'results': [], 'stageComplete': true, 'nextStage': 'PROVE'});
    }
    // GET module detail
    return _json({'id': 'test-mod', 'title': 'T', 'stage': 'TEST'});
  }

  Future<Map<String, dynamic>?> _readBody(Stream<Uint8List>? s) async {
    if (s == null) return null;
    final chunks = await s.toList();
    final bytes = chunks.expand((c) => c).toList();
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }

  ResponseBody _json(Map<String, dynamic> body, {int status = 200}) =>
      ResponseBody.fromString(jsonEncode(body), status,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType]
          });

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _hotTake(String id, int sort) => {
      'id': id,
      'stage': 'TEST',
      'type': 'HOT_TAKE',
      'contentJson': {'statement': 'Statement $id'},
      'sortOrder': sort,
    };

Map<String, dynamic> _challenge(String id, int sort) => {
      'id': id,
      'stage': 'TEST',
      'type': 'CHALLENGE',
      'contentJson': {'question': 'Q $id'},
      'revealJson': {'explanation': 'served explanation'},
      'sortOrder': sort,
    };

Future<(ProviderContainer, _RouteAdapter, dynamic)> _boot(
    List<dynamic> startItems, {bool failSingleSubmit = false}) async {
  final adapter = _RouteAdapter(startItems: startItems, failSingleSubmit: failSingleSubmit);
  final dio = Dio()..httpClientAdapter = adapter;
  final container = ProviderContainer(overrides: [dioProvider.overrideWithValue(dio)]);
  addTearDown(container.dispose);
  final provider = modulePlayerViewModelProvider('av-1', 'test-mod');
  container.listen(provider, (_, __) {}, fireImmediately: true);
  for (var i = 0; i < 80 &&
      (container.read(provider).isLoading || container.read(provider).items.isEmpty);
      i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  return (container, adapter, provider);
}

void main() {
  test('non-last HOT_TAKE: per-item fetch stores the SERVER verdict (wrong + explanation)',
      () async {
    // Two items so the hot-take is NOT last → its verdict is fetched.
    final (container, adapter, provider) =
        await _boot([_hotTake('ht-1', 100), _challenge('ch-1', 300)]);

    await container.read(provider.notifier).answerTestItem('ht-1', 'AGREE');

    final s = container.read(provider);
    expect(s.hotTakeVerdicts['ht-1']?.correct, isFalse);
    expect(s.hotTakeVerdicts['ht-1']?.explanation, 'They photosynthesise');
    expect(s.hotTakeVerdictPending.contains('ht-1'), isFalse);
    // Exactly one per-item submit, carrying only that item (never advances).
    expect(adapter.submitCalls, hasLength(1));
    expect(adapter.submitCalls.first, hasLength(1));
  });

  test('per-item fetch FAILURE: no verdict fabricated, item stays for end-of-stage submit',
      () async {
    final (container, adapter, provider) = await _boot(
        [_hotTake('ht-1', 100), _challenge('ch-1', 300)],
        failSingleSubmit: true);

    await container.read(provider.notifier).answerTestItem('ht-1', 'AGREE');

    final s = container.read(provider);
    expect(s.hotTakeVerdicts.containsKey('ht-1'), isFalse); // NO fabricated verdict
    expect(s.hotTakeVerdictPending.contains('ht-1'), isFalse);
    expect(s.items.any((i) => i.id == 'ht-1'), isTrue); // still in the stage to submit
  });

  test('NO-ADVANCE INVARIANT: a lone (last) HOT_TAKE is NOT per-item-submitted', () async {
    // Single item → it is the last item → the per-item fetch is skipped, so a per-item
    // call can never be the submission that completes/advances the stage.
    final (container, adapter, provider) = await _boot([_hotTake('only', 100)]);

    await container.read(provider.notifier).answerTestItem('only', 'AGREE');

    expect(adapter.submitCalls, isEmpty); // never submitted early
    expect(container.read(provider).hotTakeVerdicts.containsKey('only'), isFalse);
    expect(container.read(provider).revealedItems.contains('only'), isTrue); // still revealed
  });

  test('end-of-stage submit sends ALL items and advances (advancement stays here)',
      () async {
    final (container, adapter, provider) =
        await _boot([_hotTake('ht-1', 100), _challenge('ch-1', 300)]);

    await container.read(provider.notifier).submitStage();

    // The multi-item end-of-stage submit carried BOTH items.
    final multi = adapter.submitCalls.firstWhere((c) => c.length > 1, orElse: () => const []);
    final ids = multi.map((e) => (e as Map)['itemId']).toSet();
    expect(ids, containsAll(<String>{'ht-1', 'ch-1'}));
  });
}
