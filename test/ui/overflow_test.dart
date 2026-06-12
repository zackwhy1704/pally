import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pally/app/api_client.dart';
import 'package:pally/features/brain_map/presentation/brain_map_screen.dart';
import 'package:pally/features/brain_map/presentation/brain_map_view_model.dart';
import 'package:pally/features/consent/data/consent_service.dart';
import 'package:pally/features/consent/presentation/ai_disclosure_screen.dart';
import 'package:pally/features/progress/presentation/daily_goal_provider.dart';
import 'package:pally/features/progress/presentation/daily_goal_ring.dart';
import 'package:pally/features/progress/presentation/streak_card.dart';
import 'package:pally/features/progress/presentation/streak_status_provider.dart';
import 'package:pally/features/shop/presentation/powerup_view_model.dart';
import 'package:pally/features/shop/presentation/shop_screen.dart';
import 'package:pally/features/shop/presentation/shop_view_model.dart';
import 'package:pally/features/shop/providers/mystery_box_odds_provider.dart';
import 'package:pally/features/shop/providers/unlocked_characters_provider.dart';
import 'package:pally/features/subscription/presentation/trial_welcome_screen.dart';
import 'package:pally/core/ui/painters/class_uniform_mochi_painter.dart';
import 'package:pally/shared/models/avatar.dart';
import 'package:pally/shared/models/daily_goal.dart';
import 'package:pally/shared/models/mochi_character.dart';
import 'package:pally/shared/models/streak_status.dart';

// ── Stub notifiers — return fixed data synchronously, never the network ──────

class _StubStreak extends StreakStatusVm {
  @override
  Future<StreakStatus> build() async => const StreakStatus(
        streakDays: 12,
        longestStreak: 30,
        freezes: 2,
        last7: [true, false, true, true, true, false, true],
        nextMilestone: 14,
        daysToMilestone: 2,
        milestonesReached: [3, 7],
      );
}

class _StubGoal extends DailyGoalVm {
  @override
  Future<DailyGoal> build() async => const DailyGoal(
        goalType: 'MINUTES',
        goalTarget: 20,
        goalProgress: 12,
        met: false,
      );
}

class _StubShopVm extends ShopViewModel {
  @override
  ShopState build() => const ShopState(stars: 1200, collectionCount: 3);
}

class _StubPowerupVm extends PowerupViewModel {
  @override
  PowerupState build() => const PowerupState(
        counts: {'HINT_TOKEN': 1},
        catalog: {
          'HINT_TOKEN': PowerupCatalogEntry(cost: 50, label: 'Hint Token'),
        },
      );
}

class _StubOdds extends MysteryBoxOddsNotifier {
  @override
  Future<List<MysteryBoxOdds>> build() async => const [
        MysteryBoxOdds(
            character: 'PENCIL', name: 'Pencil', rarity: 'COMMON', percent: 50),
        MysteryBoxOdds(
            character: 'GOLDSTAR',
            name: 'Gold Star',
            rarity: 'SECRET',
            percent: 50),
      ];
}

class _StubUnlocked extends UnlockedCharactersNotifier {
  @override
  Future<Set<MochiCharacter>> build() async =>
      {MochiCharacter.mochi, MochiCharacter.pencil};
}

class _StubBrainMap extends BrainMapViewModel {
  @override
  Future<BrainMapState> build(String avatarId) async => const BrainMapState(
        isLoading: false,
        subject: 'Science',
        nodes: [
          TopicNode(
              slug: 'photosynthesis',
              title: 'Photosynthesis and the very long topic name',
              mastery: 0.8,
              attempts: 4),
          TopicNode(slug: 'cells', title: 'Cells', mastery: -1, attempts: 0),
        ],
      );
}

class _FakeConsentService extends ConsentService {
  _FakeConsentService() : super(Dio());
  @override
  Future<void> grantAiConsent() async {}
}

/// A Dio that fails fast for any sub-provider not explicitly stubbed,
/// so providers fall through to their offline/fallback branches instead
/// of hanging on a real socket.
Dio _stubDio() {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:1'));
  dio.httpClientAdapter = _ThrowingAdapter();
  return dio;
}

