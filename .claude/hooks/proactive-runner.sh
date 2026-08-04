#!/bin/bash
# bOS Layer 3 — Proactive Runner
# Runs periodically via launchd/cron. Checks for triggers and sends notifications.
# Does NOT require claude -p (uses shell + ntfy for speed and reliability).
# If claude -p becomes stable → upgrade to full AI proactive-check.

set -uo pipefail
# NOTE: no -e because grep -c returns exit 1 on zero matches, which would kill the script

BOS_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/proactive-$(date '+%Y%m%d').log"
SECRETS_FILE="$BOS_DIR/.secrets/ntfy.env"
TODAY=$(date '+%Y-%m-%d')
HOUR=$(date '+%H')
NOW=$(date '+%Y-%m-%d %H:%M')

mkdir -p "$LOG_DIR"

log() { echo "[$NOW] $*" >> "$LOG_FILE"; }

# ── Load ntfy topic ─────────────────────────────────────────
NTFY_TOPIC=""
if [ -f "$SECRETS_FILE" ]; then
  NTFY_TOPIC=$(grep 'NTFY_TOPIC=' "$SECRETS_FILE" 2>/dev/null | head -1 | sed 's/NTFY_TOPIC=//' | tr -d ' \r\n"')
fi

send_ntfy() {
  local title="$1"
  local body="$2"
  local priority="${3:-default}"
  local tags="${4:-robot}"

  if [ -n "$NTFY_TOPIC" ]; then
    curl -s -o /dev/null \
      -H "Title: $title" \
      -H "Priority: $priority" \
      -H "Tags: $tags" \
      -d "$body" \
      "https://ntfy.sh/$NTFY_TOPIC" 2>/dev/null || true
    log "SENT: $title"
  else
    log "SKIP (no ntfy topic): $title"
  fi
}

# ── Trigger Checks ──────────────────────────────────────────
ALERTS=""

# 1. Overdue tasks
if [ -f "$BOS_DIR/state/tasks.md" ]; then
  OVERDUE=$(grep -c '☐.*overdue\|OVERDUE' "$BOS_DIR/state/tasks.md" 2>/dev/null || echo "0")
  # Also check for tasks from >3 days ago still unchecked
  STALE_TASKS=$(grep '^| ☐\|^| ◻' "$BOS_DIR/state/tasks.md" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$STALE_TASKS" -gt 10 ] 2>/dev/null; then
    ALERTS="${ALERTS}tasks:${STALE_TASKS} open tasks|"
    log "TRIGGER: $STALE_TASKS open tasks"
  fi
fi

# 2. Energy gap (no daily-log entry in 3+ days — avoids alert fatigue for irregular loggers)
if [ "$HOUR" -ge 14 ] && [ -f "$BOS_DIR/state/daily-log.md" ]; then
  # Get most recent entry from Active section (newest-first table)
  LAST_LOG_DATE=$(grep '^| 20' "$BOS_DIR/state/daily-log.md" 2>/dev/null | head -1 | grep -o '20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]' | head -1)
  if [ -n "$LAST_LOG_DATE" ] && date -j -f "%Y-%m-%d" "$LAST_LOG_DATE" "+%s" >/dev/null 2>&1; then
    LAST_SEC=$(date -j -f "%Y-%m-%d" "$LAST_LOG_DATE" "+%s")
    NOW_SEC=$(date "+%s")
    LOG_GAP_DAYS=$(( (NOW_SEC - LAST_SEC) / 86400 ))
    if [ "$LOG_GAP_DAYS" -ge 3 ] 2>/dev/null; then
      ALERTS="${ALERTS}energy:no log for ${LOG_GAP_DAYS}d|"
      log "TRIGGER: no daily-log entry for ${LOG_GAP_DAYS} days"
    fi
  fi
fi

# 3. Habit streaks at risk (evening check)
if [ "$HOUR" -ge 18 ] && [ -f "$BOS_DIR/state/habits.md" ]; then
  # Check if any habit with streak >3 not logged today
  HABITS_TODAY=$(grep -c "$TODAY" "$BOS_DIR/state/habits.md" 2>/dev/null || echo "0")
  ACTIVE_HABITS=$(grep -c '🔥\|streak' "$BOS_DIR/state/habits.md" 2>/dev/null || echo "0")
  if [ "$ACTIVE_HABITS" -gt 0 ] && [ "$HABITS_TODAY" -eq 0 ] 2>/dev/null; then
    ALERTS="${ALERTS}habits:streaks at risk|"
    log "TRIGGER: habit streaks at risk"
  fi
fi

# 4. Friday review nudge
DOW=$(date '+%u')
if [ "$DOW" -eq 5 ] && [ "$HOUR" -ge 16 ]; then
  if [ -f "$BOS_DIR/state/weekly-log.md" ]; then
    THIS_WEEK=$(grep -c "$TODAY" "$BOS_DIR/state/weekly-log.md" 2>/dev/null || echo "0")
    if [ "$THIS_WEEK" -eq 0 ] 2>/dev/null; then
      ALERTS="${ALERTS}review:Friday, no weekly review|"
      log "TRIGGER: Friday weekly review missing"
    fi
  fi
fi

# 5. Context-bus critical signals (only pending ones, not already acted-on)
if [ -f "$BOS_DIR/state/context-bus.md" ]; then
  # Count entries that are both critical AND still pending (grep multiline proximity)
  CRITICAL_PENDING=$(awk '/Priority: critical/{found=1} found && /Status: pending/{count++; found=0} /^$/{found=0} END{print count+0}' "$BOS_DIR/state/context-bus.md" 2>/dev/null)
  if [ "$CRITICAL_PENDING" -gt 0 ] 2>/dev/null; then
    ALERTS="${ALERTS}bus:${CRITICAL_PENDING} critical pending signals|"
    log "TRIGGER: $CRITICAL_PENDING critical pending bus signals"
  fi
fi

# ── Send consolidated notification ───────────────────────────
if [ -n "$ALERTS" ]; then
  # Count alerts
  ALERT_COUNT=$(echo "$ALERTS" | tr '|' '\n' | grep -c '.' || echo "0")

  # Build message
  MSG=""
  MSG=""
  echo "$ALERTS" | tr '|' '\n' | while IFS= read -r alert; do
    [ -n "$alert" ] && MSG="${MSG}• ${alert}\n"
  done

  send_ntfy "bOS: ${ALERT_COUNT} items need attention" "$(echo -e "$MSG")" "default" "robot,bell"
else
  log "No triggers fired. All quiet."
fi

log "Proactive check complete."

# ── Log rotation (keep last 14 days) ─────────────────────────
find "$LOG_DIR" -name "proactive-*.log" -mtime +14 -delete 2>/dev/null || true
