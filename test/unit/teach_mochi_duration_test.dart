import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/teach_mochi/presentation/teach_mochi_view_model.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _resp(Map<String, dynamic> data, String path) =>
    Response<Map<String, dynamic>>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
  });

  test('submit sends a non-negative durationSeconds (ITEM 6)', () async {
    final dio = _MockDio();

    // _loadTopics GET → one topic with a slug.
    when(() => dio.get<Map<String, dynamic>>(any()))
        .thenAnswer((_) async => _resp({
              'data': {
                'pages': [
                  {
                    'id': 'p1',
                    'avatarId': 'a1',
                    'title': 'Photosynthesis',
                    'slug': 'photosynthesis',
                    'content': 'body',
                  }
                ]
              }
            }, '/api/v1/avatars/a1/wiki/pages'));

    // Capture the teach POST payload.
    Map<String, dynamic>? sentBody;
    when(() => dio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((invocation) async {
      sentBody = invocation.namedArguments[#data] as Map<String, dynamic>;
      return _resp({
        'data': {
          'score': 2,
          'totalConcepts': 3,
          'xpEarned': 10,
          'coveredConcepts': ['light'],
          'missedConcepts': ['water'],
          'feedback': 'Nice try!',
        }
      }, '/api/v1/avatars/a1/teach');
    });

    final container = ProviderContainer(
      overrides: [dioProvider.overrideWithValue(dio)],
    );
    addTearDown(container.dispose);

    // Keep the autoDispose provider alive while the async GET resolves.
    final sub = container.listen(
      teachMochiViewModelProvider('a1'),
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    final notifier = container.read(teachMochiViewModelProvider('a1').notifier);
    // Let _loadTopics (async GET) resolve.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final topics = container.read(teachMochiViewModelProvider('a1')).topics;
    expect(topics, isNotEmpty);

    notifier.selectTopic(topics.first);
    notifier.updateExplanation('Plants make food from sunlight and water.');
    await notifier.submit();

    expect(sentBody, isNotNull);
    expect(sentBody!['topicSlug'], 'photosynthesis');
    expect(sentBody!.containsKey('durationSeconds'), isTrue,
        reason: 'submit must include durationSeconds');
    expect(sentBody!['durationSeconds'], isA<int>());
    expect(sentBody!['durationSeconds'] as int, greaterThanOrEqualTo(0));
  });
}