class _ThrowingAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    throw DioException(requestOptions: options);
  }
}

List<Override> _overrides() => [
      dioProvider.overrideWithValue(_stubDio()),
      streakStatusVmProvider.overrideWith(_StubStreak.new),
      dailyGoalVmProvider.overrideWith(_StubGoal.new),
      shopViewModelProvider.overrideWith(_StubShopVm.new),
      powerupViewModelProvider.overrideWith(_StubPowerupVm.new),
      mysteryBoxOddsNotifierProvider.overrideWith(_StubOdds.new),
      unlockedCharactersProvider.overrideWith(_StubUnlocked.new),
      consentServiceProvider.overrideWithValue(_FakeConsentService()),
      brainMapViewModelProvider('a1').overrideWith(_StubBrainMap.new),
    ];

/// Pumps [child] at [size] with [scale] text scaling and asserts the build
/// produced no layout exception (overflow throws in the test harness).
Future<void> _pumpAt(
  WidgetTester tester,
  Widget child, {
  required Size size,
  required double scale,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides(),
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(scale),
          ),
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(tester.takeException(), isNull);
}

void main() {
  // The two device profiles every risky widget must survive.
  const small = Size(320, 568); // smallest supported phone
  const medium = Size(360, 690); // common Android baseline

  /// Each entry is a label + a builder for the widget under test.
  final cases = <String, Widget Function()>{
    'StreakCard': () => const StreakCard(),
    'DailyGoalRing': () => const DailyGoalRing(),
    'ShopScreen': () => const ShopScreen(),
    'AiDisclosureScreen': () => const AiDisclosureScreen(),
    'BrainMapScreen': () => const BrainMapScreen(avatarId: 'a1'),
    'ClassUniformAvatar': () => const Center(
          child: ClassUniformAvatar(
            appearance: ClassAppearance(
              bandColorHex: '#7042ED',
              subjectGlyph: 'math',
              initials: 'P5',
            ),
            size: 120,
          ),
        ),
  };

  for (final entry in cases.entries) {
    group(entry.key, () {
      testWidgets('no overflow @ 320x568 textScale 1.3', (tester) async {
        await _pumpAt(tester, entry.value(), size: small, scale: 1.3);
      });
      testWidgets('no overflow @ 360x690 textScale 1.0', (tester) async {
        await _pumpAt(tester, entry.value(), size: medium, scale: 1.0);
      });
      testWidgets('no overflow @ 360x690 textScale 1.3', (tester) async {
        await _pumpAt(tester, entry.value(), size: medium, scale: 1.3);
      });
    });
  }

  // ── Streak detail sheet — private; trigger it via a tap on the card ────────
  group('_StreakDetailSheet', () {
    testWidgets('opens without overflow @ 320x568 textScale 1.3',
        (tester) async {
      tester.view.physicalSize = small;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: small,
                textScaler: TextScaler.linear(1.3),
              ),
              child: const Scaffold(body: StreakCard()),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Tapping the card opens the streak ladder sheet.
      await tester.tap(find.byType(StreakCard));
      await tester.pumpAndSettle();
      expect(find.text('Streak ladder'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Trial welcome sheet — private; opened through its public entry point ───
  group('_TrialWelcomeSheet', () {
    testWidgets('opens without overflow @ 320x568 textScale 1.3',
        (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      tester.view.physicalSize = small;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late BuildContext ctx;
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: small,
                textScaler: TextScaler.linear(1.3),
              ),
              child: Scaffold(
                body: Builder(builder: (c) {
                  ctx = c;
                  return const SizedBox.shrink();
                }),
              ),
            ),
          ),
        ),
      );

      // maybeShow reads the "seen" flag (mocked empty above), then shows the
      // real _TrialWelcomeSheet through showModalBottomSheet. The returned
      // Future only completes when the sheet is dismissed, so we deliberately
      // do NOT await it — we just pump until the sheet is laid out.
      unawaited(TrialWelcomeScreen.maybeShow(ctx));
      // Pump the async prefs read + the sheet's open animation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('Premium is on us'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
