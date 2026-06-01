#!/usr/bin/env bash
# Pally backend contract smoke test.
# Verifies required Dart model fields are present & non-null in every live response.
# Usage: BASE_URL="https://..." TOKEN="eyJ..." bash /tmp/pally-smoke-test.sh
set -uo pipefail

BASE_URL="${BASE_URL:-https://pallybackend-production.up.railway.app}"
TOKEN="${TOKEN:-}"
PASS=0; FAIL=0
AUTH=(-H "Authorization: Bearer ${TOKEN}" -H "Accept: application/json")

unwrap() { jq 'if type=="object" and has("data") then .data else . end'; }

check_fields() {
  local label="$1" path="$2" pick="$3"; shift 3
  local body http
  body="$(curl -sf "${AUTH[@]}" -w $'\n%{http_code}' "${BASE_URL}${path}" 2>/dev/null)"
  http="$(tail -n1 <<<"$body")"; body="$(sed '$d' <<<"$body")"
  if [[ "$http" != "200" ]]; then
    printf '  \033[31mFAIL\033[0m %-40s HTTP %s\n' "$label" "$http"; FAIL=$((FAIL + 1)); return
  fi
  local unwrapped; unwrapped="$(unwrap <<<"$body")"
  local objs; objs="$(jq -c "$pick" <<<"$unwrapped" 2>/dev/null)"
  if [[ -z "$objs" || "$objs" == "null" ]]; then
    printf '  \033[33mSKIP\033[0m %-40s (no rows or shape unexpected)\n' "$label"; return
  fi
  local missing=""
  for fld in "$@"; do
    local bad; bad="$(jq -r "$pick | select(has(\"$fld\")|not) // select(.[\"$fld\"]==null) | \"bad\"" <<<"$unwrapped" 2>/dev/null | wc -l | tr -d ' ')"
    [[ "${bad:-0}" -gt 0 ]] && missing+=" $fld"
  done
  if [[ -n "$missing" ]]; then
    printf '  \033[31mFAIL\033[0m %-40s missing/null:%s\n' "$label" "$missing"; FAIL=$((FAIL + 1))
  else
    printf '  \033[32mPASS\033[0m %-40s\n' "$label"; PASS=$((PASS + 1))
  fi
}

echo "== Pally Contract Smoke Test =="
echo "   Base: $BASE_URL"
echo ""

# Health
echo "== Health =="
HTTP=$(curl -so /dev/null -w '%{http_code}' "${BASE_URL}/actuator/health")
[[ "$HTTP" == "200" ]] && { echo "  PASS health"; PASS=$((PASS + 1)); } || { echo "  FAIL health HTTP $HTTP"; FAIL=$((FAIL + 1)); }

if [[ -z "$TOKEN" ]]; then
  echo ""
  echo "  TOKEN not set — skipping authenticated endpoint checks."
  echo "  Set TOKEN=<jwt> to run full contract checks."
  echo ""
  echo "== RESULT:  ${PASS} pass  /  ${FAIL} fail =="
  exit $([[ "$FAIL" -eq 0 ]] && echo 0 || echo 1)
fi

# Resolve an avatar
AV_JSON="$(curl -sf "${AUTH[@]}" "${BASE_URL}/api/v1/avatars" 2>/dev/null)"
AVATAR_ID="$(unwrap <<<"$AV_JSON" | jq -r 'if type=="array" then .[0].id else (.avatars[0].id // .[0].id // empty) end' 2>/dev/null)"
echo "   avatarId=${AVATAR_ID:-<none — create one first>}"
A="/api/v1/avatars/${AVATAR_ID}"

echo ""
echo "== Auth / subscription =="
check_fields "auth/me"                  "/api/v1/auth/me"            '.'           id
check_fields "subscription/entitlement" "/api/v1/subscription/entitlement" '.'    isPremium source

echo ""
echo "== Avatars =="
check_fields "avatars (list)"           "/api/v1/avatars"            '.[]?'        id name
if [[ -n "$AVATAR_ID" ]]; then
  check_fields "avatar (single)"        "$A"                         '.'           id name
  echo ""
  echo "== Chat =="
  check_fields "chat/history avatarId"  "$A/chat/history"            '.[]?'        id avatarId content role
  check_fields "chat/history sources"   "$A/chat/history"            '.[]?'        sources
  echo ""
  echo "== Knowledge =="
  check_fields "wiki/pages"             "$A/wiki/pages"              '.pages[]? // .[]?' id title
  echo ""
  echo "== Quiz / flashcards =="
  check_fields "flashcards"             "$A/flashcards"              '.[]? // .flashcards[]?' id front back
  check_fields "quiz/daily"             "$A/quiz/daily"              '.questions[]? // .[]?'  id question
fi

echo ""
echo "== Progress =="
check_fields "progress"                 "/api/v1/progress"           '.'           level xp
check_fields "progress/streak"          "/api/v1/progress/streak"    '.'           streakDays
check_fields "achievements"             "/api/v1/achievements"       '.achievements[]? // .[]?' id name category rarity

echo ""
echo "== Misc =="
check_fields "shop/stars"               "/api/v1/shop/stars"         '.'
check_fields "usage/today"              "/api/v1/usage/today"        '.'

echo ""
echo "== RESULT:  ${PASS} pass  /  ${FAIL} fail =="
[[ "$FAIL" -eq 0 ]] || exit 1
