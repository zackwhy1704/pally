# Deferred items — pally (client) ledger

> The tracked home for consciously-deferred CLIENT gaps: things we chose not to do
> yet, each with a reason and **what closes it**. (Backend deferrals live in
> `pally-backend/DEFERRED.md`.) When you defer something, add it here — don't leave
> it "low priority" with no owner.

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
