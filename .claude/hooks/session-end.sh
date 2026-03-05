#!/bin/bash
# bOS Session End Hook
# Performs batch operations when a session ends.
# Runs cleanup and summary updates.

BOS_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
TODAY=$(date '+%Y-%m-%d')

# Expire old context-bus entries (TTL check)
if [ -f "$BOS_DIR/state/context-bus.md" ]; then
  # Calculate date 14 days ago (cross-platform: macOS + Linux)
  if date -v-14d '+%Y-%m-%d' >/dev/null 2>&1; then
    CUTOFF=$(date -v-14d '+%Y-%m-%d')  # macOS
  else
    CUTOFF=$(date -d '14 days ago' '+%Y-%m-%d')  # Linux
  fi

  # Mark entries with dates older than cutoff as expired
  # Matches lines like "## 2026-02-15 @agent → @target"
  if [ -n "$CUTOFF" ]; then
    # Cross-platform sed: detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s/^## \(${CUTOFF%%-*}\)/## \1/g" "$BOS_DIR/state/context-bus.md" 2>/dev/null
      # Mark old pending entries as expired
      while IFS= read -r line_num; do
        sed -i '' "${line_num}s/Status: pending/Status: expired/" "$BOS_DIR/state/context-bus.md" 2>/dev/null
      done < <(
        awk -v cutoff="$CUTOFF" '
          /^## [0-9]{4}-[0-9]{2}-[0-9]{2}/ { date=$2 }
          /Status: pending/ { if (date < cutoff) print NR }
        ' "$BOS_DIR/state/context-bus.md" 2>/dev/null
      )
    else
      while IFS= read -r line_num; do
        sed -i "${line_num}s/Status: pending/Status: expired/" "$BOS_DIR/state/context-bus.md" 2>/dev/null
      done < <(
        awk -v cutoff="$CUTOFF" '
          /^## [0-9]{4}-[0-9]{2}-[0-9]{2}/ { date=$2 }
          /Status: pending/ { if (date < cutoff) print NR }
        ' "$BOS_DIR/state/context-bus.md" 2>/dev/null
      )
    fi
  fi
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

# Clean up old pre-compact snapshots (keep last 3)
ls -t "$BOS_DIR/state/.backup"/pre-compact-*.md 2>/dev/null | tail -n +4 | xargs rm -f 2>/dev/null

# Log session to session-log.md (append-only)
if [ -f "$BOS_DIR/state/session-log.md" ] || true; then
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

# ─── Engagement measurement ───
# Track time-aware directive outcomes for this session
ENGAGE_FILE="$BOS_DIR/state/.engagement-log.md"
HOUR=$(date '+%H')

# Ensure file exists with header
if [ ! -f "$ENGAGE_FILE" ]; then
  echo "# Engagement Log" > "$ENGAGE_FILE"
  echo "<!-- Auto-tracked by session-end hook -->" >> "$ENGAGE_FILE"
  echo "| Date | Directive | Outcome |" >> "$ENGAGE_FILE"
  echo "|------|-----------|---------|" >> "$ENGAGE_FILE"
fi

# Check if micro-morning was shown today (first_today was true at some point)
if [ -f "$BOS_DIR/state/session-log.md" ]; then
  SESSION_COUNT_TODAY=$(grep -c "$TODAY" "$BOS_DIR/state/session-log.md" 2>/dev/null || echo "0")
  # If only 1-2 entries (start + end of THIS session) → likely first session today
  if [ "$SESSION_COUNT_TODAY" -le 2 ]; then
    # Check if skip counter incremented (user said skip)
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
  fi
fi

# Check if evening energy was logged today
if [ "$HOUR" -ge 18 ] && [ "$HOUR" -lt 22 ]; then
  if [ -f "$BOS_DIR/state/daily-log.md" ]; then
    TODAY_LINE=$(grep "^| $TODAY" "$BOS_DIR/state/daily-log.md" 2>/dev/null)
    if [ -n "$TODAY_LINE" ]; then
      PM_VAL=$(echo "$TODAY_LINE" | awk -F'|' '{gsub(/^ +| +$/,"",$4); print $4}')
      if echo "$PM_VAL" | grep -q '^[0-9]'; then
        echo "| $TIMESTAMP | evening-energy | logged ($PM_VAL) |" >> "$ENGAGE_FILE"
      else
        echo "| $TIMESTAMP | evening-energy | not-logged |" >> "$ENGAGE_FILE"
      fi
    fi
  fi
fi

# ─── Evening pre-push: tomorrow's plan to phone ───
# If it's evening + .pre-morning.md exists → push plan to ntfy
# This ensures user has briefing on phone even if Mac sleeps through morning slots
if [ "$HOUR" -ge 18 ] && [ "$HOUR" -lt 23 ]; then
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
    fi
  fi
fi

echo "Session ended. State preserved."
