# Apalchi Mobile — Claude Code Rules

> Rules file. Not a build script. Read fully before changing code.
> Product: **Apalchi** — the student app (B2C direct learners + B2B centre students).
> Mascot: **Mochi**. Learning loop: **LEARN → TEST → PROVE**.
> North star: a study partner that knows the student's OWN uploaded notes, not a generic textbook.

## Stack
- Flutter (Dart SDK ≥3.3), Riverpod 2.6 (`flutter_riverpod ^2.6.1`), GoRouter 15, Drift/SQLite 2.20,
  Dio 5.7, just_audio.
- State lives in view models / providers; screens are UI only.

## MANDATORY WORKFLOW (every change, no exceptions)
1. `dart analyze lib/` — zero errors, zero warnings.
2. `flutter test` — all pass.
3. `flutter build apk --debug` — compiles.
4. After any `@riverpod` change: `dart run build_runner build --delete-conflicting-outputs`.
5. Only report "done" after all pass. If anything fails, fix and re-run from step 1.

## TESTING IS NOT OPTIONAL
Every new piece of code ships with tests. No "later", no "existing tests cover it".
- New domain logic / view model / pure function → unit test.
- New widget / screen → widget test rendering at least loading / loaded / error states, inside a
  `ProviderScope` with overridden providers asserting visible widgets.
- New atomic / money / XP / stars path → atomicity + race-loss test mandatory.
- New Riverpod provider → a state test of the pure `state` transitions.
- New code ≥90% covered. Test names describe the invariant in plain English a reviewer can agree with.

## ARCHITECTURE — MANDATORY
**No network/API calls in screen widgets.** Data access lives in view models / providers. Screens compose
UI and call view-model methods. (This is already true — keep it true.)

**No god-widgets.** A screen file with many private widget classes must extract them into a per-feature
`widgets/` folder. A screen file over ~600 lines is a split candidate.

**One shared widget per repeated concern.** All "no notes / empty state / centre-vs-personal" decisions go
through the shared `NoNotesCta` family — never re-implement the empty/upload logic inline. (Inline copies
are what caused the centre upload-leak whack-a-mole.)

**Centre-vs-personal rule (canonical, applies on EVERY surface):**
- Centre class with no notes → static "ask your teacher" message, **NO tap action**, never an upload or
  generate button.
- Personal Mochi with no notes → "Upload notes" → upload flow.
- Either kind WITH notes → "Generate / Build lessons".

**No logic in `build()`** — UI composition only. **GoRouter only** — never `Navigator.push`.
**`ref.read()` only in callbacks**, never in `build()`. **Constructor injection**; always `super.key`.

**Design tokens only — never hardcode colours, text styles, or spacing.** Use `AppColors.*`,
`AppTextStyles.*`, `AppSpacing.*`.

## DESIGN TOKENS (source of truth: `lib/core/theme/`)
Colours (`AppColors`): purple `0xFF7042ED`, purpleL `0xFFEBE0FF`, purpleC `0xFF8F66FA`, teal `0xFF00BBA4`,
tealL `0xFFD7F7F3`, coral `0xFFFF6660`, amber `0xFFFFB81A`, green `0xFF2EC870`, pink `0xFFFF6BAE`, gold
`0xFFFFD100`, bg `0xFFFAFAFF`, surface `0xFFFFFFFF`, surf2 `0xFFF5F2FC`, outline `0xFFE0DAF0`, text1
`0xFF1F1733`, text2 `0xFF6B618A`, text3 `0xFFA8A0BD`.
Type (`AppTextStyles`, font **Nunito**): heading1 22/w800, title 18/w700, body 14/w400, bodySmall 12/w400,
label 11/w600, caption 9/w400.
Spacing (`AppSpacing`): xs 4, sm 8, md 16, lg 24, xl 32, xxl 48.

## DON'T
- network call in a screen widget · god-widget (>600 lines) · inline-duplicated empty/no-notes states ·
  offering upload/generate on an empty centre class · logic in `build()` · `Navigator.push` ·
  `ref.read()` in `build()` · hardcoded colours/spacing/text styles · skipping `super.key` · using
  GetX or the `provider` package (Riverpod only) · hardcoded API keys (use `--dart-define`).

## API CALL UX CONTRACT (mandatory on every button that fires a network call)
Three phases every action button must implement:
1. **LOADING** — disable the button (`onPressed: null` or guard via `_isGenerating`); show an inline
   spinner or progress text. Never toast "loading".
2. **SUCCESS** — refresh data (re-watch the provider or call `ref.invalidateSelf()`). No toast unless
   the action earns XP/stars.
3. **ERROR** — show a **persistent inline error message** with a Retry button. Never use toast-only for
   a primary action; toasts vanish before the user reads them.

**Re-entry guard** — every action method in a view model must return early when already in flight:
```dart
if (state.isLoading) return;      // AsyncNotifier
if (_pendingAction) return;       // instance flag for fire-and-forget / non-AsyncValue actions
```
**Timeout** — every `dio.post / dio.put / dio.delete` that may be slow (generation, upload, AI calls)
must pass `Options(receiveTimeout: Duration(...), sendTimeout: Duration(...))`.

## DON'T (additions)
- `VoidCallback` wrapping an async action that can fail · toast-only error for a primary action ·
  re-entrant write method with no guard · slow `dio` call with no explicit timeout.

## Common commands
```
dart analyze lib/
flutter test
flutter build apk --debug
dart run build_runner build --delete-conflicting-outputs
```
