#!/bin/bash
# bOS Time-Aware Context Injection v2
# Runs on UserPromptSubmit — BEFORE every user message.
# KEY ASSUMPTION: Sessions span multiple days. User does NOT close sessions.
# Detection is based on LAST MESSAGE TIMESTAMP, not session boundaries.
# stdout → Claude sees as system context.

BOS_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
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
  if [ -n "$LAST_MSG_DATE" ] && date -j -f "%Y-%m-%d %H:%M" "$LAST_MSG_TS" "+%s" >/dev/null 2>&1; then
    LAST_MSG_SEC=$(date -j -f "%Y-%m-%d %H:%M" "$LAST_MSG_TS" "+%s")
    HOURS_SINCE_LAST=$(( (NOW_SEC - LAST_MSG_SEC) / 3600 ))
  fi
fi

# Update last message timestamp (ALWAYS, at every message)
echo "$TODAY $TIME_DISPLAY" > "$LAST_MSG_FILE"

# ─── Determine time block (adapted to [user]'s profile) ───
# Peak: 11-15 (profile), Sauna: 16-17, Evening: 18-22
if [ "$HOUR_NUM" -ge 6 ] && [ "$HOUR_NUM" -lt 11 ]; then
  TIME_BLOCK="MORNING"
elif [ "$HOUR_NUM" -ge 11 ] && [ "$HOUR_NUM" -lt 15 ]; then
  TIME_BLOCK="PEAK"
elif [ "$HOUR_NUM" -ge 15 ] && [ "$HOUR_NUM" -lt 18 ]; then
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
  if [ "$LAST_HOUR_NUM" -ge 6 ] && [ "$LAST_HOUR_NUM" -lt 11 ]; then
    LAST_BLOCK="MORNING"
  elif [ "$LAST_HOUR_NUM" -ge 11 ] && [ "$LAST_HOUR_NUM" -lt 15 ]; then
    LAST_BLOCK="PEAK"
  elif [ "$LAST_HOUR_NUM" -ge 15 ] && [ "$LAST_HOUR_NUM" -lt 18 ]; then
    LAST_BLOCK="AFTERNOON"
  elif [ "$LAST_HOUR_NUM" -ge 18 ] && [ "$LAST_HOUR_NUM" -lt 22 ]; then
    LAST_BLOCK="EVENING"
  else
    LAST_BLOCK="NIGHT"
  fi
  [ "$LAST_BLOCK" != "$TIME_BLOCK" ] && BLOCK_CHANGED="true"
fi

# ─── Get last energy (format: "AM→PM") ───
LAST_ENERGY=""
if [ -f "$BOS_DIR/state/daily-log.md" ]; then
  LAST_LINE=$(grep "^| 20" "$BOS_DIR/state/daily-log.md" 2>/dev/null | head -1)
  if [ -n "$LAST_LINE" ]; then
    ENERGY_AM=$(echo "$LAST_LINE" | awk -F'|' '{gsub(/^ +| +$/,"",$3); print $3}')
    ENERGY_PM=$(echo "$LAST_LINE" | awk -F'|' '{gsub(/^ +| +$/,"",$4); print $4}')
    LAST_ENERGY="${ENERGY_AM}→${ENERGY_PM}"
  fi
fi

# ─── Get today's task count ───
TASK_COUNT=0
if [ -f "$BOS_DIR/state/tasks.md" ]; then
  TASK_COUNT=$(grep -c '☐' "$BOS_DIR/state/tasks.md" 2>/dev/null || echo "0")
fi

# ─── Check if energy AM/PM logged today ───
ENERGY_AM_TODAY="false"
ENERGY_PM_TODAY="false"
if [ -f "$BOS_DIR/state/daily-log.md" ]; then
  TODAY_LINE=$(grep "^| $TODAY" "$BOS_DIR/state/daily-log.md" 2>/dev/null)
  if [ -n "$TODAY_LINE" ]; then
    AM_VAL=$(echo "$TODAY_LINE" | awk -F'|' '{gsub(/^ +| +$/,"",$3); print $3}')
    PM_VAL=$(echo "$TODAY_LINE" | awk -F'|' '{gsub(/^ +| +$/,"",$4); print $4}')
    echo "$AM_VAL" | grep -q '^[0-9]' && ENERGY_AM_TODAY="true"
    echo "$PM_VAL" | grep -q '^[0-9]' && ENERGY_PM_TODAY="true"
  fi
fi

