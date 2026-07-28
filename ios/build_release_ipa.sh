#!/usr/bin/env bash
#
# Canonical iOS release build for Apalchi. Run from the REPO ROOT:  ./ios/build_release_ipa.sh
#
# Why this file exists: the iOS archive command used to live only in shell history, so an
# ad-hoc `flutter build ipa` could silently omit --dart-define=APP_ENV=production (→ prod
# telemetry routed to the DEV Sentry project) — the same "native/build config lives outside
# the Dart guards" class that has bitten before. This is the committed, reviewable procedure.
#
# ── TOOLCHAIN (do not get this wrong) ─────────────────────────────────────────────────────
# iOS MUST be built with Flutter 3.44.2, NOT the 3.32.1 that .fvmrc pins for the ANDROID
# release. ios/Runner/AppDelegate.swift uses the implicit-engine APIs (FlutterImplicitEngine-
# Delegate / FlutterImplicitEngineBridge) that DO NOT EXIST in 3.32.1's engine — a 3.32.1
# `flutter build ios` fails at Swift compile ("Cannot find type 'FlutterImplicitEngineDelegate'").
# The .fvmrc pin is Android's. Cut the iOS binary on 3.44.2 (proven: builds Runner.app clean).
#
# ── SIGNING (operator-supplied; never in git) ─────────────────────────────────────────────
# Automatic signing, DEVELOPMENT_TEAM = 5RZ3AWVS9M. To archive/upload you must be signed into
# Xcode with a member of that team holding a valid Apple Distribution certificate and an App
# Store provisioning profile for com.apalchi.app. --export-method app-store + auto-provisioning
# selects the distribution cert.
#
# ── PUSH ──────────────────────────────────────────────────────────────────────────────────
# The Release config uses Runner/RunnerRelease.entitlements (aps-environment = production).
# End-to-end APNs<->FCM delivery on iOS is an explicit POST-LAUNCH verification (needs a real
# device + distribution cert); it is NOT a submission dependency for v1 (push degrades off).
#
# APP_ENV=production is the ONE required dart-define; API_BASE_URL/SENTRY_DSN have prod defaults.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"   # override to point at your 3.44.2 install if `flutter` isn't it
echo "Using: $("$FLUTTER_BIN" --version | head -1)"
case "$("$FLUTTER_BIN" --version | head -1)" in
  *3.44.*) : ;;
  *) echo "WARNING: iOS release expects Flutter 3.44.x — see the toolchain note above." >&2 ;;
esac

# --obfuscate + --split-debug-info mirror the Android release (Sentry de-obfuscation).
"$FLUTTER_BIN" build ipa --release \
  --dart-define=APP_ENV=production \
  --obfuscate \
  --split-debug-info=build/ios-symbols

echo "IPA at build/ios/ipa/*.ipa — upload via Xcode Organizer or:"
echo "  xcrun altool --upload-app -f build/ios/ipa/*.ipa -t ios --apiKey <KEY> --apiIssuer <ISSUER>"
