#!/bin/bash
# bOS Session End Hook
# Performs batch operations when a session ends.
# Runs cleanup and summary updates.

# Hook profiling: BOS_HOOK_PROFILE=minimal|standard|strict (default: standard)
HOOK_PROFILE="${BOS_HOOK_PROFILE:-standard}"

BOS_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
TODAY=$(date '+%Y-%m-%d')

# ─── Clean crash buffer on clean exit (ISI-10) ───
rm -f "$BOS_DIR/state/.working.md"

# Expire context-bus entries past their TTL
# BUG FIX: was comparing CREATION date vs 14-day cutoff — now compares TTL date vs TODAY
if [ -f "$BOS_DIR/state/context-bus.md" ]; then
  # Write awk script to temp file (avoids macOS awk escaping issues with !=)
  AWK_EXPIRE=$(mktemp)
  cat > "$AWK_EXPIRE" << 'AWKEOF'
/^TTL:/ { gsub(/TTL: */, ""); ttl=$0 }
/Status: pending/ {
  if (ttl > "" && ttl < today) print NR
  ttl=""
}
AWKEOF

  if [[ "$OSTYPE" == "darwin"* ]]; then
    while IFS= read -r line_num; do
      sed -i '' "${line_num}s/Status: pending/Status: expired/" "$BOS_DIR/state/context-bus.md" 2>/dev/null
    done < <(awk -v today="$TODAY" -f "$AWK_EXPIRE" "$BOS_DIR/state/context-bus.md" 2>/dev/null)
  else
    while IFS= read -r line_num; do
      sed -i "${line_num}s/Status: pending/Status: expired/" "$BOS_DIR/state/context-bus.md" 2>/dev/null
    done < <(awk -v today="$TODAY" -f "$AWK_EXPIRE" "$BOS_DIR/state/context-bus.md" 2>/dev/null)
  fi
  rm -f "$AWK_EXPIRE" 2>/dev/null
fi

# Update telemetry session count (cross-platform)
if [ -f "$BOS_DIR/state/telemetry.md" ]; then
  SESSIONS=$(grep -o 'Sessions: [0-9]*' "$BOS_DIR/state/telemetry.md" 2>/dev/null | grep -o '[0-9]*')
  if [ -n "$SESSIONS" ]; then
    NEW_COUNT=$((SESSIONS + 1))
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s/Sessions: $SESSIONS/Sessions: $NEW_COUNT/" "$BOS_DIR/state/telemetry.md" 2>/dev/null
    else
      sed -i "s/Sessions: $SESSIONS/Sessions: $NEW_COUNT/" "$BOS_DIR/state/telemetry.md" 2>/dev/null
    fi
  fi
fi

# Ensure state directory structure exists
mkdir -p "$BOS_DIR/state/.backup"
mkdir -p "$BOS_DIR/state/archive"

# Clean up old pre-compact snapshots (keep last 5, aligned with pre-compact.sh)
ls -t "$BOS_DIR/state/.backup"/pre-compact-*.md 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null

# Log session to session-log.md (deduplicated — max 1 entry per hour)
CURRENT_HOUR=$(date '+%Y-%m-%d %H')
LAST_LOG_HOUR=""
if [ -f "$BOS_DIR/state/session-log.md" ]; then
  LAST_LOG_LINE=$(tail -1 "$BOS_DIR/state/session-log.md" 2>/dev/null)
  LAST_LOG_HOUR=$(echo "$LAST_LOG_LINE" | grep -o '20[0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]' 2>/dev/null)
fi
if [ "$CURRENT_HOUR" != "$LAST_LOG_HOUR" ]; then
  echo "| $TIMESTAMP | session-end | hook |" >> "$BOS_DIR/state/session-log.md" 2>/dev/null
fi

# Clean up stale .pre-morning.md (older than 2 days)
if [ -f "$BOS_DIR/state/.pre-morning.md" ]; then
  PRE_MORNING_DATE=$(grep '^Date:' "$BOS_DIR/state/.pre-morning.md" 2>/dev/null | head -1 | sed 's/Date: //')
  if [ -n "$PRE_MORNING_DATE" ]; then
    if date -v-2d '+%Y-%m-%d' >/dev/null 2>&1; then
      STALE_CUTOFF=$(date -v-2d '+%Y-%m-%d')  # macOS
    else
      STALE_CUTOFF=$(date -d '2 days ago' '+%Y-%m-%d')  # Linux
    fi
    if [ -n "$STALE_CUTOFF" ] && [ "$PRE_MORNING_DATE" \< "$STALE_CUTOFF" ]; then
      rm -f "$BOS_DIR/state/.pre-morning.md" 2>/dev/null
    fi
  fi
