# Deferred items — pally (client) ledger

> The tracked home for consciously-deferred CLIENT gaps: things we chose not to do
> yet, each with a reason and **what closes it**. (Backend deferrals live in
> `pally-backend/DEFERRED.md`.) When you defer something, add it here — don't leave
> it "low priority" with no owner.

---

## PostHog identify()/event() PII fix — no automated regression test for the two identify() sites

**What shipped 2026-08-12:** `sign_in_screen.dart` and `direct_onboarding_view_model.dart`'s
`identify()` calls no longer send `email`/`display_name` to PostHog (opaque `userId` only); a full
app-wide sweep of every `analyticsProvider` call site found one more hit,
`upload_view_model.dart`'s `uploadNote` event sending the raw `file_name` (a child can name a photo
after themselves or their school) — fixed to send `file_type` (extension) instead.

**Deliberately not covered by an automated test:** `quickOnboard()` (the call site for the
onboarding `identify()`) constructs its own `Dio` instance inline with no DI seam — a documented,
deliberate architectural choice (the user isn't authenticated yet, so it can't reuse the app's
normal authenticated Dio provider), not a shortcut. No existing test harness drives that network
path; building one is real new test infrastructure, out of scope for a resubmission-blocking
privacy fix. `sign_in_screen.dart`'s `identify()` call has the same gap for the same reason
(post-auth Dio flow, no existing widget-test harness that exercises it end-to-end).
**Closes it:** when `quickOnboard()`/sign-in get a real Dio-injection seam for OTHER reasons (there
is no standalone reason to build one just for this), add a widget test overriding
`analyticsProvider` with a capturing fake and asserting `identify()` is called with no PII props,
for both call sites. Until then, the guard against regression is that the fix is a one-line
`identify(userId)` — reintroducing PII means someone has to deliberately add a `props:` argument
back, not something that happens by default.

## iOS OCR implementation — CLOSED 2026-08-12 (root cause was a simulator-only arch gap, not a real block)

**Found 2026-08-12** while investigating whether a release build's `Podfile.lock` diff dropped a
plugin. `ios/Podfile` (added in `ed9a5b7`, 2026-06-19) had always deliberately stripped
`google_mlkit_*` from the iOS plugin list — no CocoaPods entry, no SPM entry, and it patched
`GeneratedPluginRegistrant.m` to remove the registration call too. The comment at the time claimed
this was safe because "iOS uses Apple Vision Framework for text recognition (see
`Runner/VisionTextRecognitionChannel.swift`)" — **that file never existed in this repo's history**
(`git log --all --full-history -- '**/VisionTextRecognitionChannel.swift'` returns nothing), and
`ios/Runner/` contains exactly one Swift file (`AppDelegate.swift`), with no `MethodChannel`
registered for `google_mlkit_text_recognizer` (the channel name the Dart plugin actually calls)
anywhere in the iOS project.

**Effect (now historical):** `TextRecognitionService.recognize()` was silently broken on iOS since
`ed9a5b7` — every call threw (no native handler registered). Never visible as a crash because
`photo_preview_view_model.dart`'s `_runDetection` catches ALL exceptions and replaces them with
`"Couldn't read text from this photo. Try a clearer shot."` — a plausible-sounding, completely
misleading message that blamed photo quality for what was actually a missing native implementation.

**Root cause, and the actual fix:** the stripping logic's own comment named the real reason —
"their iOS pods have no arm64-simulator slice and break the build on Apple Silicon + Xcode 26" —
but the fix applied was to remove the plugin from iOS ENTIRELY rather than exclude the one
architecture that was actually the problem. `EXCLUDED_ARCHS[sdk=iphonesimulator*]` already existed
in `ios/Podfile`'s `post_install` (excluding `armv7`); adding `arm64` to that same setting is the
standard, well-documented ML Kit/Firebase-family workaround (many Google-distributed XCFrameworks
ship without an arm64 SIMULATOR slice, only a device one) and needed zero Swift code.