# ─── Check skip memory (if user skipped 3x in row, silence for 3 days) ───
SKIP_SILENCED="false"
SKIP_FILE="$BOS_DIR/state/.micro-morning-skips"
if [ -f "$SKIP_FILE" ]; then
  SKIP_COUNT=$(head -1 "$SKIP_FILE" 2>/dev/null || echo "0")
  SKIP_UNTIL=$(sed -n '2p' "$SKIP_FILE" 2>/dev/null || echo "")
  if [ -n "$SKIP_UNTIL" ] && [ "$TODAY" \< "$SKIP_UNTIL" -o "$TODAY" = "$SKIP_UNTIL" ]; then
    SKIP_SILENCED="true"
  elif [ "$SKIP_COUNT" -ge 3 ] 2>/dev/null; then
    SILENCE_UNTIL=$(date -v+3d '+%Y-%m-%d' 2>/dev/null || date -d '+3 days' '+%Y-%m-%d' 2>/dev/null || echo "")
    if [ -n "$SILENCE_UNTIL" ]; then
      echo "0" > "$SKIP_FILE"
      echo "$SILENCE_UNTIL" >> "$SKIP_FILE"
      SKIP_SILENCED="true"
    fi
  fi
fi

# ─── Output context ───
echo "<bos-time-context>"
# Circadian mode based on time block
case "$TIME_BLOCK" in
  MORNING)  MODE="STRATEGIST — plan, decide, set priorities" ;;
  PEAK)     MODE="EXECUTOR — deep work, build, ship" ;;
  AFTERNOON) MODE="EXECUTOR — continue work, meetings OK" ;;
  EVENING)  MODE="MAINTAINER — review, log, wind down" ;;
  NIGHT)    MODE="MINIMAL — short responses, defer to tomorrow" ;;
esac
echo "time: $TIME_DISPLAY | block: $TIME_BLOCK | mode: $MODE | day: $DAY | first_today: $FIRST_TODAY"
[ "$HOURS_SINCE_LAST" -gt 0 ] && echo "last_message: ${HOURS_SINCE_LAST}h ago (${LAST_MSG_DATE} ${LAST_MSG_HOUR}:xx)"
[ "$BLOCK_CHANGED" = "true" ] && echo "block_transition: $LAST_BLOCK → $TIME_BLOCK"

# ═══════════════════════════════════════════════════════════════
# DIRECTIVES — smart triggers based on time transitions
# ═══════════════════════════════════════════════════════════════

# ─── 1. MICRO-MORNING: first message of new day (even in same session) ───
FIRST_TODAY_FILE="$BOS_DIR/state/.micro-morning-done"
if [ "$FIRST_TODAY" = "true" ] && [ "$SKIP_SILENCED" = "false" ]; then
  echo "directive: MICRO-MORNING"
  VARIANT=$((DAY % 5))  # 0-4 rotation for ADHD novelty
  case $VARIANT in
    0) echo "instruction: Prepend 3-line micro-briefing. Format:"
       echo "  [top priority or alert]"
       echo "  Energia wczoraj: $LAST_ENERGY"
       echo "  $TASK_COUNT taskow otwartych"
       ;;
    1) echo "instruction: Prepend a CHALLENGE micro-briefing. Format:"
       echo "  Wyzwanie dnia: [top task framed as challenge]"
       echo "  $LAST_ENERGY -> dzisiejszy target?"
       ;;
    2) echo "instruction: Prepend ULTRA-SHORT briefing (1 line max):"
       echo "  [single most important thing today + task count]"
       ;;
    3) echo "instruction: Prepend a SCORE briefing. Format:"
       echo "  Wczoraj: energia $LAST_ENERGY | Dzis: $TASK_COUNT taskow"
       echo "  [streak or progress note from context if available]"
       ;;
    4) echo "instruction: Prepend a QUESTION briefing. Format:"
       echo "  Co dzis jest #1? [suggest based on tasks/alerts, let user confirm]"
       echo "  ($TASK_COUNT taskow czeka)"
       ;;
  esac
  echo "Then proceed normally. MAX 3 lines. If user says skip/krotko, respect AND increment skip counter."
  echo "$TODAY" > "$FIRST_TODAY_FILE"
fi

# ─── 2. MORNING ENERGY: first message of the day, ask AM energy ───
# If day changed AND morning block AND AM energy not logged
MORNING_ENERGY_FILE="$BOS_DIR/state/.morning-energy-asked"
MORNING_ENERGY_ASKED="false"
[ -f "$MORNING_ENERGY_FILE" ] && [ "$(cat "$MORNING_ENERGY_FILE" 2>/dev/null)" = "$TODAY" ] && MORNING_ENERGY_ASKED="true"

