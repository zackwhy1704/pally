import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/classroom/presentation/classroom_session_view_model.dart';

class _MockDio extends Mock implements Dio {}

const _avatarId = 'av-1';

Map<String, dynamic> _stateJson({
  int hpRemaining = 2,
  int hpMax = 2,
  bool defeated = false,
  String status = 'ACTIVE',
  int participantCount = 1,
}) =>
    {
      'sessionId': 'session-1',
      'status': status,
      'topicSlug': 'fractions',
      'hpRemaining': hpRemaining,
      'hpMax': hpMax,
      'defeated': defeated,
      'participantCount': participantCount,
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

/// The client half of "inline rejection UI if moderation blocks the
/// nickname" (the block DECISION itself is backend-tested, with
/// no-op-then-restore, in ClassroomSessionServiceTest) — this proves the
/// view model surfaces the server's 422 as nicknameRejectedMessage and
/// never marks the student joined.
void main() {
  setUpAll(() => registerFallbackValue(RequestOptions(path: '/')));

  late _MockDio dio;
  late ProviderContainer container;

  ClassroomSessionViewModel vm() =>
      container.read(classroomSessionViewModelProvider(_avatarId).notifier);
  ClassroomSessionState state() =>
      container.read(classroomSessionViewModelProvider(_avatarId));

  setUp(() {
    dio = _MockDio();
    container = ProviderContainer(overrides: [dioProvider.overrideWithValue(dio)]);
    container.listen(classroomSessionViewModelProvider(_avatarId), (_, __) {},
        fireImmediately: true);
  });

  tearDown(() => container.dispose());

  test('join success sets participantToken/nickname/state, never rejects', () async {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
        .thenAnswer((_) async => Response(
              data: {
                'participantToken': 'tok-1',
                'nickname': 'Star Kid',
                'state': _stateJson(),
              },
              requestOptions: RequestOptions(path: '/'),
            ));
    // The live stream connect will fail harmlessly (no stream stub) — caught
    // internally, doesn't affect join's own state.
    when(() => dio.get<ResponseBody>(any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options')))
        .thenThrow(Exception('no stream in this test'));

    await vm().join('ABC123', 'Star Kid');

    final s = state();
    expect(s.joined, isTrue);
    expect(s.participantToken, 'tok-1');
    expect(s.nickname, 'Star Kid');
    expect(s.nicknameRejectedMessage, isNull);
    expect(s.state!.hpRemaining, 2);
  });

  test('join blocked by moderation (422) sets nicknameRejectedMessage, never joins',
      () async {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 422,
          data: {
            'data': null,
            'error': "That name isn't allowed — try a different name.",
            'status': 422,
          },
        ),
      ),
    );

    await vm().join('ABC123', 'Bad Name');

    final s = state();
    expect(s.joined, isFalse);
    expect(s.participantToken, isNull);
    expect(s.nicknameRejectedMessage,
        "That name isn't allowed — try a different name.");
    expect(s.error, isNull); // distinct from a generic error
  });

  test('attack re-entry guard: a second call while in-flight fires only one POST',
      () async {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
        .thenAnswer((_) async => Response(
              data: {
                'participantToken': 'tok-1',
                'nickname': 'Star Kid',
                'state': _stateJson(),
              },
              requestOptions: RequestOptions(path: '/'),
            ));
    when(() => dio.get<ResponseBody>(any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options')))
        .thenThrow(Exception('no stream in this test'));
    await vm().join('ABC123', 'Star Kid');
    vm().selectAnswer(1);
    clearInteractions(dio); // drop the join call so .called() below counts attacks only

    // Re-stub AFTER join already completed above (using the earlier instant
    // stub) — subsequent post calls (the attacks) now route to this gate.
    final gate = Completer<Response<dynamic>>();
    when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
        .thenAnswer((_) => gate.future);

    final first = vm().attack();
    final second = vm().attack(); // must be a no-op — already attacking
    gate.complete(Response(
      data: {'state': _stateJson(hpRemaining: 1), 'hitLanded': true},
      requestOptions: RequestOptions(path: '/'),
    ));
    await first;
    await second;

    verify(() => dio.post<dynamic>(any(), data: any(named: 'data'))).called(1);
  });

  group('live SSE stream parsing', () {
    late StreamController<Uint8List> chunks;

    setUp(() {
      chunks = StreamController<Uint8List>();
    });

    Future<void> joinWithStream() async {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'participantToken': 'tok-1',
                  'nickname': 'Star Kid',
                  'state': _stateJson(),
                },
                requestOptions: RequestOptions(path: '/'),
              ));
      when(() => dio.get<ResponseBody>(any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options')))
          .thenAnswer((_) async => Response(
                data: ResponseBody(chunks.stream, 200),
                requestOptions: RequestOptions(path: '/'),
              ));
      await vm().join('ABC123', 'Star Kid');
      await pumpEventQueue();
    }

    void emit(String sse) {
      chunks.add(Uint8List.fromList(utf8.encode(sse)));
    }

    test('hit event updates shared HP and prepends to recentHits', () async {
      await joinWithStream();

      emit('event: hit\n'
          'data: {"nickname":"Star Kid","hitLanded":true,"hpRemaining":1,"hpMax":2}\n'
          '\n');
      await pumpEventQueue();

      final s = state();
      expect(s.state!.hpRemaining, 1); // NOT locally derived — this is the pushed value
      expect(s.recentHits, hasLength(1));
      expect(s.recentHits.first.nickname, 'Star Kid');
      expect(s.recentHits.first.hitLanded, isTrue);
    });

    test('question event replaces the current question', () async {
      await joinWithStream();

      emit('event: question\n'
          'data: {"id":"q2","question":"Next?","options":["a","b"],"sourcePage":"fractions","explanation":"","pageTitle":"Fractions","selectionReason":null,"correctIndex":null}\n'
          '\n');
      await pumpEventQueue();

      expect(state().state!.currentQuestion!.id, 'q2');
    });

    test('defeated event marks defeated and clears the question', () async {
      await joinWithStream();

      emit('event: defeated\ndata: {}\n\n');
      await pumpEventQueue();

      final s = state();
      expect(s.state!.defeated, isTrue);
      expect(s.state!.currentQuestion, isNull);
    });

    test('ended event marks the session ENDED', () async {
      await joinWithStream();

      emit('event: ended\ndata: {}\n\n');
      await pumpEventQueue();

      expect(state().state!.status, 'ENDED');
    });

    tearDown(() {
      if (!chunks.isClosed) chunks.close();
    });
  });
}