**Verified, not assumed:** removed the whole stripping block (the `.flutter-plugins-dependencies`
filter + the `GeneratedPluginRegistrant.m` patch), added `arm64` to the simulator exclusion, ran
`flutter clean && flutter pub get && pod install` (confirmed `google_mlkit_commons` and
`google_mlkit_text_recognition` + their 15 transitive MLKit/Google pods installed — "7 dependencies
from the Podfile and 20 total pods installed"), then `flutter build ipa --release`. The RELEASE/
DEVICE build succeeded cleanly — `Runner.xcarchive` (317.2MB) and a signed IPA (75.2MB) both built.
The build log's arm64-simulator warning is real but scoped exactly to simulators, as expected; it
did not block the device archive or the IPA export. The camera-button `Platform.isIOS` gate added
earlier the same day was removed again — `dart analyze` (0 new issues), `flutter test` (1100
passed), and a second `flutter build ipa --release` after removing the gate both green, IPA
unchanged at 75.2MB (the gate only affected UI reachability, not what's linked into the binary).

**Size cost:** IPA grew from 58,909,250 → 75,230,395 bytes (+16.3MB / +27.7%) — MLKit's on-device
text-recognition model is not small. Worth knowing if app-size becomes a concern later, not a
blocker now.

**Remaining, genuinely deferred:** none for this specific bug — the feature works on both platforms
again. If a future Xcode/Google-SDK update ever reintroduces the arm64-simulator gap for a NEW pod
in this family, the fix is the same one-line `EXCLUDED_ARCHS` addition, not another full strip.

## CI: `Analyze` failure silently skips `Test` — pipeline gives no real signal — CLOSED (`6eee558`, #22, merged to main)

**Found:** verifying CI for `feat/eula-terms-acceptance` (`f94a8c5`, merged `1d89029`). The
`frontend-ci` GitHub Actions workflow runs `Analyze` (`dart analyze`) then `Test` (`flutter test`)
as sequential job steps with the implicit `if: success()` gate — when `Analyze` fails, `Test` shows
as `skipped`, not run. `Analyze` currently fails on **298 pre-existing info-level lint issues**
(not from this or any specific PR — confirmed identical failure on baseline `main` @ `fe40378` and
every commit back through at least `1d83cff`, 2026-07-30). Locally, `dart analyze lib/` only scans
`lib/` (216 issues, zero fatal); CI's `Analyze` step evidently scans the whole tree including
`test/`, and `dart analyze`'s default exit code is 1 on ANY issue regardless of severity — so a
single `info` hit anywhere fails the step and, as a side effect, skips real test execution for
every PR going forward. `f94a8c5`'s only actual test evidence is a local `flutter test` run (1100
passed); CI itself never ran `flutter test` for that SHA. Same story confirmed for the EULA branch
before it. **This is worse than the lint noise itself** — a pipeline that silently disables its own
test step gives a false sense of "CI passed" (it shows `failure`, so nobody's actually being
fooled today, but the next person auto-merging on a *fixed* Analyze step would be trusting a Test
result CI hasn't actually produced since at least 2026-07-30).

**Closes it:** either (a) make `Analyze` non-fatal on `info`-level issues (`dart analyze --fatal-
infos=false` or scope it to `lib/` like the local mandatory workflow does), or (b) decouple the
`Test` step so it runs regardless of `Analyze`'s outcome (`if: always()` or a separate job). Fixing
the 298 lint issues themselves is not urgent (they're `info`, mostly `prefer_const_constructors`/
`prefer_single_quotes`); making sure `Test` actually runs on every PR is.

---

## zh audit round 5, Phase A — "你的 Mochi" ARB value-level leak (CLOSED, 2026-07-31)

**Corrected the prompt's suggested fix before applying it:** the prompt assumed
`homeSectionYourMochis` should gain a `{mascot}` placeholder like every other mascot-referencing key.
Traced the EN source (`app_en.arb:864-867`) and found this key is a bare getter with NO placeholder
mechanism at all, carrying an explicit `@homeSectionYourMochis` description: `"Keep 'Mochis'"` — a
DELIBERATE translator instruction, not an oversight. The actual bug was simpler: the zh VALUE typed
the literal English word "Mochi" instead of the established no-placeholder convention used elsewhere
in this same file for bare mascot mentions (hardcoding "小伴" directly, matching the shop cosmetic
names and the backend's `AchievementCatalog`/`LevelRewards` zh fields from an earlier round). Fixed by
changing the VALUE only: `"你的 Mochi"` → `"你的小伴"` — no new placeholder, no new mechanism.

**Full sweep, not stop-at-one:** grepped every `app_zh.arb` value (case-sensitive, excluding `@`-metadata
lines) for the literal substring "Mochi" — `homeSectionYourMochis` was the ONLY hit. Cross-checked with a
second, case-insensitive pass excluding `{mascot}`-containing lines to rule out a differently-cased leak
elsewhere. Nothing else surfaced.

**New permanent guard:** `test/guard/no_raw_mascot_word_in_zh_arb_test.dart` — asserts no `app_zh.arb`
value contains the raw untranslated word "Mochi". This is a distinct failure mode from "missing key"
(the existing coverage guard's axis): a key can be PRESENT, translated, and still leak the English brand
word at the value level. Confirmed RED before the fix (caught exactly the one leak), GREEN after.

Gates: analyze 0/0, full suite green (1 known pre-existing unrelated golden-test failure, see round 4
Phase B note below), APK builds.

## zh audit round 5, Phase B — forgot-password dialog: crash + missing validation (CLOSED, 2026-07-31)

**Two real bugs, unrelated to i18n, in `sign_in_screen.dart`'s `_showForgotPasswordDialog`.**

**Bug 1 — no email format validation.** Was `if (email.isEmpty) return;` only. Fixed by wrapping the
field in a `Form`/`TextFormField` with a `validator`, matching the ACTUAL pattern already used by
`complete_profile_screen.dart` and `direct_onboarding_screen.dart` — block-on-tap with an inline error,
**not** a disabled-button pattern. The prompt's premise that "the two existing signup screens gate their
own submit buttons" was checked against source and found wrong: both call `_formKey.currentState
?.validate()` and return early on failure; neither disables its button. Mirrored what's actually there.
The regex was already duplicated in both of those files — extracted to
`lib/core/validation/email_validator.dart` (`emailFormatRegex` + `isValidEmailFormat`) and pointed all
three call sites at the one copy instead of adding a fourth.

**Bug 2 — the crash (prioritized, since it fired on every normal send, not as a rare flake).** Root cause
was TWO compounding issues, not the one originally hypothesized:
1. The button handler's `finally { if (ctx.mounted) setDialogState(...) }` ran even when the SAME method
   had just called `Navigator.of(ctx).pop()` (success and `AuthException` paths both pop before reaching
   that finally) — `ctx.mounted` can still read true for one or more frames during the dialog's
   deactivation window, so the guard didn't prevent the race. Fixed with a local `popped` flag set
   immediately before each `pop()` call, gating the finally on `!popped && ctx.mounted`.
2. **Found empirically, not in the original hypothesis:** the OUTER `finally { emailCtrl.dispose(); }`
   disposes the dialog's `TextEditingController` as soon as `showDialog()`'s future resolves — which can
   be BEFORE the dialog's element tree (and any in-flight `TextField` frame callback, e.g. caret-visibility
   scheduling) has actually finished tearing down. A throwaway diagnostic test proved this reproduces on
   the ORIGINAL, unfixed code (same "_dependents.isEmpty" / disposed-controller cascade), and re-running
   the real test file after applying ONLY the `popped`-flag fix showed the identical cascade still firing
   — proof the flag alone doesn't close the bug. Fixed by deferring disposal one frame:
   `WidgetsBinding.instance.addPostFrameCallback((_) => emailCtrl.dispose());`.

**Sibling audit (clean result, not skipped):** grepped the whole app for the same
`StatefulBuilder` + `Navigator.pop` + a `finally` touching `setDialogState`/`setState` shape. Only one
other `StatefulBuilder`-based dialog exists in the app; the other 3 candidates found via a broader
"pop+finally+setState" grep all guard on their SCREEN's own persistent `State.mounted` (deterministic),
not an ephemeral dialog `BuildContext.mounted` (can read true mid-deactivation) — confirmed safe, not
the same shape.

**Tests (fail-without-fix, not just green-suite):** `test/widget/sign_in_forgot_password_dialog_test.dart`
drives the full success and `AuthException` paths through a stubbed `AuthService` (added a minimal
`@visibleForTesting debugOverrideHttpClient` seam to the service — a hard singleton with a hardcoded prod
baseUrl and no other DI seam — so the test never risks a real network call). Confirmed failing before the
fix (identical crash cascade reproduced against the truly-original code via a throwaway diagnostic,
deleted once it had served its purpose), green after.

Gates: analyze 0/0, full suite green (1 known pre-existing unrelated golden-test failure — see below),
APK builds.

**Pre-existing, unrelated failure noted, not chased:** `test/golden/answer_card_golden_test.dart`
("AnswerCard golden collapsed state") fails on a clean `HEAD` with NONE of this round's changes applied
(verified by stashing all round-5 changes and re-running the golden test in isolation — it fails
identically). This is the same pre-existing golden-image flake already documented in the round 4 Phase B
entry above ("1 known pre-existing unrelated failure") — environment/rendering-sensitive, not caused by
or related to this round's work.

## zh audit round 4, Phase B — locale-switch provider invalidation (CLOSED, 2026-07-31)

**Verified before fixing:** confirmed no `ref.invalidate` call anywhere near `setLanguage()` —
`achievementsProvider`/`levelRoadmapProvider`/`progressViewModelProvider` only get invalidated on
pull-to-refresh, retry-after-error, or an XP-earning action. A real device walk found several
"still English" reports (achievements, level-rewards, progress) that turned out to be THIS bug, not
missing translations — the server was already correctly resolving zh (independently proven live via
`curl` in the prior round), but any screen visited once before a language switch keeps its
`AutoDispose` provider's cached response until one of those unrelated triggers fires.

**Enumerated properly, not guessed:** grepped every `dio.get`/`dio.post` call in `lib/features/progress/`
and cross-checked against every backend endpoint this thread's rounds made `preferred_locale`-aware.
Confirmed exactly 3 providers are affected — `coverage_provider.dart` (mastery counts + subject codes
resolved client-side via `localizedSubject()`, not server text), `daily_goal_provider.dart`, and
`streak_status_provider.dart`/`study_plan_view_model.dart` (numeric/content_language-scoped, untouched by
this round's `preferred_locale` work) are NOT in scope.

**Fixed:** `LocaleController._patchLocale` invalidates the 3 providers AFTER the PATCH succeeds — not
before, and not unconditionally. Sequencing matters: invalidating BEFORE the PATCH lands would race the
re-fetch against the server not yet knowing the new `preferred_locale`, returning the OLD language
again. A FAILED PATCH does not invalidate either — no worse than today, and avoids an invalidate that
would just re-fetch the same stale-language content the server still believes is correct.

**Tests (the fail-without-fix case, proven, not asserted):** a fake adapter tracks the server's OWN
current `preferredLocale` (updated only when the locale PATCH lands — NOT a naive "first call vs the
rest" counter, which would falsely pass a switch-back-to-en test regardless of what locale was actually
requested; caught this exact test-design bug while writing it and fixed the adapter, not the source).
Providers held alive via `container.listen(...)` across the switch (they're `AutoDispose` — without an
active listener they'd tear down and refetch on every read regardless of whether `setLanguage` ever
invalidates anything, which would make the test pass for the wrong reason). Proven: (1) a locale switch
with no manual invalidate/pull-to-refresh flips all 3 providers' content; (2) en→zh→en returns cleanly to
en, not stale zh from the middle switch; (3) a failed server PATCH does not invalidate at all.

Gates: analyze 0/0, full suite green (1 known pre-existing unrelated failure), APK builds, pubspec.lock
reconciled.

## zh audit round 4, Phase A2 — quick-onboard sends contentLanguage (CLOSED, 2026-07-31)

**Correction to the record:** an earlier round in this thread concluded the "General Mochi" default
avatar name was user-typed, not a bug — that check only looked at the `create_tutor` wizard. It was
wrong. `direct_onboarding_view_model.dart`'s `quickOnboard()` — the PRIMARY signup path, not the
secondary "add another tutor" flow Workstream 1 fixed — sent NO `contentLanguage` at all. See
`pally-backend/DEFERRED.md`'s "zh audit round 4, Phase A" for the backend half (already merged,
deployed, and live-verified: a zh signup now produces an avatar named `数学小伴`, not `Maths Mochi`).

**Fixed:** `quickOnboard()`'s request now sends `contentLanguage: ref.read(localeControllerProvider).languageCode`
— same source Workstream 1's `create_tutor` wizard uses, so whichever UI language the user is
signing up in is the sensible default here too. The request-body construction was extracted to a
pure `quickOnboardRequestBody(...)` function (no Dio, no network) specifically so this is
unit-testable in isolation — `quickOnboard()` constructs its OWN unauthenticated `Dio()` inline
(deliberately, pre-auth), so it isn't interceptable the same way `create_tutor`'s test intercepts
`dioProvider`.

Tests: `quickOnboardRequestBody` sends the right language for both zh and en, under-13's
`parentEmail` still rides alongside it, 13+ correctly omits `parentEmail` (not sent as null).

Gates: analyze 0/0, full suite green (1 known pre-existing unrelated failure), APK builds,
pubspec.lock reconciled.

**Still open:** the `LocaleController.setLanguage()` provider-invalidation gap (Phase B, a separate
root cause — server-fetched achievement/progress/library data doesn't refresh on an in-app language
switch) and the product decision to remove quick-onboard's own avatar-creation path entirely in
favor of routing everyone through `create_tutor`'s wizard — DECIDED yes by the operator, scoped as
its own follow-up PR pending a funnel-impact report, not bundled here.

## Level-up reward-label wiring — CLOSED (2026-07-31, `feat/level-up-reward-label-wiring`)

Follow-up from the achievement/level-reward i18n pass (see `pally-backend/DEFERRED.md`'s
"i18n coverage" section): the backend computed `unlockedRewardLabel` from day one but no client
surface ever showed it. Wired it into the ONE choke point every level-up celebration goes through:
- `LevelUpController.maybeCelebrate` / `LevelUpOverlay.show` gained `String? rewardLabel`;
  `_CelebrationLayer` renders a 🎁 chip when non-null. Rendered VERBATIM — the label arrives
  already locale-resolved server-side (en says "Mochi" literally, zh says "小伴" literally), no
  client-side {mascot} substitution needed, unlike most other mascot-bearing strings in this app.
- Threaded from all 3 real client trigger points: `QuizState.rewardLabel` (quiz_screen),
  `ChatState.pendingRewardLabel` (chat_screen — covers BOTH session-end and photo-question,
  which share the same `pendingLevelUp` state field), `TeachEvaluation.rewardLabel` (teach_mochi_screen).
- New tests: `QuizState`/`ChatState` copyWith, `TeachEvaluation.fromJson`, and two widget-test files
  (`level_up_overlay_test.dart`, `level_up_controller_test.dart`) proving the chip renders/doesn't
  correctly, including a zh-string-renders-verbatim case.
- Gates: analyze 0/0, full suite green (1 known pre-existing unrelated failure), APK builds.

---

## zh audit round 3 (2026-07-31) — Workstream A: banner-gap trace + shared-widget sweep

**The triggering brief's quoted string ("Upload notes to teach your tutor something new") does not
exist verbatim anywhere in `lib/`.** Grepped every substring across ALL of `lib/` (not just
`lib/features/home` — see the regression note below on why that scoping assumption specifically was
flagged as suspect). Traced the THEME instead (an upload-notes empty-state prompt) to the actual
canonical widget: `lib/core/ui/no_notes_cta.dart`, the ONE shared "no notes yet" CTA CLAUDE.md names
as mandatory for every empty-notes surface (flashcards/quiz/modules/avatar_hub/teach_mochi). Found —
not one banner, but a small family of real gaps in and around it:

1. **`NoNotesCta._centreReminder`** — a `static const` String, hardcoded, literal "Mochi" (not
   `{mascot}`). Renders on all 5 consuming screens for every centre-managed class with no notes yet.
2. **`NoNotesCta.personalButtonLabel`'s default parameter value** (`= 'Upload notes'`) — hardcoded.
   Checked all 5 call sites: NONE overrides it, so this hardcoded default is live on every single
   personal-Mochi empty-notes screen in the app.
3. **`flashcard_screen.dart`'s `NoNotesCta` call** — the lone straggler among the 5 call sites still
   passing a hardcoded literal (`'Upload notes or a document for this Mochi...'`, literal "Mochi"
   again); the other 4 (quiz/modules/avatar_hub/teach_mochi) were already correctly localized.
4. **`mochi_tips.dart`'s `kMochiTips`** — a bare `const List<String>` (10 rotating tips shown during
   AI-wait loading screens, `MochiGenerating`/`MochiThinking`), including the "no random stuff..."
   line separately flagged in the brief. 2 of 10 mention "Mochi" literally, fixed to `{mascot}`.
5. **`splash_lines.dart`'s `kSplashLines`** — same shape, one level worse: a `const List<SplashLine>`
   (a custom class, not even `List<String>`) — shown on **every single app launch** (`splash_screen.dart`)
   and reused for quiz-generation waits (`quiz_screen.dart`). 2 of 8 lines mention "Mochi" literally.
6. **`mochi_thinking.dart` was fully DEAD CODE** — zero callers anywhere in `lib/` or `test/`. Deleted
   rather than localized (its own hardcoded `'Mochi is thinking…'` default would otherwise have been
   a 6th finding, but there was no live caller to reach it).
7. **`mochi_generating.dart`'s `stepLabel` default** (`'Working on it…'`) — confirmed UNREACHABLE
   today (the one live caller, `upload_screen.dart`, always overrides it) but fixed anyway rather than
   leaving a hardcoded trap for the next caller.

All fixed: 29 new ARB keys, `didChangeDependencies`-based init for the two loading widgets whose tip
pick used to happen in `initState` (before `AppLocalizations` is reliably available), `splash_screen`/
`quiz_screen` now carry an index (not the resolved string) across the async gap and resolve content at
render time. Gates: analyze 0/0, full suite 1066 pass (1 known pre-existing unrelated failure), l10n/
layering/B-EXT.2 guards green (guard count UNCHANGED by these fixes — proof these were never visible
to it, see below), APK builds.

### REGRESSION NOTE (as requested): PR-home's banner scope has now been wrong TWICE
PR-home's "the 4 home banners" enumeration (2026-07-29 era) undercounted then; this round's brief
independently suspected the same pattern and was right to flag it — the actual gap wasn't in
`home_screen.dart` at all, and wasn't a "banner" in the literal sense either. **Two things worth
separating:** (a) a human's memory of "a banner that says X" will keep being approximately right, not
exactly right, and keep pointing at the wrong file if you trust the wording over the grep; (b) the
REAL finding here is a new blind-spot category for the coverage guard, not a scoping miss to patch
with a longer file list.

**Should round-2's guard extension be re-run against `home_screen.dart`'s banner-selection logic
specifically?** No — traced it: `home_screen.dart`'s 5 banners (`TrialCountdownBanner`,
`ConsentPendingBanner`, `ModuleProgressBanner`, `AssignmentBanner`, `DueCardsBanner`) are all static
widget references, not a dynamically-chosen list from a source the scanner can't see. There's no
banner-selection logic to re-scan there. The real, now twice-independently-discovered blind spot is
**structural, not location-specific**: three shapes the guard genuinely cannot see, all found this
round:
- a bare **`static const String`** assigned via `=` (no `Text(`/switch-arm/tuple pattern adjacent —
  `_centreReminder` was exactly this),
- a **default PARAMETER value** in a widget constructor (`= 'literal'` in the param list — both
  `personalButtonLabel` and `stepLabel` were this),
- a **`const List<T>`** of anything, including a custom class, not just `List<String>` (`kSplashLines`
  extends round 2's already-ledgered "plain `const List<String>`" blind spot one level further, to a
  list of an app-defined type with string fields).

**Trigger for a guard-extension round 3** (not built this round — this is a report, per the
established "ledger the trigger, don't build speculatively" pattern): add three patterns to the
scanner — `\w+\s*=\s*(?:const\s+)?['"]` (bare const string assignment), a default-parameter-value
scan over widget constructors, and a scan into `const List<...>` element literals regardless of
element type. Until then, the standing mitigation is what round 2 already established: don't trust
the guard's count as exhaustive — grep + read the actual file for any surface an audit specifically
names, the same discipline this round applied to find these three gaps.

---

## zh audit follow-up (2026-07-30) — mobile content_language gate + guard-extension round 2

**Two workstreams, sequenced deliberately: the root-cause gate first (alone, verified), then the
string sweep it exposed.**

### Workstream 1 — mobile create-tutor never sent `content_language` (MERGED `@8ab271f`)
The real bug: a native Chinese speaker creating a tutor on mobile got an ENGLISH avatar regardless of
device/UI locale, because `CreateTutorViewModel` never sent `content_language` in the create-avatar
POST — not a generation-pipeline defect, a missing entry point. Fixed:
- `CreateAvatarRequest`/`Avatar` gained `contentLanguage`; the wizard's `grade_step.dart` gained a
  language-chip picker, defaulting from `localeControllerProvider` (the resolved UI locale) via
  `AppLanguages.all` — not hardcoded to 'en'.
- **Post-creation change capability**, mirroring memoly's `CreateClassModal`/`EditClassModal` pattern
  (`@95fa2ec`): a new `PallyAvatarLanguageSheet` (API-call UX contract compliant — loading/success/error,
  re-entry guard, timeout) reachable from Home, PATCHing the existing avatar's content language.
- Tests: `create_tutor_content_language_test.dart` + `pally_avatar_language_sheet_test.dart`, both
  asserting the actual POST/PATCH body via an `HttpClientAdapter` stub, not just VM state.

### Workstream 2 — guard-extension pass + the sweep it surfaced (this commit)
The trigger ledgered under item 3 below ("guard-extension pass after PR-F") fired: the sink regex was
widened to see switch-arm results (`=>`), and list/tuple literals where the first element is a short
emoji/icon (this codebase's "icon + label(+code)" const-list idiom). The wider scanner surfaced **105
new candidates spanning entirely new sub-features** — far beyond the ~7 items the triggering audit had
enumerated by hand. All of it was localized this pass, not just the enumerated list:
- **Upload family**: tips banner (`upload_tips_banner.dart`), step-label/tab switches in
  `upload_screen.dart`, and a genuine duplicate-content bug in the hero speech bubble (an English-only
  tail clause repeated what the caption below it already said — deleted, not translated) plus a
  co-located raw `avatar!.subject` interpolation (now `localizedSubject`).
- **OCR awareness**: `ocr_what_can_read.dart` (24 keys) and `ocr_tips_overlay.dart` (24 keys) — tier
  labels + tips + readable/tricky content chips, all switch/const-list blind spots.
- **Chapter picker**: `_StateBadge`'s tuple-returning switch + a bare `Text(cond ? 'A' : 'B')` ternary.
- **Subject-vocabulary triple-dedup**: `create_group_screen.dart`'s chip label and `subject_step.dart`'s
  quick-pick chip label now route through `localizedSubject` — display-only, the SENT/stored value is
  untouched (the risky sibling, `SubjectStep`'s own text-field prefill, is deliberately left alone: it
  round-trips through `_subjectToJson`'s canonicalization, so localizing the field itself would break
  saves on edit — same reasoning as the free-text passthrough philosophy already documented in
  `label_localizer.dart`).
- **Onboarding**: `direct_onboarding_view_model.dart` gained a typed `DirectOnboardingErrorKind` (17
  variants) + `direct_onboarding_error_localizer.dart`, replacing ad-hoc `_friendlyError` string-building
  (mirrors the PR-G3/PR-J typed-error pattern); dead `subjectLabel`/`levelLabel`/`levelSubtitle` getters
  (19 strings, superseded by `label_localizer.dart` since PR-B) deleted rather than localized.
- **Streak/progress**: `streak_milestone_overlay.dart` + `daily_goal_ring.dart` getters converted to
  methods(l); `grade_step.dart`'s exam-systems list + a stray `'AGE'` label fixed.
- **Shop cosmetics** (product decision surfaced, not made unilaterally): `MochiCharacter.displayName`
  went from a hardcoded getter ('Pencil Mochi', etc.) to `displayName(AppLocalizations l)`. Asked
  whether the cosmetic NAMES should translate or stay brand-like — **decided: translate**
  ('Pencil Mochi'→'铅笔小伴' etc., using 小伴 as the compound suffix, consistent with every other
  mascot-bearing string). Also fixed two real bugs found while wiring it: `_UnlockedDialog` rendered the
  character name TWICE (redundant duplicate `Text`, deleted); `_formatOdds`'s mystery-box odds sentence
  now resolves the short name from the STABLE `character` code via `MochiCharacter.fromJson(code)`
  instead of the data model's own `.name` field (so the network-failure fallback and the live API both
  render the same localized name, never a raw English one on a zh device).
- **Debug/identifier residue reasoned, not silenced**: `api_client.dart`'s Dio-logger diagnostic switch,
  `feature_flags.dart`/`auth_service.dart`/`milestone_invite_nudge.dart`/
  `streak_milestone_controller.dart`'s cache/storage-key builders, `json_reader.dart`'s
  `JsonParseException.toString()`, and `mochi_config.dart`'s default `toString()` are all developer-only
  (traced every call site — each feeds only `appLog.e`/a storage key/an uncaught-exception message, never
  a widget) — reasoned `debug-log`/`storage-key` in the baseline, two new categories added to the
  vocabulary. `module_list_screen.dart`'s `'$count $key'` and `module_player_view_model.dart`'s `'• $e'`
  are `format` (a passthrough fallback and a bullet + already-server-localized content string,
  respectively — no client-added natural-language token in either).
- **Found and fixed a real duplication bug** (not just residue): `invite_screen.dart` had its OWN
  hardcoded, unlocalized share message ("Join me on Apalchi — the study buddy that learns YOUR notes...")
  duplicating `referral_screen.dart`'s already-localized `l10n.referralShareMessage(code)` for the exact
  same referral flow, with different wording. Deleted the duplicate, reused the existing key. Also found
  its sibling "Show QR"/"Hide QR" ternary label unlocalized (the "ternary not adjacent to a sink keyword"
  blind spot) — 2 new ARB keys (`inviteShowQr`/`inviteHideQr`).
- **`MochiCharacter.defaultSubject`'s free-text-prefill values** ('General', 'English', 'Science', …)
  reasoned `backend-label` in the final regen — same shape as the `SubjectStep` prefill above: it feeds
  `CreateTutorState.subject`, sent as free-text/canonical English, DISPLAY-localized via
  `localizedSubject` wherever actually shown.
- **Reported, not fixed** (premise didn't hold under trace): the audit assumed level-rewards
  (`LevelReward`/`LevelRoadmap`) were a const client-side reward list — the guard-blind-spot shape. Traced
  through `level_roadmap_provider.dart` to the backend's `LevelRewards.java`: genuinely server-owned
  static data. Out of scope for a client PR — needs a backend `content_language` track, same family as
  the LEDGERED PallyError item below. The audit's "home screen 5th banner" could not be located anywhere
  in current source despite exhaustive searching — reported as unverifiable rather than fabricating a fix.

**Baseline: 66 → 88** (net growth, not a regression — the widened scanner now sees real `debug-log`/
`storage-key`/additional `backend-label` residue that was always there but structurally invisible to the
narrower sink regex before this pass; every one of the 88 lines carries an enforced, specific reason).
Full reason-category counts: `format` 43 · `backend-label` 21 · `debug-log` 10 · `storage-key` 4 ·
`nav-fallback` 4 · `emoji-escape` 2 · `device-meta` 2 · `deferred-persisted` 1 · `brand` 1.

### LEDGERED (unchanged by this pass, still open, still the real critical path)
1. **PallyError central-mapper localization** — unchanged since PR-K3; now joined by **level-rewards**
   as a second backend-owned English-data item needing its own `content_language` track (see above).
2. **Typed system-message refactor** (chat_view_model persisted messages) — unchanged since PR-I/J.
3. ~~Coverage-guard blind spot: list/switch string literals~~ — **CLOSED by this pass** (the trigger that
   fired this workstream). The regex now sees `=>` switch arms and emoji-first-element const lists.
   Residual, documented blind spots the scanner STILL can't see (found only by manual full-file reads
   during this sweep, not by the regex): a plain `const List<String>` with no switch/tuple shape; a
   ternary not textually adjacent to a sink keyword (`invite_screen.dart`'s "Show QR"/"Hide QR" was
   exactly this); `_natural()`'s all-caps filter hiding genuinely user-facing ALL-CAPS labels. No trigger
   set for a further extension — closing these needs either a smarter heuristic or continued manual
   review, not a mechanical regex tweak.

---

## Branch B — UI localization (zh) — CLIENT EXTRACTION COMPLETE, BY MEASUREMENT (2026-07-30)

**STATUS: the coverage baseline is 66 = reasoned permanent-ish allows ONLY. Zero un-localized
user-facing English remains in the guard's view; every remaining line has an in-file, enforced reason
(brand / format / nav-fallback / backend-label / device-meta / emoji-escape / deferred-persisted /
deferred-pallyerror). The two `deferred-*` code items (PallyError central-mapper, typed system-message)
and the guard-blind-spot extension pass are the only client-side l10n work left — all ledgered below.
The remaining launch-critical path is HUMAN, not code: native-SG review of `app_zh.arb` (see
`NEEDS_NATIVE_REVIEW.md`), 🔒 anti-steering + consent/deletion + 小伴 first.**

### PR-F — subscription surface localized IN FULL, not just the 39 measured (2026-07-30, MERGE PENDING at commit below)
The guard SAW 39 subscription strings; the surface actually had ~115 (the other ~75 were blind-spot:
switch getters, `const` record/feature lists, default params, ternary `Text` — invisible to the sink
regex). Localizing only the 39 would have shipped a paywall + countdown banner that render ~90% English
on a zh device — the exact "measured-looking, wrong in the visible place" failure. So the FULL visible
surface was localized (113 new keys across all 7 files). Discipline held:
- **en byte-identical** (App Store 3.1.1 anti-steering copy is a compliance artifact — verified
  programmatically: every extracted en value, `{mascot}`→Mochi and adjacent-literals joined, matches the
  pre-PR source).
- **Prices NOT moved to ARB** — `US$9.99/mo` etc. stay as gated literals behind `allowPriceDisplay`; the
  conservative compliance choice, and it means the extraction could not blind the price guard.
- **F0/F3 bracket honoured**: `ios_price_gate_guard` proven to DETECT before (literal path, price-KEY
  indirection path, anti-vacuous self-check) and STILL detect after the extraction (broke each path,
  watched it fail, restored, watched it pass).
- **anti-steering zh flagged 🔒 TOP-PRIORITY** in NEEDS_NATIVE_REVIEW.md (webCtaDefaultIntro,
  subPlansManageIntro, "Manage/cancel on the web", "Continue on web", etc.) — English-safe today; the zh
  MUST be vetted (no implied external payment / added steering) before any zh flag flips for real users.
- Baseline 105 → 66 (all 39 `deferred-PRF` drained, 0 added, 0 unreasoned).

---

## Branch B — earlier history (pre-PR-F)

**CORRECTION (2026-07-29): the earlier "CLIENT EXTRACTION COMPLETE @a8b85d8" claim was SCOPE-based,
not coverage-based, and was wrong.** 13 PRs localized the surfaces on a scope list (~371 strings). A
human walking the app in Chinese then found ~12 unlocalized surfaces; a machine walk of the widget-tree
source found **762 hardcoded user-facing strings across 40 feature directories** still in English —
whole features (photo_question, progress, groups, wiki_viewer, shop, exam_prep, homework, study_plan,
brain_health, invite, …) were never on the scope list. Real coverage was **371 / 1133 ≈ 33%**, not 100%.
This is the same failure mode as the stale ledger titles and the stale branch list: the metric
described the plan, not the artifact.

### Completeness is now MEASURED, not asserted
`test/guard/l10n_coverage_guard_test.dart` walks `lib/` for every hardcoded user-facing string (UI text
sinks + prose heuristic) and fails on any not in a **shrink-only baseline** (`l10n_coverage_baseline.txt`,
seeded at 751). Localize a string → delete its baseline line; you never add a line except for a
legitimately-English string, with a reason. **"COMPLETE" = the baseline is empty**, re-verified by the
guard — not a scope list ticked off. A new hardcoded string fails CI, so the next walk can't surprise us.

### Mascot naming (operator decision): Mochi → 小伴, one source of truth
`mascotName` ARB key (en `Mochi` / zh `小伴`). Every user-facing mascot reference resolves via a
`{mascot}` placeholder — the 42 pre-existing "Mochi" keys were retrofitted, and en stays byte-identical
at runtime (`"New {mascot}"`→`"New Mochi"`) so en finders keep matching while zh reads 小伴. Renaming =
one ARB edit. ✅ **Backend alignment DONE (MERGED pally-backend main @b3b4eff):** the zh generation +
chat directives (`PromptLanguage.ZH_DIRECTIVE` + `ZH_CHAT_BLOCK1_RULE`) now name the mascot 小伴, written
to explicitly OVERRIDE the "keep brand names in official form" clause for the mascot only (so the model
isn't left choosing between two rules). en directive stays "" → byte-identical-English invariant intact;
full backend suite green. So a compiled zh lesson/chat and the app both say 小伴 — no split-brain. NB the
SG-specific term 小伴 itself is part of the standing native-SG review.

### PR plan (~10 PRs; the inventory decided the count)
- ✅ **PR-A** coverage guard + baseline + `mascotName` foundation (42 keys retrofitted) — MERGED `@f95e666`
- ✅ **PR-B** subject/level/tier labels via `label_localizer.dart` resolver (28 keys; the "Maths"→数学 gap;
  free-text subjects pass through UNTRANSLATED; canonical en fns kept; no B-EXT.2 conditional) — MERGED `@4c3d7a6`.
  NB: display sites render variables, so the literal guard can't see this win — baseline unchanged, by design.
- ✅ **PR-C** progress/achievements/goals/streaks (63 keys) — MERGED `@cbc42ab`. First baseline shrink: 751→699.
  Also localized ternary/switch strings the scanner misses (a documented guard blind spot).
- ✅ **PR-D** groups+join+invite (67 keys) — MERGED `@1a2d326`. Baseline 699→627. Fixed cta_invariant to
  resolve the join CTA per test-locale.
- ✅ **PR-E** character shop + flashcards (48 keys) — MERGED `@77358f2`. Baseline 627→588.
- **PR-F** subscription/premium 🔒 + learning-style (LEFT for a fresh session — compliance)
- ✅ **PR-G** photo_question (58 keys) — MERGED `@5f71ef8`. Baseline 588→527. SPLIT: upload + ocr_awareness
  are follow-up PRs (upload has VM error strings needing l threaded).
- ✅ **PR-G2** ocr_awareness (27 keys) — MERGED `@5f9678a`. Baseline 527→499.
- ✅ **PR-G3** upload flow + TYPED upload errors (64 keys) — MERGED `@da1b3c8`. Baseline 499→460.
  VM returns typed `UploadError{kind,fileName?,detail?}`; `localizedUploadError` resolves at render (notifier
  never imports AppLocalizations — layering; re-localizes on live locale switch). The reusable pattern for any
  VM-string localization. `_sourceTypes` dropdown was FOLDED into PR-H (not left a stray follow-up).
- ✅ **PR-H** wiki_viewer+compiled+chapters (64 `wiki*` keys) — MERGED `@92fda9e`. Baseline 460→392.
  Chapter lock banner/picker, compiled-brain screen, wiki viewer + get-it-checked + review-status. ICU plurals
  on every chapter count; helper-scope `l` threaded (getter `_statusLabel`→method(l); `_header`/`_footer`/`_row`/
  `_timeAgo` take `AppLocalizations`). Delegate ripples fixed on 4 screen-rendering tests. Also folded the
  upload `_sourceTypes` dropdown here. AI/teacher content (conflict + delete dialogs, page bodies) untouched.
- ✅ **PR-I** create-tutor flow + chat residue (44 keys) — MERGED `@666951e`. Baseline 392→348.
  create-tutor stepper + typed `CreateTutorError` (PR-G3 pattern); report sheet, homework-scan bubble, photo
  bubbles, answer-card, source-badge chips. ICU plurals on solved/detected counts. DELIBERATELY DEFERRED (ledgered,
  not skipped): `chat_view_model` system-message CONTENT is persisted into the stream + synced to backend →
  needs a typed system-message-kind on the Message model (data-model change, not string extraction); its two
  consent lines are compliance copy → **routed to PR-J**.
- ✅ **PR-J** 🔒 consent + account_deletion + auth (84 keys) — MERGED `@eef5235`. Baseline 348→290. COMPLIANCE:
  byte-faithful en, every zh flagged for native-SG review as a launch precondition. AI-disclosure, parental-
  consent-pending, delete-account (+VM), restore, complete-profile (+VM). Typed `CompleteProfileError` +
  `DeleteAccountError`; shared month names + `dateFormatDMY` (zh {year}年{month}{day}日). NOT WIRED (honest,
  drafted zh in tracker): the 2 chat_view_model consent MESSAGES (persisted → ride the deferred typed-system-
  message refactor) + shared `PallyError` network strings (central-mapper PR).
- ✅ **PR-K1** widget-tree long tail, 20 feature dirs (186 keys) — MERGED `@dcc46ac`. Baseline 290→134.
  teach_mochi/homework/exam_prep/referral/study_plan/quiz/brain_health/assignments/centre_join/chat family/
  learning_style/feature tour/voice dialogs/centre_block/splash/avatar_picker/collection/create_tutor/
  force_update/weakness/upload tips. TeachingModeX.label getter DELETED (label at render); DateFormat now
  locale-aware. Delegate ripples on 8 test harnesses; cta_invariant centre_join + create_tutor step-2
  resolve per locale.
- ✅ **PR-K2** 🔒 consent-gate sheet OUT of api_client (12 keys) — MERGED `@0a404e7`. Baseline 134→128.
  The kind shape already existed (interceptor threads the reason CODE); the sheet moved to
  features/consent and localizes at render; interceptor toasts localize via the global-navigator ctx;
  the hidden 'your grown-up' masked-email fallback (3 context-less call sites) now resolves INSIDE the
  pending sheet (nullable maskedEmail). Hazard fixed: PARENT_LINK_REQUIRED navigation now runs BEFORE the
  toast (an l10n throw could previously swallow the redirect). New consent_gate_sheet_test (5 cases).
  All 12 zh drafts 🔒 flagged with the PR-J set.
- ✅ **PR-K3** core/shared infra + notifications (56 keys) — MERGED `@fbc461b`. Baseline 128→105.
  Delete-tutor + relevance dialogs, router error, app_async/app_error_view, mochi_generating; notification
  pipeline localized CONTEXT-FREE (schedule methods take AppLocalizations; callers resolve
  lookupAppLocalizations(persisted locale); channels + ICU plural; flashcard 'your Mochi'→notifYourMascot);
  module item-count chips (closed learn/test/prove set, resolver + raw fallback).
- **PR-F** subscription — RESERVED, own session (re-prove ios_price_gate_guard before+after, human eyes on zh)

### Baseline END STATE (post-K4): 105 = 39 PR-F + 66 allows, EACH REASON ENFORCED IN THE FILE
Buckets (per-line reason now lives in the baseline's third column, not a PR description): `format` 41
(interpolation + numerals/symbols/punctuation/emoji, no natural-language tokens) · `deferred-PRF` 39
(subscription, English-by-design until PR-F) · `backend-label` 14 (`avatar.dart` 13 + `entitlement.dart` 1;
DISPLAY localizes via `label_localizer` since PR-B) · `nav-fallback` 4 (`scaffold_shell` const `TabSpec.label`;
DISPLAY localizes via `_navLabel` branchIndex→navHome/navLibrary/navGroups/navMe — see below) · `device-meta` 2 ·
`emoji-escape` 2 · `brand` 1 (`'Pally'` MaterialApp.title) · `deferred-persisted` 1 (`chat_view_model` 📷
Homework photo) · `deferred-pallyerror` 1 (`direct_onboarding_view_model`). After PR-F drains its 39, the
baseline IS the allow list — a new hardcoded string fails CI.

### PR-K4 — allow-list made auditable + the nav-labels premise CORRECTED (2026-07-30)
An allow-list line with no in-file reason is the coverage guard lying politely: the number reads
"105-and-shrinking" while a reason that lives only in a merged PR description evaporates. Fixed:
- **Baseline format is now `<relpath>\t<string>\t<reason>`, and the reason is ENFORCED** —
  `unreasonedBaselineKeys` fails the guard on any bare allow (proven: stripping the `Pally` reason failed
  the real guard; a unit test pins the detector). Regeneration PRESERVES reasons; a newly-baselined string
  gets `NEEDS_REASON` and fails until justified. This is the escape-hatch-closer the shrink-only baseline
  lacked. All 105 lines audited into the buckets above.
- **The four nav labels were NOT an escape — the premise "Home/Library/Groups/Me render English" is WRONG.**
  `scaffold_shell.dart:109` renders `_navLabel(l10n, tab)`, which maps branchIndex 0-3 →
  navHome/navLibrary/navGroups/navMe (both ARBs: 主页/学习库/小组/我的). `tab.label` is referenced ONCE
  (line 74) as the `_ =>` fallback for an UNMAPPED branch — unreachable for tabs 0-3. The baseline literals
  are the `const TabSpec.label` fallbacks the regex-scanner sees in source but that never render. Localizing
  `buildTabs()` would be wrong (breaks the const data structure, duplicates the resolver). New permanent test
  `test/widget/nav_shell_localized_test.dart` pumps the real `ScaffoldShell` under en+zh and asserts the nav
  renders 中文 (and not the English fallbacks) — the device-locale walk as CI evidence, and the regression
  guard if anyone reverts to `label: tab.label`.

### LEDGERED (with triggers), not skipped
1. **PallyError central-mapper localization** — MEASURED 2026-07-30: 32 `.userMessage` sites across 25
   files, most baking `error: String` into VM state → the PR-G3/PR-J typed-error refactor at full scale,
   NOT a <20-string mechanical pass. Its curated strings (several say "Mochi") render English under zh.
   **Trigger: before any zh flag flips for real users** — either typed-kind states per VM (correct) or an
   interim `localizedPallyError(l, kind)` resolver at the ~15 screen render sites (cheaper, catches most).
2. **Typed system-message refactor** (chat_view_model persisted messages incl. '📷 Homework photo' + the
   2 consent lines from PR-I/J) — data-model change; zh drafts already in NEEDS_NATIVE_REVIEW.md.
3. **Coverage-guard blind spot: list/switch string literals** — the sink regex can't see list elements or
   switch arms (found live: upload_screen step-label lists, ~15 strings, still English). Trigger: one
   guard-extension pass (add list/switch sinks) after PR-F, then drain what it surfaces the same way.
Each: same recipe; delegates on any screen-rendering test; lock→3.32.1 before push; coverage guard must
shrink (never grow); 🔒 compliance rules if price/subscription copy is touched.

---

### (historical) the 13 scope-list PRs — all merged, all still valid work
Registry-driven (`AppLanguages`), ARB + gen-l10n, harness parameterized over `AppLanguages.all`.

### STANDING LAUNCH GATES (in addition to finishing coverage in the plan above)
`lib/l10n/app_zh.arb` is **machine-drafted**. Before any zh launch, a native Singapore
Chinese educator MUST review `lib/l10n/NEEDS_NATIVE_REVIEW.md` (SG conventions: 华语/中文, 巴士/德士/
组屋, no mainlandisms). **Two items on that review are load-bearing:**
1. 🔒 **PR10 anti-steering copy** (`settingsKeepPremiumPrice` / `settingsKeepPremium`) — flagged
   COMPLIANCE. It exists to satisfy App Store guideline 3.1.1. A translator optimizing for natural
   Chinese could easily imply external payment; that is a rejection risk on a build already in review.
   The zh must stay faithful in meaning, add no purchase steering, and keep `US$9.99/mo` verbatim.
   The `ios_price_gate_guard_test` now follows the l10n indirection (any file referencing a
   price-valued ARB key must gate it) so a future ungated price key fails the build.
2. The backend moderation false-positive (PERSONAL_DATA/HIGH on comprehension questions — see
   `pally-backend/DEFERRED.md`), which bites zh comprehension hardest.

### Deliberately scoped OUT of the client extraction (each its own small data-file PR IF wanted):
- `prettyTier` plan names ("Premium", …) — shared model (`entitlement.dart`).
- `subjectLabel` / `levelLabel` / `levelSubtitle` — onboarding subject/education-stage option labels,
  defined in a shared onboarding-data file, not any one screen.
- Email-format hint examples (`your@email.com`, `parent@example.com`) — kept verbatim as illustrations.

---

### (historical note — the architecture as it stood mid-branch)
The client i18n architecture is established and the **daily student loop — including the home
screen and bottom nav — is fully localized**. Registry-driven (`AppLanguages`), ARB + gen-l10n,
harness parameterized over `AppLanguages.all`.

### SHIPPED (all merged to main)
- PR1 scaffolding + AppLanguages registry + LocaleController + settings language-picker + harness
  locale-axis + 4 guard tests (`@d0b39ef`)
- PR2 sign-in + B4 entry-selector + reconcileToServer mirror at account creation (`@47161ed`)
- PR3 onboarding tour (first ICU placeholder) (`@ea7e1ef`)
- PR4 library home hub (first real ICU plurals: en 1-vs-N, zh `other`) (`@0d264db`)
- PR5 avatar hub (`@d1ad665`)
- PR6 chat chrome — highest-traffic surface; this is where a zh session's moderation refusal
  (backend fix) now renders in Chinese (`@d35c63f`)
- PR7 module SCREENS (list + player shell) (`@227a7a6`)
- PR8 quiz (question chrome, results, re-teach nudge) (`@cfc50ce`)
- PR-home HOME screen + bottom NAV shell + the 4 home banners + consent-pending banner (~51 strings).
  Closed the nav-shell gap the on-device E2E walk surfaced (home + nav were English while every other
  loop surface was zh). Nav labels resolve via a branchIndex switch (semantic map, not a language
  conditional). (`@31ec07a`)
- PR9 module item BODY widgets — LearnBody/TestBody/ProveBody/complete/muddiest/self-assess + proof
  chips (~48 strings). Static chrome only; item CONTENT left verbatim (backend `content_language`).
  (`@614c473`)
- PR10 SETTINGS screen (~50 strings). Carried the 🔒 anti-steering price copy (App Store 3.1.1):
  extracted byte-identical, gate structure unchanged, `ios_price_gate_guard_test` strengthened to
  follow the l10n indirection. (`@a6be358`)
- PR11 SIGN-UP form — `direct_onboarding_screen.dart`, the 3-step flow (~55 strings). Biggest surface.
  (`@051c3d2`)
- PR12 "What makes Apalchi different" explainer (10 strings). (`@a8b85d8`)

### REMAINS on the client: PR-B … PR-K in the plan at the top (762→0 baseline). The
### "nothing remains" note that was here was the scope-based error this correction fixes.

### THE RECIPE (non-negotiable, proven over 8 PRs)
1. Extract user-facing strings to ARB (en **byte-identical** to current hardcoded so en-locale test
   finders keep matching; zh machine-drafted; every zh row appended to `lib/l10n/NEEDS_NATIVE_REVIEW.md`).
2. ICU plural/select for anything countable — never fragment assembly; zh resolves via `other`.
3. Placeholders with descriptions. REUSE existing keys (`commonCancel`, `commonTryAgain`,
   `commonLoading`, `commonCheckConnection`, `moduleCtaReview`, `libraryEmptyTitle`, …) before minting.
   (Watch case: `commonTryAgain` is "Try Again" not "Try again" — a reuse that changes case updates the test.)
4. NO language conditionals in widgets (B-EXT.2 grep guard stays green).
5. DO NOT translate: Mochi's name, class names, teacher-uploaded content, student text, AI artifacts.
6. **Two ripples that cost a cycle each — apply proactively:** (a) any test that RENDERS the screen
   needs `AppLocalizations.localizationsDelegates` + `.supportedLocales` — INCLUDING view-model tests
   that pump the widget, not just `*_screen_test`; (b) reconcile `pubspec.lock` to its 3.32.1 resolution
   (`git checkout HEAD -- pubspec.lock`) before every push.
7. Gates per PR: analyze clean · full suite at BOTH locales · geometry + CTA at both locales · APK builds ·
   no `pubspec.yaml` change.

### STANDING NATIVE-REVIEW GATE (the real Chinese-launch critical path — NOT more client PRs)
`lib/l10n/app_zh.arb` is ~371 MACHINE-DRAFTED strings (see the top of this section for the two
load-bearing items). Before any zh launch, a native Singapore Chinese educator must review
`lib/l10n/NEEDS_NATIVE_REVIEW.md` (SG conventions: 华语/中文, 巴士/德士/组屋, no mainlandisms). Also
gate the backend moderation false-positive (PERSONAL_DATA/HIGH on comprehension questions — see
`pally-backend/DEFERRED.md`), which bites zh comprehension hardest.

---

## Small-screen geometry audit (2026-07-21) — follow-ups from Phase A

### ✅ CLOSED (2026-07-21, fix/dependency-lock-and-dio): dio 5.10.0 fresh-`pub get` compile break
- **Was:** `pubspec.lock` gitignored + `dio: ^5.7.0` → a fresh `flutter pub get` resolved dio 5.10.0,
  whose new `DioExceptionType.transformTimeout` broke the exhaustive DioException switches
  (`api_client.dart` switch expression, `pally_error._fromDio`) → whole app failed to compile.
- **Fixed by:** committing `pubspec.lock` (un-gitignored; dio pinned 5.9.2 — the resolution that builds
  today's passing APK) + capping `dio: ">=5.7.0 <5.10.0"` as the documented ceiling.
- **Clean-checkout evidence (the fail-without-fix proof):** a detached worktree of the branch commit →
  `pub get` → **dio 5.9.2 → analyze clean → APK builds**. A detached worktree of `main` (lock removed,
  as it is gitignored there) → `pub get` → **dio 5.10.0 → 3 hard compile errors** in api_client +
  pally_error. Branch reproducible, main broken-on-clean-build.
- **Note on the switch DEFENSE (deliberately NOT done):** forward-compat `default`/`_` arms can't be
  added cleanly — against the current (exhaustive) `DioExceptionType` they are
  `unreachable_switch_case/default` warnings. The committed lock + cap are the correct protection;
  a deliberate future move past 5.10 should add explicit handling for the new type then (the compile
  error is the right forcing function). Also verified: the spec's named files
  (create_tutor_view_model / auth_service / progress_view_model) have NO DioException switch;
  `upload_view_model` already has a `_ =>` and is safe.

### Onboarding CTAs below the fold at 360×640 (CONFIRMED, tests written + skipped)
- **What:** `direct_onboarding` (steps 1-2) and `onboarding` (pages 1-3) render their primary CTA
  ("Next"/"Create account"/"Let's go →") below the 640-fold — reachable only by scrolling. Confirmed
  by `test/geometry/cta_invariant_test.dart` (the 5 tests are committed, `skip:`-ed with a DEFERRED ref).
- **Why deferred:** the fix is pattern (1) (pin the CTA: `Column[Expanded(scroll), pinnedCTA]`), but it
  restructures two AUTH-FLOW screens (`direct_onboarding_screen` is 1500+ lines) and deserves careful,
  unhurried work + its own verification — not end-of-session bracket surgery. Stays strictly layout-only.
- **Closes it:** pin each page/step CTA out of the scroll; un-skip the 5 CTA tests (they gate it green).

### settings_screen — ListTile without a Material ancestor
- **What:** a `ListTile` sits in a coloured `DecoratedBox` with no `Material` between (×2) →
  "background/ink may be invisible" assertion. Surfaced + EXCLUDED (with reason) in the smoke registry.
- **Why deferred:** a render-hierarchy fix (wrap in `Material`), not one of the 2 geometry patterns.
- **Closes it:** add the `Material` ancestor; re-enroll `settings_screen` in the smoke registry.

### subscription_return_screen — provider mutated during build
- **What:** `initState` → `_poll()` → `ref.read(entitlementVmProvider.notifier).refresh()` mutates a
  provider during first build ("Tried to modify a provider while the widget tree was building").
  Surfaced + EXCLUDED (with reason) in the smoke registry.
- **Why deferred:** a LOGIC/state fix (defer the poll to a post-frame callback), NOT layout — out of the
  branch's scope rule ("a fix that can't stay layout-only → STOP + report").
- **Closes it:** move the initial `_poll()` to `WidgetsBinding.addPostFrameCallback`; re-enroll the screen.

---

## Avatar Hub (shipped 2026-07-14) — follow-ups

### Home avatar cards through the hub
- **What:** Home's `_AvatarCard` (`home_screen.dart`) taps DIRECTLY to `ModuleListRoute`;
  the Library rows now go through the per-avatar Hub. For consistency, Home should route
  through the hub too — one front door everywhere.
- **Why deferred:** Home is NOT just a different tap target — its card is a grid tile with
  its OWN concepts the hub doesn't model: `isActive` slot-lock (`_showSlotLockedSheet`) and
  a long-press tutor-options menu (`_showTutorOptions`). Folding those into the hub is its
  own design pass, and it doubles the diff of a de-clutter that shipped clean on Library alone.
- **Closes it:** a dedicated Phase 0 for the hub absorbing slot-lock + long-press semantics,
  then re-point `_AvatarCard.onTap` (active branch) to `AvatarHubRoute`.

### Hub v2 — absorb the remaining avatar-scoped surfaces
- **What:** study-plan, brain-health, exam-prep, homework are avatar-scoped routes that sit
  OUTSIDE the current journey (Learn → Practice → Prove → Tools). Should the hub become the
  single index for them too?
- **Why deferred:** v1's job was to make the CORE journey legible; bolting on four more rows
  would recreate the clutter we just removed, one level down. It's a product-IA decision, not
  a mechanical add.
- **Closes it:** decide the v2 information architecture (a "More" section? a second tab? leave
  them on their own entry points?) with the real screens in front of you, then wire the chosen
  shape — reusing the `_HubSection` / `_HubRow` grammar already in `avatar_hub_screen.dart`.

### Hub small-device density (fast-follow, belt-and-suspenders)
- **What:** the hero's "N modules · X% mastery" + progress bar is now the densest line in the
  app. The suite pins no-overflow at 320dp / 1.3× textScale, but a real SE-class-width visual
  pass at 1.3× on the hero is worth a manual glance.
- **Closes it:** run the hub on an SE-width device at 1.3× accessibility text; confirm the hero
  line wraps (never clips). Non-blocking — the guard test already asserts `takeException()==null`.
