import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';

/// feat/prove-comeback is render-only. This pins that the /self-report submission is
/// UNCHANGED — the body is still exactly {'selfReport': <report>} and hits the same path.
class _Adapter implements HttpClientAdapter {
  Map<String, dynamic>? selfReportBody;
  String? selfReportPath;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.path.endsWith('/self-report')) {
      selfReportPath = options.path;
      final chunks =
          requestStream == null ? <Uint8List>[] : await requestStream.toList();
      final bytes = chunks.expand((c) => c).toList();
      selfReportBody =
          bytes.isEmpty ? null : jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      return _json({'ok': true});
    }
    if (options.path.endsWith('/start')) {
      return _json({'stage': 'PROVE', 'items': <dynamic>[]});
    }
    return _json({'id': 'test-mod', 'title': 'T', 'stage': 'PROVE'});
  }

  ResponseBody _json(Map<String, dynamic> b) => ResponseBody.fromString(
      jsonEncode(b), 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      });

  @override
  void close({bool force = false}) {}
}

void main() {
  test('submitSelfReport body is unchanged: {selfReport: <report>} at /self-report',
      () async {
    final adapter = _Adapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final container =
        ProviderContainer(overrides: [dioProvider.overrideWithValue(dio)]);
    addTearDown(container.dispose);
    final provider = modulePlayerViewModelProvider('av-1', 'mod-1');
    container.listen(provider, (_, __) {}, fireImmediately: true);
    for (var i = 0; i < 60 && container.read(provider).isLoading; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }

    await container.read(provider.notifier).submitSelfReport('item-1', 'YES');

    expect(adapter.selfReportPath,
        '/api/v1/avatars/av-1/modules/mod-1/items/item-1/self-report');
    expect(adapter.selfReportBody, {'selfReport': 'YES'});
  });
}
