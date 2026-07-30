# Deferred items — pally (client) ledger

> The tracked home for consciously-deferred CLIENT gaps: things we chose not to do
> yet, each with a reason and **what closes it**. (Backend deferrals live in
> `pally-backend/DEFERRED.md`.) When you defer something, add it here — don't leave
> it "low priority" with no owner.

---

## Branch B — UI localization (zh) — IN PROGRESS, ~33% COVERAGE (2026-07-29)

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
- **PR-J** consent+account_deletion+auth (QUIET COMPLIANCE — byte-faithful meaning, no "improving" the English,
  flag zh for native reviewer alongside the 🔒 set) — INCLUDES the two chat_view_model consent lines from PR-I
- **PR-K** long tail (homework/exam_prep/study_plan/brain_health/teach_mochi/centre/assignments/etc.)
- **PR-F** subscription — RESERVED, own session (re-prove ios_price_gate_guard before+after, human eyes on zh)
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
