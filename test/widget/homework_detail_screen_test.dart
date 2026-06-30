import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/homework/presentation/homework_detail_screen.dart';

class _MockDio extends Mock implements Dio {}

Response<dynamic> _resp(dynamic data) => Response<dynamic>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: '/homework/s1'),
    );

void main() {
  setUpAll(() => registerFallbackValue(RequestOptions(path: '/')));

  late _MockDio dio;
  setUp(() => dio = _MockDio());

  Widget harness() => ProviderScope(
        overrides: [dioProvider.overrideWithValue(dio)],
        child: const MaterialApp(
          home: HomeworkDetailScreen(avatarId: 'av-1', submissionId: 's1'),
        ),
      );

  Map<String, dynamic> detail({
    required String status,
    String? feedback,
    String? grade,
  }) =>
      {
        'id': 's1',
        'classId': 'cls-1',
        'title': 'Algebra WS3',
        'subject': 'Maths',
        'status': status,
        'files': [
          {'index': 0, 'name': 'work.jpg', 'contentType': 'image/jpeg', 'size': 1}
        ],
        'teacherFeedback': feedback,
        'teacherGrade': grade,
        'releasedAt': status == 'RELEASED' ? '2026-06-11T00:00:00Z' : null,
        'createdAt': '2026-06-10T00:00:00Z',
      };

  testWidgets('a released submission shows the teacher feedback and grade',
      (tester) async {
    when(() => dio.get<dynamic>(any())).thenAnswer((_) async => _resp(detail(
          status: 'RELEASED',
          feedback: 'Watch your units on Q3.',
          grade: 'A-',
        )));

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.text("Teacher's feedback"), findsOneWidget);
    expect(find.text('Watch your units on Q3.'), findsOneWidget);
    expect(find.text('A-'), findsOneWidget);
  });

  testWidgets('an in-review submission withholds feedback entirely',
      (tester) async {
    when(() => dio.get<dynamic>(any()))
        .thenAnswer((_) async => _resp(detail(status: 'IN_REVIEW')));

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.text('In review'), findsOneWidget);
    expect(find.text("Teacher's feedback"), findsNothing);
  });
}
