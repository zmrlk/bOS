#!/usr/bin/env zsh
# ============================================================
# bOS — Evening Nudge (daily 20:00)
# Sends ntfy push reminding user to run /evening
# Also silently updates state/projects.md timestamps
# ============================================================

set -euo pipefail

BOS_DIR="${BOS_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/evening-nudge-$(date '+%Y%m%d').log"
SECRETS_FILE="$BOS_DIR/.secrets/ntfy.env"
NTFY_BASE_URL="${NTFY_BASE_URL:-https://ntfy.sh}"

mkdir -p "$LOG_DIR"
exec >> "$LOG_FILE" 2>&1
echo "[evening-nudge] $(date '+%H:%M:%S') START"

# ── Idempotency ────────────────────────────────────────────
SENT_FILE="$LOG_DIR/.evening-nudge-last-date"
TODAY=$(date '+%Y-%m-%d')
if [[ -f "$SENT_FILE" ]] && [[ "$(cat "$SENT_FILE" 2>/dev/null)" == "$TODAY" ]]; then
  echo "[evening-nudge] Already sent today. Skipping."
  exit 0
fi

# ── Load ntfy topic ─────────────────────────────────────────
NTFY_TOPIC="${NTFY_TOPIC:-}"
[[ -z "$NTFY_TOPIC" && -f "$SECRETS_FILE" ]] && source "$SECRETS_FILE" 2>/dev/null || true
[[ -z "$NTFY_TOPIC" ]] && { echo "[evening-nudge] ERROR: NTFY_TOPIC not set"; exit 1; }

# ── Build message ───────────────────────────────────────────
# Check if daily-log already has PM energy for today
HAS_PM=""
if [[ -f "$BOS_DIR/state/daily-log.md" ]]; then
  TODAY_ROW=$(grep "$TODAY" "$BOS_DIR/state/daily-log.md" 2>/dev/null | head -1)
  if [[ -n "$TODAY_ROW" ]]; then
    # Check if PM energy column (3rd pipe-separated value) is filled
    PM_VAL=$(echo "$TODAY_ROW" | awk -F'|' '{print $4}' | tr -d ' ')
    if [[ -n "$PM_VAL" && "$PM_VAL" != "—" && "$PM_VAL" != "-" ]]; then
      HAS_PM="yes"
    fi
  fi
fi

if [[ "$HAS_PM" == "yes" ]]; then
  echo "[evening-nudge] PM energy already logged. Skipping nudge."
  echo "$TODAY" > "$SENT_FILE"
  exit 0
fi

# ── Send notification ───────────────────────────────────────
MSG="Czas na /evening — zaloguj energię i zamknij dzień."

# Add project count if available
if [[ -f "$BOS_DIR/state/projects.md" ]]; then
  # Read project count from Summary section (line: | Active projects | N |)
  PROJ_COUNT=$(grep 'Active projects' "$BOS_DIR/state/projects.md" 2>/dev/null | grep -oE '[0-9]+' | head -1)
  if [[ -n "$PROJ_COUNT" && "$PROJ_COUNT" -gt 0 ]]; then
    MSG="$MSG $PROJ_COUNT aktywnych projektów."
  fi
fi

CURL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Title: 🌙 bOS Evening" \
  -H "Priority: default" \
  -H "Tags: moon,clipboard" \
  -d "$MSG" \
  "$NTFY_BASE_URL/$NTFY_TOPIC" 2>&1) || CURL_STATUS="ERR"

if [[ "$CURL_STATUS" == "200" ]]; then
  echo "[evening-nudge] Push sent OK"
  echo "$TODAY" > "$SENT_FILE"
else
  echo "[evening-nudge] ERROR: HTTP $CURL_STATUS"
fi

echo "[evening-nudge] $(date '+%H:%M:%S') DONE"
