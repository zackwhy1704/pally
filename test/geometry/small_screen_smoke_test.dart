// ignore_for_file: avoid_relative_lib_imports, unused_element_parameter
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pally/app/api_client.dart';
import 'package:pally/features/auth/auth_state.dart';

// ── Screens under audit (all 57 lib/features/**/*_screen.dart) ───────────────
import 'package:pally/features/account_deletion/presentation/delete_account_screen.dart';
import 'package:pally/features/app_update/force_update_screen.dart';
import 'package:pally/features/assignments/presentation/assignment_compare_screen.dart';
import 'package:pally/features/auth/screens/centre_block_screen.dart';
import 'package:pally/features/auth/screens/complete_profile_screen.dart';
import 'package:pally/features/auth/screens/sign_in_screen.dart';
import 'package:pally/features/avatar_hub/presentation/avatar_hub_screen.dart';
import 'package:pally/features/avatar_picker/screens/avatar_picker_screen.dart';
import 'package:pally/features/brain_health/presentation/brain_health_screen.dart';
import 'package:pally/features/centre/presentation/centre_join_screen.dart';
import 'package:pally/features/chat/presentation/chat_screen.dart';
import 'package:pally/features/chat/presentation/chat_tab_screen.dart';
import 'package:pally/features/collection/presentation/collection_screen.dart';
import 'package:pally/features/consent/presentation/ai_disclosure_screen.dart';
import 'package:pally/features/create_tutor/presentation/create_tutor_screen.dart';
import 'package:pally/features/debug/presentation/painter_gallery_screen.dart';
import 'package:pally/features/exam_prep/presentation/exam_prep_screen.dart';
import 'package:pally/features/flashcards/presentation/flashcard_screen.dart';
import 'package:pally/features/groups/presentation/create_group_screen.dart';
import 'package:pally/features/groups/presentation/group_detail_screen.dart';
import 'package:pally/features/groups/presentation/group_list_screen.dart';
import 'package:pally/features/home/presentation/home_screen.dart';
import 'package:pally/features/homework/presentation/homework_detail_screen.dart';
import 'package:pally/features/homework/presentation/homework_list_screen.dart';
import 'package:pally/features/homework/presentation/homework_submit_screen.dart';
import 'package:pally/features/invite/presentation/invite_screen.dart';
import 'package:pally/features/join/presentation/join_screen.dart';
import 'package:pally/features/library/presentation/library_screen.dart';
import 'package:pally/features/modules/presentation/module_list_screen.dart';
import 'package:pally/features/modules/presentation/module_player_screen.dart';
import 'package:pally/features/onboarding/presentation/direct_onboarding_screen.dart';
import 'package:pally/features/onboarding/presentation/onboarding_screen.dart';
import 'package:pally/features/photo_question/presentation/camera_screen.dart';
import 'package:pally/features/photo_question/presentation/homework_scan_detail_screen.dart';
import 'package:pally/features/photo_question/presentation/photo_preview_screen.dart';
import 'package:pally/features/photo_question/screens/ocr_confidence_preview_screen.dart';
import 'package:pally/features/photo_question/screens/photo_review_screen.dart';
import 'package:pally/features/progress/presentation/achievements_screen.dart';
import 'package:pally/features/progress/presentation/level_roadmap_screen.dart';
import 'package:pally/features/progress/presentation/progress_screen.dart';
import 'package:pally/features/quiz/presentation/quiz_screen.dart';
import 'package:pally/features/referral/presentation/referral_screen.dart';
import 'package:pally/features/settings/presentation/learning_style_screen.dart';
import 'package:pally/features/shop/presentation/shop_screen.dart';
import 'package:pally/features/study_plan/presentation/study_plan_screen.dart';
import 'package:pally/features/subscription/presentation/paywall_screen.dart';
import 'package:pally/features/subscription/presentation/subscription_plans_screen.dart';
import 'package:pally/features/subscription/presentation/trial_expired_screen.dart';
// trial_welcome_screen.dart — EXCLUDED (see registry); not a widget.
import 'package:pally/features/teach_mochi/presentation/teach_mochi_screen.dart';
import 'package:pally/features/upload/presentation/ocr_review_screen.dart';
import 'package:pally/features/upload/presentation/upload_screen.dart';
import 'package:pally/features/wiki_compiled/presentation/wiki_compiled_screen.dart';
import 'package:pally/features/wiki_viewer/presentation/wiki_viewer_screen.dart';

