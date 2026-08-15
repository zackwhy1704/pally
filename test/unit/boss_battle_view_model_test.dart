import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/boss_battle/presentation/boss_battle_view_model.dart';

class _MockDio extends Mock implements Dio {}

const _avatarId = 'av-1';

Map<String, dynamic> _activeBossJson({
  int hpRemaining = 3,
  int hpMax = 3,
  bool defeated = false,
  bool rewardUnlocked = false,
}) =>
    {
      'active': true,
      'id': 'boss-1',
      'topicSlug': 'fractions',
      'hpRemaining': hpRemaining,
      'hpMax': hpMax,
      'defeated': defeated,
      'rewardUnlocked': rewardUnlocked,
      'currentQuestion': defeated
          ? null
          : {
              'id': 'q1',
              'question': 'What is 1/2 of 4?',
              'options': ['1', '2', '3', '4'],
              'sourcePage': 'fractions',
              'explanation': '',
              'pageTitle': 'Fractions',
              'selectionReason': null,
              'correctIndex': null,
            },
    };

/// The VM must never derive hp/defeated itself — it adopts whatever the
/// server response says, verbatim, even when that number could not have
/// been produced by a naive client-side decrement.
void main() {
  setUpAll(() => registerFallbackValue(RequestOptions(path: '/')));

  late _MockDio dio;
  late ProviderContainer container;

  BossBattleViewModel vm() =>
      container.read(bossBattleViewModelProvider(_avatarId).notifier);
  BossBattleState state() =>
      container.read(bossBattleViewModelProvider(_avatarId));

  setUp(() {
    dio = _MockDio();
    when(() => dio.get<dynamic>(any(), options: any(named: 'options')))
        .thenAnswer((_) async => Response(
              data: _activeBossJson(),
              requestOptions: RequestOptions(path: '/'),
            ));
    container = ProviderContainer(overrides: [dioProvider.overrideWithValue(dio)]);
    // Keep the autoDispose notifier alive for the test's duration.
    container.listen(bossBattleViewModelProvider(_avatarId), (_, __) {},
        fireImmediately: true);
  });

  tearDown(() => container.dispose());

  test('build() loads the active boss from GET /boss/active', () async {
    await pumpEventQueue();
    final s = state();
    expect(s.isLoading, isFalse);
    expect(s.hasActiveBoss, isTrue);
    expect(s.boss!.hpRemaining, 3);
    expect(s.boss!.hpMax, 3);
    expect(s.boss!.currentQuestion!.id, 'q1');
  });

  test('no active boss (active:false) — hasActiveBoss is false, not an error', () async {
    when(() => dio.get<dynamic>(any(), options: any(named: 'options')))
        .thenAnswer((_) async => Response(
              data: {'active': false},
              requestOptions: RequestOptions(path: '/'),
            ));
    container.dispose();
    container = ProviderContainer(overrides: [dioProvider.overrideWithValue(dio)]);
    container.listen(bossBattleViewModelProvider(_avatarId), (_, __) {},
        fireImmediately: true);
    await pumpEventQueue();

    final s = state();
    expect(s.isLoading, isFalse);
    expect(s.hasActiveBoss, isFalse);
    expect(s.error, isNull);
  });

  test('attack() with no selected answer never fires a POST', () async {
    await pumpEventQueue();
    await vm().attack();
    verifyNever(() => dio.post<dynamic>(any(),
        data: any(named: 'data'), options: any(named: 'options')));
  });

  test('attack() sends the currently-selected index for the CURRENT question id',
      () async {
    await pumpEventQueue();
    vm().selectAnswer(2);
    when(() => dio.post<dynamic>(any(),
            data: any(named: 'data'), options: any(named: 'options')))
        .thenAnswer((_) async => Response(
              data: {'state': _activeBossJson(hpRemaining: 2), 'hitLanded': true},
              requestOptions: RequestOptions(path: '/'),
            ));

    await vm().attack();

    final captured = verify(() => dio.post<dynamic>('/api/v1/avatars/$_avatarId/boss/boss-1/attack',
            data: captureAny(named: 'data'), options: any(named: 'options')))
        .captured
        .single as Map;
    expect(captured['questionId'], 'q1');
    expect(captured['selectedIndex'], 2);
  });

  test(
      'attack() REPLACES hp from the server response wholesale — never a local '
      'decrement (a naive client would compute 3-1=2; the server here says 0, '
      'and the client must show exactly 0)', () async {
    await pumpEventQueue();
    vm().selectAnswer(0);
    when(() => dio.post<dynamic>(any(),
            data: any(named: 'data'), options: any(named: 'options')))
        .thenAnswer((_) async => Response(
              // Deliberately NOT hpRemaining-1 (would be 2) — proves the client
              // adopts the server number rather than deriving it.
              data: {
                'state': _activeBossJson(hpRemaining: 0, defeated: true, rewardUnlocked: true),
                'hitLanded': true,
              },
              requestOptions: RequestOptions(path: '/'),
            ));

    await vm().attack();

    final s = state();
    expect(s.boss!.hpRemaining, 0);
    expect(s.boss!.defeated, isTrue);
    expect(s.boss!.rewardUnlocked, isTrue);
    expect(s.lastHitLanded, isTrue);
    expect(s.selectedIndex, isNull); // cleared for the next question
  });

  test('attack() re-entry guard: a second call while in-flight fires only one POST',
      () async {
    await pumpEventQueue();
    vm().selectAnswer(0);
    final gate = Completer<void>();
    when(() => dio.post<dynamic>(any(),
        data: any(named: 'data'),
        options: any(named: 'options'))).thenAnswer((_) async {
      await gate.future;
      return Response(
        data: {'state': _activeBossJson(hpRemaining: 2), 'hitLanded': true},
        requestOptions: RequestOptions(path: '/'),
      );
    });

    final first = vm().attack();
    final second = vm().attack(); // must be a no-op — already attacking
    gate.complete();
    await first;
    await second;

    verify(() => dio.post<dynamic>(any(),
        data: any(named: 'data'), options: any(named: 'options'))).called(1);
  });
}
