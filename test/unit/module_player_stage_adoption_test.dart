import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';

/// The module player must ADOPT the server's stage from the /start response — it is
/// authoritative. A revision returns stage=PROVE while the client still holds COMPLETE
/// (the finished module the student re-opened); without adopting it, state.stage stays
/// COMPLETE → the header chip reads "Complete" and the body falls to 'Unknown stage'.
class _RouteAdapter implements HttpClientAdapter {
  _RouteAdapter({required this.detailStage, required this.startBody});
  final String detailStage;
  final Map<String, dynamic> startBody;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final body = options.path.endsWith('/start')
        ? startBody
        : <String, dynamic>{'id': 'test-mod', 'title': 'T', 'stage': detailStage};
    return ResponseBody.fromString(jsonEncode(body), 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType]
    });
  }

  @override
  void close({bool force = false}) {}
}

Future<ModulePlayerState> _runStart(
    {required String detailStage, required Map<String, dynamic> startBody}) async {
  final dio = Dio()
    ..httpClientAdapter = _RouteAdapter(detailStage: detailStage, startBody: startBody);
  final container = ProviderContainer(overrides: [dioProvider.overrideWithValue(dio)]);
  addTearDown(container.dispose);
  final provider = modulePlayerViewModelProvider('av-1', 'test-mod');
  container.listen(provider, (_, __) {}, fireImmediately: true);
  for (var i = 0; i < 80 && container.read(provider).isLoading; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  return container.read(provider);
}

void main() {
  test('REGRESSION: revision start on a COMPLETE module adopts PROVE stage + revision',
      () async {
    // Module detail says COMPLETE (it was finished); /start (revision) returns PROVE.
    // Pre-fix, state.stage stayed COMPLETE → "Complete" chip + 'Unknown stage' body.
    final s = await _runStart(detailStage: 'COMPLETE', startBody: {
      'stage': 'PROVE',
      'revision': true,
      'items': [
        {
          'id': 'pv-1',
          'stage': 'PROVE',
          'type': 'PROVE_QUESTION',
          'contentJson': {'question': 'Explain in your own words'},
          'sortOrder': 0,
        }
      ],
    });
    expect(s.stage, 'PROVE', reason: 'the served stage must be adopted');
    expect(s.isRevision, isTrue);
    expect(s.isContentUpdating, isFalse);
    expect(s.error, isNull);
    expect(s.totalItems, 1);
  });

  test('normal start with a matching stage is unchanged', () async {
    final s = await _runStart(detailStage: 'LEARN', startBody: {
      'stage': 'LEARN',
      'items': [
        {
          'id': 'l-1',
          'stage': 'LEARN',
          'type': 'MICRO_CARD',
          'contentJson': {'title': 'T', 'body': 'B'},
          'sortOrder': 0,
        }
      ],
    });
    expect(s.stage, 'LEARN');
    expect(s.isRevision, isFalse);
    expect(s.error, isNull);
  });
}
