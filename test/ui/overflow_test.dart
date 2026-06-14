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
import 'package:pally/features/assignments/presentation/assignment_compare_screen.dart';
import 'package:pally/features/assignments/presentation/assignment_detail_view_model.dart';
import 'package:pally/features/groups/presentation/challenge_card.dart';
import 'package:pally/features/groups/presentation/challenge_view_model.dart';
import 'package:pally/core/ui/painters/class_uniform_mochi_painter.dart';
import 'package:pally/core/ui/mochi_avatar.dart';
import 'package:pally/shared/models/mochi_config.dart';
import 'package:pally/features/wiki_viewer/data/review_service.dart';
import 'package:pally/features/wiki_viewer/presentation/review_view_model.dart';
import 'package:pally/features/wiki_viewer/presentation/review_status_widgets.dart';
import 'package:pally/features/wiki_viewer/presentation/get_it_checked_sheet.dart';
import 'package:pally/features/family/family_status_provider.dart';
import 'package:pally/shared/models/wiki_page.dart';
import 'package:pally/shared/models/assignment_detail.dart';
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
        newSlugs: {'cells'},
        newTitles: {'Cells'},
        nodes: [
          TopicNode(
            slug: 'photosynthesis',
            title: 'Photosynthesis and the very long topic name',
            mastery: 0.8,
            attempts: 4,
            certainty: 'VERIFIED',
            certaintyScore: 0.9,
            quizUseCount: 6,
            hasConflict: true,
            conflictNote: 'You wrote leaves are blue, but earlier notes '
                'say green — which is right?',
          ),
          TopicNode(
            slug: 'cells',
            title: 'Cells',
            mastery: -1,
            attempts: 0,
            certainty: 'UNCERTAIN',
            certaintyScore: 0.2,
            quizUseCount: 0,
            prerequisiteSlugs: ['photosynthesis'],
          ),
        ],
      );
}

/// Released assignment with long answers + per-concept evaluation to stress
/// the compare cards.
class _StubAssignmentDetail extends AssignmentDetailViewModel {
  @override
  Future<AssignmentDetail> build(String avatarId, String assignmentId) async =>
      AssignmentDetail(
        id: 'as1',
        classId: 'c1',
        title: 'Photosynthesis and cellular respiration revision worksheet',
        type: 'PRE_CLASS',
        status: 'COMPLETED',
        dueDate: null,
        answersReleased: true,
        answersReleasedAt: null,
        moduleIds: const ['m1'],
        questions: const [
          AssignmentQuestion(
            index: 0,
            prompt:
                'Explain how plants convert sunlight into chemical energy and '
                'why this matters for the whole food chain.',
            studentAnswer:
                'Plants use sunlight, water and carbon dioxide to make glucose '
                'and oxygen inside the chloroplast during photosynthesis.',
            modelAnswer:
                'Photosynthesis converts light energy into chemical energy '
                'stored in glucose, releasing oxygen as a by-product.',
            concepts: [
              ConceptEval(
                concept: 'Reactants and products of photosynthesis',
                passed: true,
                feedback: 'Correctly identified water and carbon dioxide.',
              ),
              ConceptEval(
                concept: 'Role of chlorophyll in absorbing light',
                passed: false,
                feedback:
                    'Missed that chlorophyll is the pigment that absorbs the '
                    'light energy needed to start the reaction.',
              ),
            ],
          ),
        ],
      );
}

/// Pre-release assignment — no model answer, "not released" hint.
class _StubAssignmentDetailLocked extends AssignmentDetailViewModel {
  @override
  Future<AssignmentDetail> build(String avatarId, String assignmentId) async =>
      const AssignmentDetail(
        id: 'as2',
        classId: 'c1',
        title: 'Locked assignment',
        type: 'PRE_CLASS',
        status: 'SUBMITTED',
        dueDate: null,
        answersReleased: false,
        answersReleasedAt: null,
        moduleIds: ['m1'],
        questions: [
          AssignmentQuestion(
            index: 0,
            prompt: 'What is the powerhouse of the cell?',
            studentAnswer: 'The mitochondria.',
            modelAnswer: null,
            concepts: [],
          ),
        ],
      );
}