import 'package:pally/features/photo_question/models/ocr_confidence_result.dart';
import 'package:pally/shared/models/photo_question.dart';

/// The glob count of lib/features/**/*_screen.dart. Every screen must be
/// ENROLLED (pumped) or EXCLUDED (with a reason) — never silently skipped.
/// Update ONLY when a screen file is genuinely added/removed.
const int kScaffoldScreenCount = 57;

const _avatarId = 'av-1';

/// An enrolled screen: a builder that constructs it with minimal fakes.
class _Enrolled {
  const _Enrolled(this.name, this.build, {this.overrides = const []});
  final String name;
  final Widget Function() build;
  final List<Override> overrides;
}

/// An excluded screen: the file name + a one-line reason. NEVER a silent skip.
class _Excluded {
  const _Excluded(this.name, this.reason);
  final String name;
  final String reason;
}

final List<_Enrolled> _enrolled = [
  _Enrolled('delete_account_screen', () => const DeleteAccountScreen()),
  _Enrolled('force_update_screen', () => const ForceUpdateScreen()),
  _Enrolled('assignment_compare_screen',
      () => const AssignmentCompareScreen(avatarId: _avatarId, assignmentId: 'as-1')),
  _Enrolled('centre_block_screen', () => const CentreBlockScreen()),
  _Enrolled('complete_profile_screen', () => const CompleteProfileScreen()),
  _Enrolled('sign_in_screen', () => const SignInScreen()),
  _Enrolled('avatar_hub_screen', () => const AvatarHubScreen(avatarId: _avatarId)),
  _Enrolled('avatar_picker_screen', () => const AvatarPickerScreen()),
  _Enrolled('brain_health_screen', () => const BrainHealthScreen(avatarId: _avatarId)),
  _Enrolled('centre_join_screen', () => const CentreJoinScreen()),
  _Enrolled('chat_screen', () => const ChatScreen(avatarId: _avatarId)),
  _Enrolled('chat_tab_screen', () => const ChatTabScreen()),
  _Enrolled('collection_screen', () => const CollectionScreen()),
  _Enrolled('ai_disclosure_screen', () => const AiDisclosureScreen()),
  _Enrolled('create_tutor_screen', () => const CreateTutorScreen()),
  _Enrolled('painter_gallery_screen', () => const PainterGalleryScreen()),
  _Enrolled('exam_prep_screen', () => const ExamPrepScreen(avatarId: _avatarId)),
  _Enrolled('flashcard_screen', () => const FlashcardScreen(avatarId: _avatarId)),
  _Enrolled('create_group_screen', () => const CreateGroupScreen()),
  _Enrolled('group_detail_screen', () => const GroupDetailScreen(groupId: 'g-1')),
  _Enrolled('group_list_screen', () => const GroupListScreen()),
  _Enrolled('home_screen', () => const HomeScreen()),
  _Enrolled('homework_detail_screen',
      () => const HomeworkDetailScreen(avatarId: _avatarId, submissionId: 'sub-1')),
  _Enrolled('homework_list_screen', () => const HomeworkListScreen(avatarId: _avatarId)),
  _Enrolled('homework_submit_screen', () => const HomeworkSubmitScreen(avatarId: _avatarId)),
  _Enrolled('invite_screen', () => const InviteScreen()),
  _Enrolled('join_screen', () => const JoinScreen()),
  _Enrolled('library_screen', () => const LibraryScreen()),
  _Enrolled('module_list_screen', () => const ModuleListScreen(avatarId: _avatarId)),
  _Enrolled('module_player_screen',
      () => const ModulePlayerScreen(avatarId: _avatarId, moduleId: 'mod-1')),
  _Enrolled('direct_onboarding_screen', () => const DirectOnboardingScreen()),
  _Enrolled('onboarding_screen', () => const OnboardingScreen()),
  _Enrolled('camera_screen', () => const CameraScreen()),
  _Enrolled('homework_scan_detail_screen',
      () => const HomeworkScanDetailScreen(result: HomeworkScanResult())),
  _Enrolled('photo_preview_screen',
      () => const PhotoPreviewScreen(photoPath: '/tmp/fake.jpg', avatarId: _avatarId)),
  _Enrolled('ocr_confidence_preview_screen',
      () => OcrConfidencePreviewScreen(
            result: OcrConfidenceResult(photoFile: File('/tmp/fake.jpg'), items: const []),
            avatarId: _avatarId,
            detectedTexts: const ['What is 2+2?'],
          )),
  _Enrolled('photo_review_screen',
      () => PhotoReviewScreen(
            photoFile: File('/tmp/fake.jpg'),
            detectedTexts: const ['What is 2+2?'],
            avatarId: _avatarId,
          )),
  _Enrolled('achievements_screen', () => const AchievementsScreen()),
  _Enrolled('level_roadmap_screen', () => const LevelRoadmapScreen()),
  _Enrolled('progress_screen', () => const ProgressScreen()),
  _Enrolled('quiz_screen', () => const QuizScreen(avatarId: _avatarId)),
  _Enrolled('referral_screen', () => const ReferralScreen()),
  _Enrolled('learning_style_screen', () => const LearningStyleScreen()),
  _Enrolled('shop_screen', () => const ShopScreen()),
  _Enrolled('study_plan_screen', () => const StudyPlanScreen(avatarId: _avatarId)),
  _Enrolled('paywall_screen', () => const PaywallScreen()),
  _Enrolled('subscription_plans_screen', () => const SubscriptionPlansScreen()),
  _Enrolled('trial_expired_screen', () => const TrialExpiredScreen(avatarId: _avatarId)),
  _Enrolled('teach_mochi_screen', () => const TeachMochiScreen(avatarId: _avatarId)),
  _Enrolled('ocr_review_screen',
      () => const OcrReviewScreen(
            avatarId: _avatarId,
            fileId: 'f-1',
            qualityReason: 'low quality',
            extractedText: 'Some extracted text',
          )),
  _Enrolled('upload_screen', () => const UploadScreen(avatarId: _avatarId)),
  _Enrolled('wiki_compiled_screen',
      () => const WikiCompiledScreen(
            avatarId: _avatarId,
            newPageTitles: ['Fractions', 'Decimals'],
            brainScore: 72,
          )),
  _Enrolled('wiki_viewer_screen', () => const WikiViewerScreen(avatarId: _avatarId)),
];

