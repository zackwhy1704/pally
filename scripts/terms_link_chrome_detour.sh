#!/usr/bin/env bash
# Companion to integration_test/eula_terms_and_report_demo_test.dart.
#
# The "Read the full Terms of Use" link opens Chrome via an external Android
# Intent (url_launcher's LaunchMode.externalApplication) — outside the
# Flutter widget tree, so the on-device test can't drive it directly. This
# script runs concurrently on the host and does the real on-screen work by
# polling which app is focused, never a blind sleep:
#   1. wait until a non-Apalchi app is foregrounded (Chrome opened)
#   2. hold 2.5s so the Terms page is legible on camera
#   3. one slow scroll-down swipe
#   4. hold 1.5s
#   5. BACK — return to Apalchi
#   6. wait until Apalchi is foregrounded again, then hold 0.5s
#
# Start this BEFORE (or at the same moment as) the flutter test run — it
# just sits in its poll loop until the terms link is actually tapped, so
# early start is harmless.
#
# Usage: ./scripts/terms_link_chrome_detour.sh <device-serial>

set -euo pipefail

SERIAL="${1:?Usage: terms_link_chrome_detour.sh <device-serial>}"
ADB="${ANDROID_ADB:-$HOME/Library/Android/sdk/platform-tools/adb}"
APP_ID="com.apalchi.app"
POLL_INTERVAL=0.3
TIMEOUT_S=30

focused_package() {
  "$ADB" -s "$SERIAL" shell dumpsys window 2>/dev/null \
    | grep -m1 'mCurrentFocus' \
    | sed -nE 's#.* ([a-zA-Z0-9_.]+)/[a-zA-Z0-9_.]+\}?$#\1#p'
}

wait_until() {
  # wait_until <description> <predicate-fn>
  local desc="$1" predicate="$2" waited=0
  echo "[detour] waiting: $desc"
  while true; do
    if "$predicate"; then
      echo "[detour] ok: $desc"
      return 0
    fi
    sleep "$POLL_INTERVAL"
    waited=$(echo "$waited + $POLL_INTERVAL" | bc)
    if (( $(echo "$waited > $TIMEOUT_S" | bc -l) )); then
      echo "[detour] TIMEOUT waiting: $desc" >&2
      exit 1
    fi
  done
}

is_chrome_foreground() {
  local pkg
  pkg=$(focused_package)
  [[ -n "$pkg" && "$pkg" != "$APP_ID" ]]
}

is_app_foreground() {
  local pkg
  pkg=$(focused_package)
  [[ "$pkg" == "$APP_ID" ]]
}

wait_until "Chrome (or default browser) foregrounded after Terms link tap" is_chrome_foreground

echo "[detour] hold 2.5s — Terms page legible"
sleep 2.5

echo "[detour] slow scroll down"
# Pixel 8 is 1080x2400. One slow downward swipe, ~900ms duration.
"$ADB" -s "$SERIAL" shell input swipe 540 1900 540 700 900

echo "[detour] hold 1.5s"
sleep 1.5

echo "[detour] BACK to Apalchi"
"$ADB" -s "$SERIAL" shell input keyevent 4

wait_until "Apalchi foregrounded again" is_app_foreground

echo "[detour] hold 0.5s"
sleep 0.5

echo "[detour] done"
