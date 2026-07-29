# Deferred items — pally (client) ledger

> The tracked home for consciously-deferred CLIENT gaps: things we chose not to do
> yet, each with a reason and **what closes it**. (Backend deferrals live in
> `pally-backend/DEFERRED.md`.) When you defer something, add it here — don't leave
> it "low priority" with no owner.

---

## Branch B — UI localization (zh) — HANDOFF (paused 2026-07-29, main @cfc50ce)

The client i18n architecture is established and the **daily student loop is fully localized**.
Registry-driven (`AppLanguages`), ARB + gen-l10n, harness parameterized over `AppLanguages.all`,
**157 zh strings drafted** across 8 merged PRs. Adding a third language later = one registry
entry + one ARB file (Spanish/etc. get geometry+CTA coverage automatically).

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

### REMAINS (priority order; follow the SAME recipe — do NOT invent new patterns)
1. **Module item BODY widgets** — `LearnBody` / `TestBody` / `ProveBody` and the item types
   (MICRO_CARD / HOT_TAKE / SPOT_MISTAKE / CHALLENGE) under `features/modules/presentation/widgets/`.
   Deferred from PR7 (large sub-surface); PR7 shipped only the module screens' chrome.
2. **Settings** — complete the partial surface from PR1 (~60 strings, `settings_screen.dart` 999 lines).
   CAUTION: the Subscription/Referral cards contain price strings behind the iOS anti-steering
   `allowPriceDisplay(ref)` gate — localize the LABELS but do NOT change what the gate shows.
3. **Sign-up form** — `direct_onboarding_screen.dart` (1507 lines). Biggest surface, hit once per user;
   last for that reason. Most likely to strand — do it as its own focused session.

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
`lib/l10n/app_zh.arb` is 157 MACHINE-DRAFTED strings. Before any zh launch, a native Singapore Chinese
educator must review `lib/l10n/NEEDS_NATIVE_REVIEW.md` (SG conventions: 华语/中文, 巴士/德士/组屋, no
mainlandisms). Also gate the backend moderation false-positive (PERSONAL_DATA/HIGH on comprehension
questions — see `pally-backend/DEFERRED.md`), which bites zh comprehension hardest.

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