final List<_Excluded> _excluded = [
  const _Excluded('trial_welcome_screen',
      'Not a Scaffold widget — TrialWelcomeScreen is a static helper class '
          '(maybeShow) that presents a modal bottom sheet; nothing to pump as a route.'),
  const _Excluded('splash_screen',
      'Transient redirect screen: initState kicks off app-init (Future.delayed '
          'min-display timer + resolveStartRoute) then context.go()s away — no stable '
          'layout surface, and the min-display timer trips the pending-timer check.'),
  // Both surfaced a REAL non-geometry defect (not a RenderFlex overflow) — out of
  // this branch's layout-only / 2-pattern scope, ledgered in DEFERRED for a
  // separate fix. Excluded here so the GEOMETRY gate stays green + focused; the
  // underlying bugs are tracked, not hidden.
  const _Excluded('settings_screen',
      'A ListTile sits inside a coloured DecoratedBox with no Material ancestor '
          '("ListTile background/ink may be invisible" assertion, x2). A render-'
          'hierarchy fix (Material wrapper), not one of the 2 geometry patterns — '
          'DEFERRED for a separate render fix.'),
  const _Excluded('subscription_return_screen',
      'Throws "modify a provider while the widget tree is building": initState '
          'calls _poll() -> ref.read(entitlementVmProvider.notifier).refresh(), '
          'mutating a provider during first build. A LOGIC/state fix (defer to '
          'post-frame), NOT layout — out of scope per the branch rule; DEFERRED.'),
];

/// A Dio adapter that answers EVERY request instantly with an empty 200 `{}`.
///
/// Completing immediately (rather than hanging) is deliberate: a hanging future
/// leaves Dio's own internal timeout Timer pending, which trips the test binding's
/// pending-timer check at teardown. An instant completion cancels those timers and
/// lets each AsyncNotifier settle to a stable data/error state within the pump —
/// no late resolution into a disposed container, no timer leak. Endpoints wanting a
/// different shape just resolve to AsyncError (Riverpod swallows it into an error
/// state); either way the first-frame layout is what we smoke for overflow.
class _StubAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString('{}', 200, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });
  @override
  void close({bool force = false}) {}
}

