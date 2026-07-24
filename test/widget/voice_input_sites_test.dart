import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pally/app/api_client.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:pally/features/auth/screens/complete_profile_screen.dart';
import 'package:pally/features/chat/presentation/chat_screen.dart';
import 'package:pally/features/modules/presentation/widgets/test_body.dart';
import 'package:pally/features/modules/presentation/widgets/prove_body.dart';
import 'package:pally/features/upload/presentation/upload_screen.dart';
import 'package:pally/features/upload/presentation/upload_view_model.dart';
import 'package:pally/features/voice_input/data/voice_input_prefs.dart';

/// Cross-site check for the voice-input rollout: the mic must render on
/// EXACTLY the four named sites and nowhere else, and the single off-switch
/// (voiceInputEnabledProvider) must hide it on all four at once. This is the
/// "exactly these four and never the family it wasn't asked for" invariant —
/// the same class of bug this codebase keeps re-fixing one instance at a time
/// (see CLAUDE.md's centre-vs-personal / empty-state history).
const _voiceKey = ValueKey('voiceInputButton');

/// A Dio adapter that answers every request instantly with an empty 200 body
/// — mirrors test/geometry/small_screen_smoke_test.dart's `_StubAdapter` so
/// ChatScreen/UploadScreen/CompleteProfileScreen settle into a stable first
/// frame instead of hanging on a real network call.
class _StubAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<List<int>>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString('{}', 200, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });
  @override
  void close({bool force = false}) {}
}

List<Override> _authOverrides() => [
      dioProvider.overrideWithValue(Dio()..httpClientAdapter = _StubAdapter()),
      authStateProvider.overrideWithValue(const AuthState(
        userId: 'u-1',
        token: 'tok',
        isSetupComplete: true,
        isOnboardingComplete: true,
        accountType: 'direct',
      )),
    ];

/// Settles a real screen's first frame, then unmounts + advances the fake
/// clock so any lingering provider-owned Timer (e.g. ChatScreen's
/// weaknessFocusProvider Dio call) fires and clears before the test ends —
/// mirrors small_screen_smoke_test.dart's `_pumpAt` drain, otherwise
/// flutter_test's "Timer is still pending" invariant check fails the test for
/// a reason unrelated to the voice-input assertion being made.
Future<void> _settleAndDrain(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
}

Future<void> _drainAfterTest(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 2));
  tester.takeException();
}

