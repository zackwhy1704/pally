#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Pally Flutter — canonical run script
# Usage: ./start.sh
# Always uses Railway production backend (https://pallybackend-production.up.railway.app)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 1. Find Pixel 8 (prefer physical device over emulator) ───────────────────
DEVICE=$(flutter devices 2>/dev/null | grep "49051FDJH002K5" | awk '{print $4}' | head -1)
if [[ -z "$DEVICE" ]]; then
  DEVICE=$(flutter devices 2>/dev/null | grep -i "pixel\|android" | grep -v emulator | awk '{print $4}' | head -1)
fi
if [[ -z "$DEVICE" ]]; then
  DEVICE=$(flutter devices 2>/dev/null | grep "emulator" | awk '{print $4}' | head -1)
fi
if [[ -z "$DEVICE" ]]; then
  echo "ERROR: No device found. Connect Pixel 8 via USB or start an emulator."
  exit 1
fi

echo "Target device : $DEVICE"
echo "Backend       : https://pallybackend-production.up.railway.app"
echo ""

# ── 2. Kill stale Flutter processes ──────────────────────────────────────────
pkill -f "flutter_tools\|flutter run" 2>/dev/null || true
sleep 1

# ── 3. Codegen ────────────────────────────────────────────────────────────────
cd "$SCRIPT_DIR"
dart run build_runner build --delete-conflicting-outputs 2>&1 | tail -3

# ── 4. Launch ─────────────────────────────────────────────────────────────────
echo ""
echo "─────────────────────────────────────────────────"
echo "  Starting Pally Flutter"
echo "  Device : $DEVICE"
echo "─────────────────────────────────────────────────"
echo ""

flutter run \
  -d "$DEVICE" \
  --no-pub \
  2>&1 | tee /tmp/flutter_run.log
