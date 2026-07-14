import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/avatar_hub/presentation/avatar_hub_view_model.dart';
import 'package:pally/features/modules/presentation/module_list_view_model.dart';
import 'package:pally/features/modules/presentation/module_player_view_model.dart';
import 'package:pally/features/quiz/providers/quiz_status_provider.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/learning_module.dart';
import 'package:pally/shared/models/mochi_character.dart';

/// FIX B: after an in-player stage ADVANCE, the module-list, avatar-hub, and
/// quiz-status providers (which live under the nav stack while the player is pushed)
/// must be invalidated so popping back shows fresh stage/mastery/CTA. A submit that
/// does NOT advance must invalidate nothing (no refetch churn mid-stage).
class _Adapter implements HttpClientAdapter {
  _Adapter({required this.advanceOnSubmit});
  final bool advanceOnSubmit;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final path = options.path;
    if (path.endsWith('/start')) {
      return _json({
        'stage': 'TEST',
        'items': [
          {
            'id': 'ht-1',
            'stage': 'TEST',
            'type': 'HOT_TAKE',
            'contentJson': {'statement': 's'},
            'sortOrder': 0,
          }
        ],
      });
    }
    if (path.endsWith('/submit')) {
      return advanceOnSubmit
          ? _json({'results': [], 'stageComplete': true, 'nextStage': 'PROVE'})
          : _json({'results': [], 'stageComplete': false, 'nextStage': null});
    }
    return _json({'id': 'test-mod', 'title': 'T', 'stage': 'TEST'});
  }

  ResponseBody _json(Map<String, dynamic> b) => ResponseBody.fromString(
      jsonEncode(b), 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      });

  @override
  void close({bool force = false}) {}
}

/// Records every provider disposed (invalidate disposes synchronously).
class _DisposeSpy extends ProviderObserver {
  final List<String> disposed = [];
  @override
  void didDisposeProvider(ProviderBase<Object?> provider, ProviderContainer container) {
    disposed.add(provider.toString());
  }
}

class _SpyModuleList extends ModuleListViewModel {
  @override
  Future<List<LearningModule>> build(String avatarId) async => const [];
}

class _SpyHub extends AvatarHubViewModel {
  @override
  Future<AvatarHubData> build(String avatarId) async => AvatarHubData(
        avatar: Avatar(
            id: avatarId, name: 'X', character: MochiCharacter.mochi, subject: 'Math'),
        moduleCount: 0,
        avgMasteryPct: 0,
      );
}

Future<(_DisposeSpy, ProviderContainer)> _run({required bool advance}) async {
  final spy = _DisposeSpy();
  final dio = Dio()..httpClientAdapter = _Adapter(advanceOnSubmit: advance);
  final container = ProviderContainer(
    observers: [spy],
    overrides: [
      dioProvider.overrideWithValue(dio),
      moduleListViewModelProvider('av-1').overrideWith(_SpyModuleList.new),
      avatarHubViewModelProvider('av-1').overrideWith(_SpyHub.new),
      quizStatusProvider('av-1').overrideWith((ref) async =>
          const QuizStatus(takenToday: false, totalTopics: 0, masteredTopics: 0)),
    ],
  );
  addTearDown(container.dispose);

  final player = modulePlayerViewModelProvider('av-1', 'test-mod');
  // Keep the three surfaces alive so an invalidate actually disposes them.
  container.listen(moduleListViewModelProvider('av-1'), (_, __) {}, fireImmediately: true);
  container.listen(avatarHubViewModelProvider('av-1'), (_, __) {}, fireImmediately: true);
  container.listen(quizStatusProvider('av-1'), (_, __) {}, fireImmediately: true);
  container.listen(player, (_, __) {}, fireImmediately: true);

  for (var i = 0; i < 80 &&
      (container.read(player).isLoading || container.read(player).items.isEmpty);
      i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  spy.disposed.clear(); // ignore setup disposals; measure only the submit
  await container.read(player.notifier).submitStage();
  await Future<void>.delayed(const Duration(milliseconds: 10));
  return (spy, container);
}

bool _wasInvalidated(_DisposeSpy spy, String needle) =>
    spy.disposed.any((d) => d.contains(needle));

void main() {
  test('advancing submit (nextStage=PROVE) invalidates list, hub, and quiz-status',
      () async {
    final (spy, _) = await _run(advance: true);
    expect(_wasInvalidated(spy, 'moduleListViewModel'), isTrue);
    expect(_wasInvalidated(spy, 'avatarHubViewModel'), isTrue);
    // quizStatusProvider is a plain FutureProvider → toString shows its value type.
    expect(_wasInvalidated(spy, 'QuizStatus'), isTrue);
  });

  test('non-advancing submit invalidates NONE (no mid-stage refetch churn)', () async {
    final (spy, _) = await _run(advance: false);
    expect(_wasInvalidated(spy, 'moduleListViewModel'), isFalse);
    expect(_wasInvalidated(spy, 'avatarHubViewModel'), isFalse);
    expect(_wasInvalidated(spy, 'QuizStatus'), isFalse);
  });
}