void main() {
  const secureChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    SharedPreferences.setMockInitialValues({
      voiceInputExplainerShownPrefsKey: true,
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, (call) async {
      if (call.method == 'readAll') return <String, String>{};
      return null;
    });
  });

  tearDown(() async {
    await AuthNotifier.instance.signOut();
  });

  group('test_body.dart — SpotMistakeCard only', () {
    testWidgets('SpotMistakeCard (unrevealed) renders the mic', (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SpotMistakeCard(
              problem: '2 + 2 = ?',
              wrongSolution: '2 + 2 = 5',
              errorDescription: 'wrong',
              correctSolution: '4',
              isRevealed: false,
              diagnosis: '',
              selfCheck: null,
              onReveal: (_) {},
              onSelfCheck: (_) {},
            ),
          ),
        ),
      ));
      expect(find.byKey(_voiceKey), findsOneWidget);
    });

    testWidgets(
        'ChallengeCard and HotTakeCard — NOT in the four sites — have no mic',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Column(children: [
              ChallengeCard(
                question: 'Explain it',
                explanation: 'model answer',
                isRevealed: false,
                answer: '',
                onSubmit: (_) {},
              ),
              HotTakeCard(
                statement: 'Plants eat soil',
                verdict: null,
                verdictPending: false,
                isRevealed: false,
                answer: null,
                onAnswer: (_) {},
              ),
            ]),
          ),
        ),
      ));
      expect(find.byKey(_voiceKey), findsNothing);
    });
  });

  group('prove_body.dart — ProveQuestion', () {
    testWidgets('renders the mic and keeps a dictated answer synced + editable',
        (tester) async {
      String? synced;
      final controller = TextEditingController();
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ProveQuestion(
              questionNumber: 1,
              question: 'Why is the sky blue?',
              answer: '',
              onChanged: (v) => synced = v,
            ),
          ),
        ),
      ));
      expect(find.byKey(_voiceKey), findsOneWidget);

      // The field is independent of `controller` above (ProveQuestion owns
      // its own), but typing directly proves onChanged still reaches the
      // parent through the normal TextField path, unaffected by the mic.
      await tester.enterText(find.byType(TextField), 'typed answer');
      await tester.pump();
      expect(synced, 'typed answer');
      controller.dispose();
    });
  });

  group('upload_screen.dart — Type tab notes field only', () {
    testWidgets(
        'Type tab notes field has the mic; the topic-tag field does not',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          ..._authOverrides(),
          uploadViewModelProvider('test-avatar').overrideWith(() => _IdleUploadVM()),
        ],
        child: const MaterialApp(home: UploadScreen(avatarId: 'test-avatar')),
      ));
      await _settleAndDrain(tester);

      // Type tab (default) — the notes field's mic.
      expect(find.byKey(_voiceKey), findsOneWidget);

      // Switch to the Photo tab, which renders _ContextTagBar's topic-tag
      // TextField — explicitly excluded by the task ("DO NOT add voice to
      // topic tags"). It must never grow a mic.
      await tester.tap(find.text('Photo'));
      await tester.pumpAndSettle();
      expect(find.text('Topic (e.g. Algebra)'), findsOneWidget);
      expect(find.byKey(_voiceKey), findsNothing);

      await _drainAfterTest(tester);
    });
  });

  group('chat_screen.dart — _InputBar', () {
    testWidgets('renders the mic as a sibling of the camera button',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: _authOverrides(),
        child: const MaterialApp(home: ChatScreen(avatarId: 'test-avatar')),
      ));
      await _settleAndDrain(tester);

      expect(find.byKey(_voiceKey), findsOneWidget);

      await _drainAfterTest(tester);
    });
  });

  group('excluded surface — auth/profile fields never get a mic', () {
    testWidgets('CompleteProfileScreen has no mic anywhere', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: _authOverrides(),
        child: const MaterialApp(home: CompleteProfileScreen()),
      ));
      await _settleAndDrain(tester);

      expect(find.byKey(_voiceKey), findsNothing);

      await _drainAfterTest(tester);
    });
  });

  group('off-switch reaches every one of the four real sites', () {
    // Each site gets its own testWidgets (a fresh ProviderContainer) rather
    // than reusing one tester across multiple pumpWidget calls with a
    // DIFFERENT override count each time — Riverpod's ProviderScope forbids
    // changing the number of overrides on an existing container/element.
    testWidgets('SpotMistakeCard respects voiceInputEnabled=false',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [voiceInputEnabledProvider.overrideWith((ref) => false)],
        child: MaterialApp(
          home: Scaffold(
            body: SpotMistakeCard(
              problem: 'p',
              wrongSolution: 'w',
              errorDescription: 'e',
              correctSolution: 'c',
              isRevealed: false,
              diagnosis: '',
              selfCheck: null,
              onReveal: (_) {},
              onSelfCheck: (_) {},
            ),
          ),
        ),
      ));
      expect(find.byKey(_voiceKey), findsNothing);
    });

    testWidgets('ProveQuestion respects voiceInputEnabled=false',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [voiceInputEnabledProvider.overrideWith((ref) => false)],
        child: MaterialApp(
          home: Scaffold(
            body: ProveQuestion(
                questionNumber: 1, question: 'q', answer: '', onChanged: (_) {}),
          ),
        ),
      ));
      expect(find.byKey(_voiceKey), findsNothing);
    });

    testWidgets('UploadScreen respects voiceInputEnabled=false',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          voiceInputEnabledProvider.overrideWith((ref) => false),
          ..._authOverrides(),
          uploadViewModelProvider('test-avatar').overrideWith(() => _IdleUploadVM()),
        ],
        child: const MaterialApp(home: UploadScreen(avatarId: 'test-avatar')),
      ));
      await _settleAndDrain(tester);
      expect(find.byKey(_voiceKey), findsNothing);
      await _drainAfterTest(tester);
    });

    testWidgets('ChatScreen respects voiceInputEnabled=false', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          voiceInputEnabledProvider.overrideWith((ref) => false),
          ..._authOverrides(),
        ],
        child: const MaterialApp(home: ChatScreen(avatarId: 'test-avatar')),
      ));
      await _settleAndDrain(tester);
      expect(find.byKey(_voiceKey), findsNothing);
      await _drainAfterTest(tester);
    });
  });
}

/// A settled, no-op UploadViewModel so the Type tab renders without hitting
/// the real network path — copies the pattern in upload_screen_tabs_test.dart.
class _IdleUploadVM extends UploadViewModel {
  @override
  UploadState build(String avatarId) => const UploadState();
}
