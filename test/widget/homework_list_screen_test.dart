import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/homework/presentation/homework_list_screen.dart';

class _MockDio extends Mock implements Dio {}

Response<dynamic> _resp(dynamic data, String path) => Response<dynamic>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );

void main() {
  setUpAll(() => registerFallbackValue(RequestOptions(path: '/')));

  late _MockDio dio;

  setUp(() => dio = _MockDio());

  Widget harness() => ProviderScope(
        overrides: [dioProvider.overrideWithValue(dio)],
        child: const MaterialApp(
          home: HomeworkListScreen(avatarId: 'av-1'),
        ),
      );

  Map<String, dynamic> submission({
    required String id,
    required String title,
    required String status,
  }) =>
      {
        'id': id,
        'classId': 'cls-1',
        'title': title,
        'subject': 'Maths',
        'status': status,
        'files': [
          {'index': 0, 'name': 'work.jpg', 'contentType': 'image/jpeg', 'size': 1}
        ],
        'teacherFeedback': status == 'RELEASED' ? 'Nice work' : null,
        'teacherGrade': status == 'RELEASED' ? 'A' : null,
        'releasedAt': null,
        'createdAt': '2026-06-10T00:00:00Z',
      };

  testWidgets('empty list shows the friendly no-homework state', (tester) async {
    when(() => dio.get<dynamic>(any()))
        .thenAnswer((_) async => _resp(const [], '/homework'));

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.text('No homework yet'), findsOneWidget);
    expect(find.text('Submit homework'), findsOneWidget); // the FAB
  });

  testWidgets('each status renders its own badge', (tester) async {
    when(() => dio.get<dynamic>(any())).thenAnswer((_) async => _resp([
          submission(id: 's1', title: 'Algebra', status: 'IN_REVIEW'),
          submission(id: 's2', title: 'Geometry', status: 'RETURNED'),
          submission(id: 's3', title: 'Fractions', status: 'RELEASED'),
        ], '/homework'));

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.text('Algebra'), findsOneWidget);
    expect(find.text('In review'), findsOneWidget);
    expect(find.text('Please redo'), findsOneWidget);
    expect(find.text('Feedback ready'), findsOneWidget);
  });
}