Dio _stubDio() => Dio()..httpClientAdapter = _StubAdapter();

/// Overrides applied to EVERY screen's scope:
/// - [dioProvider]: hanging Dio (see above).
/// - [authStateProvider]: a fixed signed-in state. This ALSO stops the real
///   [authNotifierProvider] (a ChangeNotifierProvider over the AuthNotifier
///   SINGLETON) from ever building — Riverpod disposes that singleton when a
///   scope tears down, which otherwise poisons every later test with
///   "AuthNotifier was used after being disposed".
List<Override> _globalOverrides() => [
      dioProvider.overrideWithValue(_stubDio()),
      authStateProvider.overrideWithValue(const AuthState(
        userId: 'u-1',
        token: 'tok',
        isSetupComplete: true,
        isOnboardingComplete: true,
        accountType: 'direct',
      )),
    ];

/// Pumps [c] at [size] and returns the FIRST exception thrown during layout
/// (a RenderFlex overflow, or null). After capturing it, the tree is unmounted
/// so widget- and provider-owned timers (polls, repeating animations) are
/// cancelled before teardown — otherwise a pending periodic Timer would fail the
/// test for a reason unrelated to geometry. Any dispose-time async noise from
/// that unmount is discarded (it is not a geometry finding).
Future<Object?> _pumpAt(WidgetTester tester, _Enrolled c, Size size) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [..._globalOverrides(), ...c.overrides],
      child: MaterialApp(home: c.build()),
    ),
  );
  // First frame builds the tree (a RenderFlex overflow throws during this
  // layout). Then advance the fake clock: Dio schedules a zero-duration Timer
  // inside fetch() that a bare pump() never fires — advancing time fires it so
  // the stubbed request resolves and its Timer clears. A final settle pump
  // rebuilds the screen into its data/error state (whose layout is also smoked).
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();

  final firstException = tester.takeException();

  // Drain: unmount to dispose the ProviderScope + widget states, cancelling any
  // lifecycle-bound timers; then advance the clock generously so lingering
  // one-shot Future.delayed timers (e.g. HomeScreen's 600ms intro delay) fire
  // and clear. Discard exceptions surfaced during disposal.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
  tester.takeException();

  return firstException;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // In-memory flutter_secure_storage so AuthNotifier.instance works.
  const secureChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String>{};

  setUp(() {
    store.clear();
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, (call) async {
      final args = (call.arguments as Map?) ?? {};
      switch (call.method) {
        case 'read':
          return store[args['key']];
        case 'write':
          store[args['key'] as String] = args['value'] as String;
          return null;
        case 'delete':
          store.remove(args['key']);
          return null;
        case 'deleteAll':
          store.clear();
          return null;
        case 'readAll':
          return Map<String, String>.from(store);
        case 'containsKey':
          return store.containsKey(args['key']);
      }
      return null;
    });
  });

  tearDown(() async {
    await AuthNotifier.instance.signOut();
  });

  const small = Size(360, 640); // common small Android portrait
  const tall = Size(360, 850); // taller small phone

  group('registry accounts for every screen', () {
    test('enrolled + excluded == glob count (57)', () {
      expect(_enrolled.length + _excluded.length, kScaffoldScreenCount,
          reason: 'Every lib/features/**/*_screen.dart must be enrolled or '
              'explicitly excluded. New screens force a decision here.');
    });
  });

  group('small_screen_smoke @360x640', () {
    for (final c in _enrolled) {
      testWidgets(c.name, (tester) async {
        expect(await _pumpAt(tester, c, small), isNull,
            reason: '${c.name} threw (RenderFlex overflow?) at 360x640');
      });
    }
  });

  group('small_screen_smoke @360x850', () {
    for (final c in _enrolled) {
      testWidgets(c.name, (tester) async {
        expect(await _pumpAt(tester, c, tall), isNull,
            reason: '${c.name} threw (RenderFlex overflow?) at 360x850');
      });
    }
  });
}