if [ "$FIRST_TODAY" = "true" ] && [ "$ENERGY_AM_TODAY" = "false" ] && [ "$MORNING_ENERGY_ASKED" = "false" ]; then
  echo "directive: MORNING-ENERGY"
  echo "instruction: Ask AM energy in micro-morning or as 1 line: 'Energia rano? (1-10)'. Log to daily-log.md AM column."
  echo "$TODAY" > "$MORNING_ENERGY_FILE"
fi

# ─── 3. /morning: new day + gap >1h → AskUserQuestion or auto-trigger ───
MORNING_RUN_FILE="$BOS_DIR/state/.morning-run-today"
MORNING_RUN_TODAY="false"
[ -f "$MORNING_RUN_FILE" ] && [ "$(cat "$MORNING_RUN_FILE" 2>/dev/null)" = "$TODAY" ] && MORNING_RUN_TODAY="true"

if [ "$FIRST_TODAY" = "true" ] && [ "$MORNING_RUN_TODAY" = "false" ] && [ "$HOURS_SINCE_LAST" -ge 1 ]; then
  # If user's first message has no specific intent (greeting/empty), auto-run /morning
  # If user has specific request, use AskUserQuestion to offer
  echo "directive: MORNING-OFFER"
  echo "instruction: Nowy dzień (${HOURS_SINCE_LAST}h przerwy). Jeśli user pisze powitanie/ogólnie → odpal /morning automatycznie. Jeśli ma konkretny request → po odpowiedzi użyj AskUserQuestion: 'Morning briefing?' z opcjami: [Tak] [Nie, dzięki]. NIGDY nie pisz tylko tekstu 'możesz odpalić /morning' — albo odpal albo daj klikalne opcje."
fi

# ─── 4. EVENING ENERGY: entering evening block OR late afternoon + no PM energy ───
EVENING_ASKED_FILE="$BOS_DIR/state/.evening-energy-asked"
EVENING_ALREADY_ASKED="false"
[ -f "$EVENING_ASKED_FILE" ] && [ "$(cat "$EVENING_ASKED_FILE" 2>/dev/null)" = "$TODAY" ] && EVENING_ALREADY_ASKED="true"

# Trigger when: entering EVENING block, OR already in evening, OR approaching end of work day (20:00+)
SHOULD_ASK_EVENING="false"
if [ "$ENERGY_PM_TODAY" = "false" ] && [ "$EVENING_ALREADY_ASKED" = "false" ]; then
  # Entering evening block from earlier block
  if [ "$TIME_BLOCK" = "EVENING" ] && [ "$BLOCK_CHANGED" = "true" ]; then
    SHOULD_ASK_EVENING="true"
  fi
  # Already evening, first message after >1h gap
  if [ "$TIME_BLOCK" = "EVENING" ] && [ "$HOURS_SINCE_LAST" -ge 1 ]; then
    SHOULD_ASK_EVENING="true"
  fi
  # Late evening (20:00+) — approaching end of day, last chance
  if [ "$HOUR_NUM" -ge 20 ] && [ "$HOUR_NUM" -lt 23 ]; then
    SHOULD_ASK_EVENING="true"
  fi
fi

if [ "$SHOULD_ASK_EVENING" = "true" ]; then
  echo "directive: EVENING-ENERGY-ONCE"
  echo "instruction: BLOCKING — PREPEND to your response: 'Energia dzis? (1-10) + co sie udalo?' THEN answer normally. This is NOT optional. After this one ask, do NOT repeat."
  echo "$TODAY" > "$EVENING_ASKED_FILE"
fi

# ─── 5. /evening NUDGE: 18:00+ with AskUserQuestion, escalating ───
EVENING_NUDGE_FILE="$BOS_DIR/state/.evening-nudge-done"
EVENING_NUDGE_SENT="false"
[ -f "$EVENING_NUDGE_FILE" ] && [ "$(cat "$EVENING_NUDGE_FILE" 2>/dev/null)" = "$TODAY" ] && EVENING_NUDGE_SENT="true"

