#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Pally Flutter — canonical run script
# Run from pally/ directory.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ADB=~/Library/Android/sdk/platform-tools/adb

# ── 1. Check backend is up ────────────────────────────────────────────────────
if ! curl -sf http://localhost:8080/actuator/health 2>/dev/null | grep -q '"status":"UP"'; then
  echo "ERROR: Backend is not running on port 8080."
  echo "  Start it first:  cd ../pally-backend && ./start.sh"
  exit 1
fi
echo "Backend UP on port 8080 ✓"

# ── 2. Find emulator ──────────────────────────────────────────────────────────
DEVICE=$(flutter devices 2>/dev/null | grep "emulator" | awk '{print $4}' | head -1)
if [[ -z "$DEVICE" ]]; then
  echo "No emulator found. Start one in Android Studio or run:"
  echo "  flutter emulators --launch <emulator-id>"
  exit 1
fi
echo "Target device: $DEVICE ✓"

# ── 3. API URL — Android emulator must use 10.0.2.2 to reach host ─────────────
# iOS simulator uses localhost. Physical device uses your machine's LAN IP.
API_URL="http://10.0.2.2:8080"
echo "API URL: $API_URL"
echo ""

# ── 4. Kill stale Flutter processes ──────────────────────────────────────────
pkill -f "flutter_tools\|flutter run" 2>/dev/null || true
sleep 1

# ── 5. Run codegen if needed ──────────────────────────────────────────────────
cd "$SCRIPT_DIR"
dart run build_runner build --delete-conflicting-outputs 2>&1 | tail -3

# ── 6. Launch ─────────────────────────────────────────────────────────────────
echo ""
echo "─────────────────────────────────────────────────"
echo "  Starting Pally Flutter"
echo "  Device : $DEVICE"
echo "  API    : $API_URL"
echo "─────────────────────────────────────────────────"
echo ""

flutter run \
  -d "$DEVICE" \
  --dart-define=API_BASE_URL="$API_URL" \
  --no-pub \
  2>&1 | tee /tmp/flutter_run.log