/// Revealed MCQ challenge with a distribution to stress the bars + long option
/// text. revealAt in the past so the countdown shows the revealed state.
class _StubChallengeRevealed extends ChallengeViewModel {
  @override
  Future<Challenge> build(String challengeId) async => Challenge(
        id: challengeId,
        classId: 'c1',
        question:
            'Which process releases the most usable energy for the cell over '
            'the long term and why does it depend on oxygen?',
        options: const [
          'Aerobic respiration in the mitochondria',
          'Anaerobic fermentation in the cytoplasm',
        ],
        revealAt: DateTime.now().subtract(const Duration(minutes: 5)),
        revealed: true,
        answered: true,
        answer: 'Aerobic respiration in the mitochondria',
        correct: 'Aerobic respiration in the mitochondria',
        distribution: const [
          ChallengeDistribution(
              answer: 'Aerobic respiration in the mitochondria', count: 18),
          ChallengeDistribution(
              answer: 'Anaerobic fermentation in the cytoplasm', count: 4),
        ],
        myAnswer: 'Anaerobic fermentation in the cytoplasm',
      );
}

/// Open MCQ challenge with a far-future reveal (OPEN state with options).
class _StubChallengeOpen extends ChallengeViewModel {
  @override
  Future<Challenge> build(String challengeId) async => Challenge(
        id: challengeId,
        classId: 'c1',
        question: 'What gas do plants take in during photosynthesis?',
        options: const ['Carbon dioxide', 'Oxygen', 'Nitrogen'],
        revealAt: DateTime.now().add(const Duration(hours: 2)),
        revealed: false,
        answered: false,
      );
}