fi

# ─── Engagement measurement (skip in minimal mode) ───
# Track time-aware directive outcomes for this session
if [ "$HOOK_PROFILE" = "minimal" ]; then
  echo "Session ended. State preserved. (minimal mode — engagement skipped)"
  exit 0
fi
ENGAGE_FILE="$BOS_DIR/state/.engagement-log.md"
HOUR=$(date '+%H')

# Ensure file exists with header
if [ ! -f "$ENGAGE_FILE" ]; then
  echo "# Engagement Log" > "$ENGAGE_FILE"
  echo "<!-- Auto-tracked by session-end hook -->" >> "$ENGAGE_FILE"
  echo "| Date | Directive | Outcome |" >> "$ENGAGE_FILE"
  echo "|------|-----------|---------|" >> "$ENGAGE_FILE"
fi

# Check if micro-morning was shown today (uses marker file, not session-log grep)
# DEDUP: only log once per day per directive (not per session-close)
ENGAGE_TODAY_FILE="$BOS_DIR/state/.engage-logged-today"
ENGAGE_LOGGED_TODAY=""
[ -f "$ENGAGE_TODAY_FILE" ] && ENGAGE_LOGGED_TODAY=$(cat "$ENGAGE_TODAY_FILE" 2>/dev/null)

MICRO_MORNING_FILE="$BOS_DIR/state/.micro-morning-done"
if [ -f "$MICRO_MORNING_FILE" ] && [ "$(cat "$MICRO_MORNING_FILE" 2>/dev/null)" = "$TODAY" ]; then
  # Only log once per day
  if ! echo "$ENGAGE_LOGGED_TODAY" | grep -q "micro-morning"; then
    if [ -f "$BOS_DIR/state/.micro-morning-skips" ]; then
      SKIP_COUNT=$(head -1 "$BOS_DIR/state/.micro-morning-skips" 2>/dev/null || echo "0")
      if [ "$SKIP_COUNT" -gt 0 ] 2>/dev/null; then
        echo "| $TIMESTAMP | micro-morning | skipped ($SKIP_COUNT) |" >> "$ENGAGE_FILE"
      else
        echo "| $TIMESTAMP | micro-morning | shown |" >> "$ENGAGE_FILE"
      fi
    else
      echo "| $TIMESTAMP | micro-morning | shown |" >> "$ENGAGE_FILE"
    fi
    echo "${ENGAGE_LOGGED_TODAY}micro-morning," > "$ENGAGE_TODAY_FILE"
    ENGAGE_LOGGED_TODAY=$(cat "$ENGAGE_TODAY_FILE" 2>/dev/null)
  fi
fi

# Check if evening energy was logged today (dedup: once per day)
if [ "$HOUR" -ge 18 ] && [ "$HOUR" -lt 22 ]; then
  if ! echo "$ENGAGE_LOGGED_TODAY" | grep -q "evening-energy"; then
    if [ -f "$BOS_DIR/state/daily-log.md" ]; then
      TODAY_LINE=$(grep "^| $TODAY" "$BOS_DIR/state/daily-log.md" 2>/dev/null)
      if [ -n "$TODAY_LINE" ]; then
        PM_VAL=$(echo "$TODAY_LINE" | awk -F'|' '{gsub(/^ +| +$/,"",$4); print $4}')
        if echo "$PM_VAL" | grep -q '^[0-9]'; then
          echo "| $TIMESTAMP | evening-energy | logged ($PM_VAL) |" >> "$ENGAGE_FILE"
        else
          echo "| $TIMESTAMP | evening-energy | not-logged |" >> "$ENGAGE_FILE"
        fi
        echo "${ENGAGE_LOGGED_TODAY}evening-energy," > "$ENGAGE_TODAY_FILE"
      fi
    fi
  fi
fi