if [ "$ENERGY_PM_TODAY" = "false" ] && [ "$EVENING_NUDGE_SENT" = "false" ]; then
  if [ "$HOUR_NUM" -ge 20 ]; then
    # 20:00+ — stronger nudge
    echo "directive: EVENING-NUDGE-STRONG"
    echo "instruction: 20:00+ bez /evening. Użyj AskUserQuestion: 'Evening shutdown?' z opcjami: [Tak, lecimy] [Tylko energia] [Skip]. Po odpowiedzi usera: odpal /evening lub zaloguj energię."
    echo "$TODAY" > "$EVENING_NUDGE_FILE"
  elif [ "$HOUR_NUM" -ge 18 ] && [ "$BLOCK_CHANGED" = "true" ]; then
    # 18:00+ entering evening — gentle nudge
    echo "directive: EVENING-NUDGE-GENTLE"
    echo "instruction: Wchodzisz w wieczór. Na KOŃCU odpowiedzi użyj AskUserQuestion: 'Kończysz na dziś?' z opcjami: [/evening] [Jeszcze pracuję]"
    echo "$TODAY" > "$EVENING_NUDGE_FILE"
  fi
fi

# ─── 6. NIGHT MODE: user still active after 22:00 ───
if [ "$TIME_BLOCK" = "NIGHT" ] && [ "$BLOCK_CHANGED" = "true" ]; then
  echo "nudge: 22:00+ — rozważ /evening i shutdown. Sen > produktywność."
fi

# ─── 7. CRITICAL DATA_GAP: daily-log gap > 5 days ───
if [ -f "$BOS_DIR/state/daily-log.md" ]; then
  # Get most recent entry date from Active section (first data row, newest-first order)
  LAST_LOG_DATE=$(grep '^| 20' "$BOS_DIR/state/daily-log.md" 2>/dev/null | head -1 | grep -o '20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]' | head -1)
  if [ -n "$LAST_LOG_DATE" ] && date -j -f "%Y-%m-%d" "$LAST_LOG_DATE" "+%s" >/dev/null 2>&1; then
    LAST_SEC=$(date -j -f "%Y-%m-%d" "$LAST_LOG_DATE" "+%s")
    LOG_GAP=$(( (NOW_SEC - LAST_SEC) / 86400 ))
    if [ "$LOG_GAP" -ge 5 ]; then
      echo "directive: CRITICAL-DATA-GAP"
      echo "instruction: ${LOG_GAP}-day gap in daily-log. PREPEND to your response: ask energy (1-10) in 1 line. Do NOT skip. Do NOT wait for 'natural moment'. User explicitly requested this behavior."
    fi
  fi
fi

# ─── 8. WEEKLY NUDGES (persistent through weekend) ───
REVIEW_DONE_FILE="$BOS_DIR/state/.review-week-done"
REVIEW_DONE="false"
if [ -f "$REVIEW_DONE_FILE" ]; then
  REVIEW_WEEK=$(cat "$REVIEW_DONE_FILE" 2>/dev/null)
  # Check if review was done this week (same ISO week)
  THIS_WEEK=$(date '+%Y-W%V')
  [ "$REVIEW_WEEK" = "$THIS_WEEK" ] && REVIEW_DONE="true"
fi

# Friday 16:00+ through Sunday — keep nudging until review is done
if [ "$DAY" -ge 5 ] && [ "$REVIEW_DONE" = "false" ]; then
  if [ "$DAY" = "5" ] && [ "$HOUR_NUM" -ge 16 ]; then
    echo "directive: WEEKLY-REVIEW-DUE"
    echo "instruction: Piątek — zaproponuj /review-week. Użyj AskUserQuestion: 'Piątkowy review?' z opcjami: [Tak, lecimy] [Później] [Skip this week]"
  elif [ "$DAY" -ge 6 ]; then
    echo "directive: WEEKLY-REVIEW-OVERDUE"
    echo "instruction: Weekend bez review — zaproponuj /review-week. Użyj AskUserQuestion z opcjami: [Tak] [Nie, skip]"
  fi
fi

# Sunday plan nudge
PLAN_DONE_FILE="$BOS_DIR/state/.plan-week-done"
PLAN_DONE="false"
[ -f "$PLAN_DONE_FILE" ] && [ "$(cat "$PLAN_DONE_FILE" 2>/dev/null)" = "$(date '+%Y-W%V')" ] && PLAN_DONE="true"

if [ "$DAY" = "7" ] && [ "$HOUR_NUM" -ge 16 ] && [ "$PLAN_DONE" = "false" ]; then
  echo "directive: WEEKLY-PLAN-DUE"
  echo "instruction: Niedziela — zaproponuj /plan-week. Użyj AskUserQuestion: 'Plan na nowy tydzień?' z opcjami: [Tak] [Później] [Skip]"
fi

echo "</bos-time-context>"
exit 0