/// Review VM stub — pending request so the sheet renders its full surface
/// (link-active row + revoke) under the overflow harness.
class _StubReviewVm extends ReviewViewModel {
  @override
  ReviewState build(String pageId) => ReviewState(
        isLoading: false,
        requests: [
          ReviewRequest(
            id: 'rr1',
            status: 'PENDING',
            reviewerName: 'Mum',
            expiresAt: DateTime.now().add(const Duration(days: 6)),
          ),
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
/// Extra provider overrides can be appended for screen-specific stubs.
Future<void> _pumpAt(
  WidgetTester tester,
  Widget child, {
  required Size size,
  required double scale,
  List<Override> extraOverrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [..._overrides(), ...extraOverrides],
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
    'MochiAvatar': () => const Center(
          child: MochiAvatar(
            config: MochiConfig(body: 4, accessory: 'crown', aura: 'sparkle'),
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

  // ── Assignment compare (P1) — released + locked ────────────────────────────
  group('AssignmentCompareScreen released', () {
    final overrides = [
      assignmentDetailViewModelProvider('a1', 'as1')
          .overrideWith(_StubAssignmentDetail.new),
    ];
    Widget build() =>
        const AssignmentCompareScreen(avatarId: 'a1', assignmentId: 'as1');

    testWidgets('no overflow @ 320x568 textScale 1.3', (tester) async {
      await _pumpAt(tester, build(),
          size: small, scale: 1.3, extraOverrides: overrides);
    });
    testWidgets('no overflow @ 360x690 textScale 1.3', (tester) async {
      await _pumpAt(tester, build(),
          size: medium, scale: 1.3, extraOverrides: overrides);
    });
  });

  group('AssignmentCompareScreen not released', () {
    final overrides = [
      assignmentDetailViewModelProvider('a1', 'as2')
          .overrideWith(_StubAssignmentDetailLocked.new),
    ];
    testWidgets('no overflow @ 320x568 textScale 1.3', (tester) async {
      await _pumpAt(
        tester,
        const AssignmentCompareScreen(avatarId: 'a1', assignmentId: 'as2'),
        size: small,
        scale: 1.3,
        extraOverrides: overrides,
      );
    });
  });

  // ── Challenge card (P3) — open + revealed ──────────────────────────────────
  group('ChallengeCard revealed', () {
    final overrides = [
      challengeViewModelProvider('ch1')
          .overrideWith(_StubChallengeRevealed.new),
    ];
    testWidgets('no overflow @ 320x568 textScale 1.3', (tester) async {
      await _pumpAt(
        tester,
        const SingleChildScrollView(child: ChallengeCard(challengeId: 'ch1')),
        size: small,
        scale: 1.3,
        extraOverrides: overrides,
      );
    });
    testWidgets('no overflow @ 360x690 textScale 1.3', (tester) async {
      await _pumpAt(
        tester,
        const SingleChildScrollView(child: ChallengeCard(challengeId: 'ch1')),
        size: medium,
        scale: 1.3,
        extraOverrides: overrides,
      );
    });
  });

  group('ChallengeCard open', () {
    final overrides = [
      challengeViewModelProvider('ch2').overrideWith(_StubChallengeOpen.new),
    ];
    testWidgets('no overflow @ 320x568 textScale 1.3', (tester) async {
      await _pumpAt(
        tester,
        const SingleChildScrollView(child: ChallengeCard(challengeId: 'ch2')),
        size: small,
        scale: 1.3,
        extraOverrides: overrides,
      );
    });
  });

  // ── Review surfaces (PART 1/2) — banners + chips + get-it-checked sheet ────
  WikiPage flaggedPage() => const WikiPage(
        id: 'wp1',
        avatarId: 'a1',
        title:
            'Photosynthesis and cellular respiration — the complete revision page',
        content: 'long content',
        reviewState: WikiReviewState.flagged,
        verifiedBy: 'Mrs Tan the science teacher',
        flagNote:
            'The equation for photosynthesis is missing the light energy '
            'arrow and the role of chlorophyll is not explained clearly enough.',
      );

  WikiPage lowConfidencePage() => const WikiPage(
        id: 'wp2',
        avatarId: 'a1',
        title: 'Fractions',
        content: 'c',
        reviewState: WikiReviewState.lowConfidence,
      );

  group('ReviewStateSurface flagged banner', () {
    testWidgets('no overflow @ 320x568 textScale 1.3', (tester) async {
      await _pumpAt(
        tester,
        SingleChildScrollView(
          child: ReviewStateSurface(
            page: flaggedPage(),
            onGetChecked: () {},
            onFixNotes: () {},
          ),
        ),
        size: small,
        scale: 1.3,
      );
    });
  });

  group('ReviewStateSurface low-confidence banner', () {
    testWidgets('no overflow @ 320x568 textScale 1.3', (tester) async {
      await _pumpAt(
        tester,
        SingleChildScrollView(
          child: ReviewStateSurface(
            page: lowConfidencePage(),
            onGetChecked: () {},
            onFixNotes: () {},
          ),
        ),
        size: small,
        scale: 1.3,
      );
    });
  });

  group('GetItCheckedSheet', () {
    final withParent = [
      reviewViewModelProvider('wp1').overrideWith(_StubReviewVm.new),
      familyStatusProvider.overrideWith((ref) async =>
          const FamilyStatus(accountType: AccountType.child, parentLinked: true)),
    ];
    final noParent = [
      reviewViewModelProvider('wp1').overrideWith(_StubReviewVm.new),
      familyStatusProvider.overrideWith((ref) async => FamilyStatus.empty),
    ];

    testWidgets('no overflow with parent linked @ 320x568 textScale 1.3',
        (tester) async {
      await _pumpAt(
        tester,
        GetItCheckedSheet(avatarId: 'a1', page: flaggedPage()),
        size: small,
        scale: 1.3,
        extraOverrides: withParent,
      );
      expect(find.text('Ask my parent'), findsOneWidget);
    });

    testWidgets('"Ask my parent" hidden when unlinked', (tester) async {
      await _pumpAt(
        tester,
        GetItCheckedSheet(avatarId: 'a1', page: flaggedPage()),
        size: medium,
        scale: 1.0,
        extraOverrides: noParent,
      );
      expect(find.text('Ask my parent'), findsNothing);
      expect(find.text('Share review link'), findsOneWidget);
    });
  });
}