# ─── Evening pre-push: tomorrow's plan to phone ───
# If it's evening + .pre-morning.md exists → push plan to ntfy
# This ensures user has briefing on phone even if Mac sleeps through morning slots
# IDEMPOTENCY: max 1 evening push per day (sessions close multiple times)
EVENING_SENT_FILE="$HOME/.claude/logs/.evening-push-last-date"
if [ "$HOUR" -ge 18 ] && [ "$HOUR" -lt 23 ]; then
  # Skip if already pushed today
  if [ -f "$EVENING_SENT_FILE" ] && [ "$(cat "$EVENING_SENT_FILE" 2>/dev/null)" = "$TODAY" ]; then
    true  # already sent today, skip silently
  else
    PRE_MORNING="$BOS_DIR/state/.pre-morning.md"
    SECRETS_FILE="$BOS_DIR/.secrets/ntfy.env"
    NTFY_TOPIC=""

    # Load topic
    if [ -f "$SECRETS_FILE" ]; then
      NTFY_TOPIC=$(grep 'NTFY_TOPIC=' "$SECRETS_FILE" 2>/dev/null | head -1 | sed 's/NTFY_TOPIC=//' | tr -d ' \r\n"')
    fi

    if [ -n "$NTFY_TOPIC" ] && [ -f "$PRE_MORNING" ]; then
      # Extract key info (first 5 non-empty, non-header lines)
      PLAN=$(grep -v '^#\|^$\|^---' "$PRE_MORNING" 2>/dev/null | head -5 | tr '\n' ' ' | cut -c1-250)
      if [ -n "$PLAN" ]; then
        TOMORROW=$(date -v+1d '+%a %d.%m' 2>/dev/null || date -d '+1 day' '+%a %d.%m' 2>/dev/null || echo "jutro")
        curl -s -o /dev/null \
          -H "Title: bOS plan $TOMORROW" \
          -H "Priority: default" \
          -H "Tags: moon,clipboard" \
          -d "$PLAN" \
          "https://ntfy.sh/$NTFY_TOPIC" 2>/dev/null || true
        echo "$TODAY" > "$EVENING_SENT_FILE"
      fi
    fi
  fi
fi

# ─── Session Digest (for /recall cross-session search) ───
# Generate a brief digest of this session for future recall
DIGEST_DIR="$BOS_DIR/state/.backup/session-digests"
mkdir -p "$DIGEST_DIR"
DIGEST_FILE="$DIGEST_DIR/$TODAY-$(date '+%H%M').md"

# Only create if doesn't exist yet (idempotency — sessions close multiple times)
if [ ! -f "$DIGEST_FILE" ]; then
  {
    echo "# Session Digest — $TIMESTAMP"
    echo ""
    # Extract topic from pre-compact snapshot (first meaningful header or summary line)
    LATEST_SNAPSHOT=$(ls -t "$BOS_DIR/state/.backup"/pre-compact-*.md 2>/dev/null | head -1)
    TOPIC=""
    if [ -n "$LATEST_SNAPSHOT" ]; then
      # Try: first ## header that isn't "Context" or "State", then first bullet, then first non-empty line
      TOPIC=$(grep -E -m1 '^## [^(Context|State)]' "$LATEST_SNAPSHOT" 2>/dev/null | head -1 | sed 's/^## //')
      [ -z "$TOPIC" ] && TOPIC=$(grep -E -m1 '^- ' "$LATEST_SNAPSHOT" 2>/dev/null | head -1 | sed 's/^- //')
      [ -z "$TOPIC" ] && TOPIC=$(grep -E -m1 '.{10,}' "$LATEST_SNAPSHOT" 2>/dev/null | head -1)
    fi
    # Fallback: check context-bus for today's entries
    [ -z "$TOPIC" ] && TOPIC=$(grep -E -A1 "## $TODAY" "$BOS_DIR/state/context-bus.md" 2>/dev/null | grep -v "^##" | head -1)
    [ -z "$TOPIC" ] && TOPIC="(no topic extracted)"
    echo "## Topic: $(echo "$TOPIC" | cut -c1-120)"
    echo ""
    echo "## Context"
    if [ -n "$LATEST_SNAPSHOT" ]; then
      echo "<!-- source: pre-compact snapshot -->"
      head -30 "$LATEST_SNAPSHOT" 2>/dev/null
    fi
    echo ""
    echo "## Recent State Changes"
    # Show recent context-bus entries from today
    if [ -f "$BOS_DIR/state/context-bus.md" ]; then
      grep -E -A3 "## $TODAY|## $(date '+%Y-%m')" "$BOS_DIR/state/context-bus.md" 2>/dev/null | head -20
    fi
    echo ""
    echo "## Tasks Modified Today"
    if [ -f "$BOS_DIR/state/tasks.md" ]; then
      grep "$TODAY" "$BOS_DIR/state/tasks.md" 2>/dev/null | head -10
    fi
  } > "$DIGEST_FILE" 2>/dev/null

  # Rotate: keep only last 30 digests
  ls -t "$DIGEST_DIR"/*.md 2>/dev/null | tail -n +31 | xargs rm -f 2>/dev/null
fi

echo "Session ended. State preserved."
