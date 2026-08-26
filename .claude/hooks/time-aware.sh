#!/bin/bash
# bOS Time-Aware Context Injection v2
# Runs on UserPromptSubmit — BEFORE every user message.
# KEY ASSUMPTION: Sessions span multiple days. User does NOT close sessions.
# Detection is based on LAST MESSAGE TIMESTAMP, not session boundaries.
# stdout → Claude sees as system context.

BOS_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=ping-inject.sh
. "$BOS_DIR/.claude/hooks/ping-inject.sh"
HOUR=$(date '+%H')
HOUR_NUM=$((10#$HOUR))  # force decimal (strip leading 0)
DAY=$(date '+%u')  # 1=Monday, 7=Sunday
TODAY=$(date '+%Y-%m-%d')
NOW_SEC=$(date '+%s')
TIME_DISPLAY=$(date '+%H:%M')

# ─── Track last message (core of v2 — replaces session-boundary detection) ───
LAST_MSG_FILE="$BOS_DIR/state/.last-message"
LAST_MSG_DATE=""
LAST_MSG_HOUR=""
LAST_MSG_SEC=0
HOURS_SINCE_LAST=0

if [ -f "$LAST_MSG_FILE" ]; then
  LAST_MSG_TS=$(cat "$LAST_MSG_FILE" 2>/dev/null)
  LAST_MSG_DATE=$(echo "$LAST_MSG_TS" | cut -d' ' -f1)
  LAST_MSG_HOUR=$(echo "$LAST_MSG_TS" | cut -d' ' -f2 | cut -d: -f1)
  if [ -n "$LAST_MSG_DATE" ]; then
    # macOS date -j, GNU date -d fallback
    LAST_MSG_SEC=$(date -j -f "%Y-%m-%d %H:%M" "$LAST_MSG_TS" "+%s" 2>/dev/null || date -d "$LAST_MSG_TS" "+%s" 2>/dev/null)
    [ -n "$LAST_MSG_SEC" ] && HOURS_SINCE_LAST=$(( (NOW_SEC - LAST_MSG_SEC) / 3600 ))
  fi
fi

# Update last message timestamp (ALWAYS, at every message)
echo "$TODAY $TIME_DISPLAY" > "$LAST_MSG_FILE"

# ─── Determine time block (neutral clock, not a personal rhythm) ───
# A user's own peak hours belong in profile.md, not hardcoded here.
if [ "$HOUR_NUM" -ge 6 ] && [ "$HOUR_NUM" -lt 12 ]; then
  TIME_BLOCK="MORNING"
elif [ "$HOUR_NUM" -ge 12 ] && [ "$HOUR_NUM" -lt 18 ]; then
  TIME_BLOCK="AFTERNOON"
elif [ "$HOUR_NUM" -ge 18 ] && [ "$HOUR_NUM" -lt 22 ]; then
  TIME_BLOCK="EVENING"
else
  TIME_BLOCK="NIGHT"
fi

# ─── Day transition detection (replaces session-based first_today) ───
# "First today" = last message was on a different day (regardless of session state)
FIRST_TODAY="false"
if [ -z "$LAST_MSG_DATE" ] || [ "$LAST_MSG_DATE" != "$TODAY" ]; then
  FIRST_TODAY="true"
fi

# ─── Time block transition detection ───
# Detects when user crosses into a new time block since last message
# Used for smart nudges: morning→/morning, evening→/evening
BLOCK_CHANGED="false"
if [ -n "$LAST_MSG_HOUR" ]; then
  LAST_HOUR_NUM=$((10#$LAST_MSG_HOUR))
  # Determine last message's time block
  if [ "$LAST_HOUR_NUM" -ge 6 ] && [ "$LAST_HOUR_NUM" -lt 12 ]; then
    LAST_BLOCK="MORNING"
  elif [ "$LAST_HOUR_NUM" -ge 12 ] && [ "$LAST_HOUR_NUM" -lt 18 ]; then
    LAST_BLOCK="AFTERNOON"
  elif [ "$LAST_HOUR_NUM" -ge 18 ] && [ "$LAST_HOUR_NUM" -lt 22 ]; then
    LAST_BLOCK="EVENING"
  else
    LAST_BLOCK="NIGHT"
  fi
  [ "$LAST_BLOCK" != "$TIME_BLOCK" ] && BLOCK_CHANGED="true"
fi

# ─── Output context ───
echo "<bos-time-context>"
# Circadian mode based on time block
case "$TIME_BLOCK" in
  MORNING)  MODE="STRATEGIST — plan, decide, set priorities" ;;
  AFTERNOON) MODE="EXECUTOR — deep work, build, ship" ;;
  EVENING)  MODE="MAINTAINER — review, log, wind down" ;;
  NIGHT)    MODE="MINIMAL — short responses, defer to tomorrow" ;;
esac
echo "time: $TIME_DISPLAY | block: $TIME_BLOCK | mode: $MODE | day: $DAY | first_today: $FIRST_TODAY"
[ "$HOURS_SINCE_LAST" -gt 0 ] && echo "last_message: ${HOURS_SINCE_LAST}h ago (${LAST_MSG_DATE} ${LAST_MSG_HOUR}:xx)"
[ "$BLOCK_CHANGED" = "true" ] && echo "block_transition: $LAST_BLOCK → $TIME_BLOCK"

# ═══════════════════════════════════════════════════════════════
# DIRECTIVES — deliberately minimal
# ═══════════════════════════════════════════════════════════════
# bOS does not interrogate. The hook carries the working mode and nothing
# else: no energy questions, no ritual offers, no repeating nudges. Energy
# and expenses are captured AMBIENTLY from what the user actually says.
# /morning, /evening and /reflect run ONLY when the user asks for them.

# ─── Late-hour production gate ───
# After 22:00 a mutation to anything live gets a dry-run and a rollback plan
# stated in three lines BEFORE it is executed.
if [ "$TIME_BLOCK" = "NIGHT" ]; then
  echo "directive: LATE-HOUR-GATE"
  echo "instruction: Late hour. Before mutating anything live (deploy, migration, mass update, send), state the dry-run and the rollback plan in 3 lines and get a go-ahead."
fi

# ─── Data gap (informational only — never a question) ───
if [ -f "$BOS_DIR/state/daily-log.md" ]; then
  LAST_LOG_DATE=$(grep '^| 20' "$BOS_DIR/state/daily-log.md" 2>/dev/null | head -1 | grep -o '20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]' | head -1)
  LAST_SEC=""
  if [ -n "$LAST_LOG_DATE" ]; then
    LAST_SEC=$(date -j -f "%Y-%m-%d" "$LAST_LOG_DATE" "+%s" 2>/dev/null || date -d "$LAST_LOG_DATE" "+%s" 2>/dev/null)
  fi
  if [ -n "$LAST_SEC" ]; then
    LOG_GAP=$(( (NOW_SEC - LAST_SEC) / 86400 ))
    [ "$LOG_GAP" -ge 5 ] && echo "note: daily-log has a ${LOG_GAP}-day gap (context only — do NOT ask the user about it)"
  fi
fi

echo "</bos-time-context>"
_bos_inject_ping
exit 0
