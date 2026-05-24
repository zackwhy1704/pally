#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Pally Flutter — canonical run script
# Usage:
#   ./start.sh          local backend (http://10.0.2.2:8080)
#   ./start.sh --prod   Railway backend (set RAILWAY_URL in .env or env var)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 0. Load .env if present ──────────────────────────────────────────────────
if [[ -f "$SCRIPT_DIR/.env" ]]; then
  set -a; source "$SCRIPT_DIR/.env"; set +a
fi

# ── 1. Determine backend URL ──────────────────────────────────────────────────
USE_PROD=false
for arg in "$@"; do [[ "$arg" == "--prod" ]] && USE_PROD=true; done

if $USE_PROD; then
  if [[ -z "${RAILWAY_URL:-}" ]]; then
    echo "ERROR: RAILWAY_URL not set."
    echo "  Add to pally/.env:  RAILWAY_URL=https://your-app.railway.app"
    exit 1
  fi
  API_URL="$RAILWAY_URL"
  echo "Mode: PRODUCTION (Railway)"
  # No local health check needed for prod
else
  API_URL="${LOCAL_URL:-http://10.0.2.2:8080}"
  echo "Mode: LOCAL"
  if ! curl -sf http://localhost:8080/actuator/health 2>/dev/null | grep -q '"status":"UP"'; then
    echo "ERROR: Backend is not running on port 8080."
    echo "  Start it first:  cd ../pally-backend && ./start.sh"
    exit 1
  fi
  echo "Backend UP on port 8080 ✓"
fi

# ── 2. Find emulator ──────────────────────────────────────────────────────────
DEVICE=$(flutter devices 2>/dev/null | grep "emulator" | awk '{print $4}' | head -1)
if [[ -z "$DEVICE" ]]; then
  echo "No emulator found. Start one in Android Studio or run:"
  echo "  flutter emulators --launch <emulator-id>"
  exit 1
fi
echo "Target device : $DEVICE ✓"
echo "API URL       : $API_URL"
echo ""

# ── 3. Kill stale Flutter processes ──────────────────────────────────────────
pkill -f "flutter_tools\|flutter run" 2>/dev/null || true
sleep 1

# ── 4. Codegen ────────────────────────────────────────────────────────────────
cd "$SCRIPT_DIR"
dart run build_runner build --delete-conflicting-outputs 2>&1 | tail -3

# ── 5. Launch ─────────────────────────────────────────────────────────────────
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
