import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/family/family_service.dart';
import 'package:pally/features/family/presentation/family_dashboard_screen.dart';

/// Dio adapter that immediately fails every request, so the unrelated
/// entitlement fetch the dashboard kicks off resolves instantly (to its
/// fail-open default) instead of hitting the network and stalling
/// pumpAndSettle.
class _OfflineAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString('{}', 400);
}

Dio _offlineDio() => Dio()..httpClientAdapter = _OfflineAdapter();

/// Fake service that returns whatever family payload the test supplies,
/// so we can prove the dashboard's strict require<int>() reads.
class _FakeFamilyService extends FamilyService {
  _FakeFamilyService(this._payload) : super(Dio());
  final Map<String, dynamic> _payload;

  @override
  Future<Map<String, dynamic>> family() async => _payload;
}

Widget _wrap(Map<String, dynamic> payload) => ProviderScope(
      overrides: [
        familyServiceProvider
            .overrideWithValue(_FakeFamilyService(payload)),
        dioProvider.overrideWithValue(_offlineDio()),
      ],
      child: const MaterialApp(home: FamilyDashboardScreen()),
    );

void main() {
  group('FamilyDashboardScreen strict parsing', () {
    testWidgets('renders child stats when all required fields present',
        (tester) async {
      await tester.pumpWidget(_wrap({
        'children': [
          {
            'childName': 'Ada',
            'level': 4,
            'streakDays': 7,
            'minutesThisWeek': 120,
            'modulesCompleted': 9,
          },
        ],
      }));
      await tester.pumpAndSettle();

      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('Lv.4 · 7 days · 120 min · 9 done'), findsOneWidget);
    });

    testWidgets(
        'surfaces an error (not silent zeros) when a required stat is missing',
        (tester) async {
      // Backend dropped minutesThisWeek + modulesCompleted — a broken
      // contract that previously rendered as a parent seeing "0 min · 0 done".
      await tester.pumpWidget(_wrap({
        'children': [
          {
            'childName': 'Ada',
            'level': 4,
            'streakDays': 7,
          },
        ],
      }));
      await tester.pumpAndSettle();

      // The dashboard must show an error card, NOT a tile full of zeros.
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.textContaining('0 min'), findsNothing);
    });

    testWidgets('shows empty state when there are no children at all',
        (tester) async {
      await tester.pumpWidget(_wrap({'children': const []}));
      await tester.pumpAndSettle();

      expect(find.text('No children linked yet'), findsOneWidget);
    });
  });
}
