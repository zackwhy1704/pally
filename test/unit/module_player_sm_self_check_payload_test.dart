import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';

/// feat/sm-diagnosis-ui — PATH (a) payload-shape pin. A SPOT_MISTAKE item's
/// typed diagnosis rides `response`, and the self-check rides an ADDITIVE
/// `selfCheck` key on the SAME end-of-stage submit — no new endpoint. HOT_TAKE
/// and CHALLENGE submissions must NOT carry a selfCheck (regression pins).
class _Adapter implements HttpClientAdapter {
  _Adapter(this.startItems);
  final List<dynamic> startItems;
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
      submitCalls.add((body?['submissions'] as List?) ?? const []);
      return _json({'results': [], 'stageComplete': true, 'nextStage': 'PROVE'});
    }
    return _json({'id': 'mod', 'title': 'T', 'stage': 'TEST'});
  }

  Future<Map<String, dynamic>?> _readBody(Stream<Uint8List>? s) async {
    if (s == null) return null;
    final bytes = (await s.toList()).expand((c) => c).toList();
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }

  ResponseBody _json(Map<String, dynamic> b, {int status = 200}) =>
      ResponseBody.fromString(jsonEncode(b), status, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      });

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _sm(String id, int sort) => {
      'id': id,
      'stage': 'TEST',
      'type': 'SPOT_MISTAKE',
      'contentJson': {'problem': 'P $id', 'wrongSolution': 'W $id'},
      'revealJson': {'errorDescription': 'e', 'correctSolution': 'c'},
      'sortOrder': sort,
    };

Map<String, dynamic> _hotTake(String id, int sort) => {
      'id': id,
      'stage': 'TEST',
      'type': 'HOT_TAKE',
      'contentJson': {'statement': 'S $id'},
      'sortOrder': sort,
    };

Future<(ProviderContainer, _Adapter, dynamic)> _boot(List<dynamic> items) async {
  final adapter = _Adapter(items);
  final dio = Dio()..httpClientAdapter = adapter;
  final container =
      ProviderContainer(overrides: [dioProvider.overrideWithValue(dio)]);
  addTearDown(container.dispose);
  final provider = modulePlayerViewModelProvider('av-1', 'mod');
  container.listen(provider, (_, __) {}, fireImmediately: true);
  for (var i = 0;
      i < 80 &&
          (container.read(provider).isLoading ||
              container.read(provider).items.isEmpty);
      i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  return (container, adapter, provider);
}

Map _row(List<dynamic> submissions, String itemId) =>
    submissions.firstWhere((e) => (e as Map)['itemId'] == itemId) as Map;

void main() {
  test('SM diagnosis rides response and selfCheck rides an additive key on submit',
      () async {
    final (container, adapter, provider) =
        await _boot([_sm('sm-1', 200), _hotTake('ht-1', 100)]);
    final vm = container.read(provider.notifier);

    // Student types a diagnosis (recorded via answerTestItem → answers[]) and
    // self-checks "Not quite".
    await vm.answerTestItem('sm-1', 'the sign is flipped');
    vm.setSpotMistakeSelfCheck('sm-1', 'NOT_QUITE');

    await vm.submitStage();

    final multi = adapter.submitCalls.firstWhere((c) => c.length > 1);
    final smRow = _row(multi, 'sm-1');
    expect(smRow['response'], 'the sign is flipped'); // diagnosis persisted as response
    expect(smRow['selfCheck'], 'NOT_QUITE'); // additive self-check key
    // Fail-without-fix: pre-change the SM submission was {itemId,response:'found'}
    // with no selfCheck, so the server recorded a null-signal row.

    // Regression: the HOT_TAKE submission never carries a selfCheck.
    expect(_row(multi, 'ht-1').containsKey('selfCheck'), isFalse);
  });

  test('SM with NO self-check omits the key (legacy null-signal path preserved)',
      () async {
    final (container, adapter, provider) = await _boot([_sm('sm-1', 200)]);
    final vm = container.read(provider.notifier);

    await vm.answerTestItem('sm-1', 'a diagnosis but no self-check chosen');
    await vm.submitStage();

    final submitted = adapter.submitCalls.expand((c) => c).toList();
    final smRow = submitted.firstWhere((e) => (e as Map)['itemId'] == 'sm-1') as Map;
    expect(smRow['response'], 'a diagnosis but no self-check chosen');
    expect(smRow.containsKey('selfCheck'), isFalse); // no forced/defaulted signal
  });
}
