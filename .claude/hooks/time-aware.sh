#!/bin/bash
# bOS Time-Aware Context Injection
# Runs on UserPromptSubmit — BEFORE every user message.
# Lightweight: only date checks + grep, no heavy reads.
# stdout → Claude sees as system context.

BOS_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
HOUR=$(date '+%H')
DAY=$(date '+%u')  # 1=Monday, 7=Sunday
TODAY=$(date '+%Y-%m-%d')
TIME_DISPLAY=$(date '+%H:%M')

# ─── Determine time block (adapted to user's profile) ───
# Peak: 11-15 (profile), Sauna: 16-17, Evening: 18-22
if [ "$HOUR" -ge 6 ] && [ "$HOUR" -lt 11 ]; then
  TIME_BLOCK="MORNING"
elif [ "$HOUR" -ge 11 ] && [ "$HOUR" -lt 15 ]; then
  TIME_BLOCK="PEAK"
elif [ "$HOUR" -ge 15 ] && [ "$HOUR" -lt 18 ]; then
  TIME_BLOCK="AFTERNOON"
elif [ "$HOUR" -ge 18 ] && [ "$HOUR" -lt 22 ]; then
  TIME_BLOCK="EVENING"
else
  TIME_BLOCK="NIGHT"
fi

# ─── Check if first message today ───
# FIX: default true — if session-log missing or no today entry, assume first
FIRST_TODAY="true"
if [ -f "$BOS_DIR/state/session-log.md" ]; then
  if grep -q "$TODAY" "$BOS_DIR/state/session-log.md" 2>/dev/null; then
    FIRST_TODAY="false"
  fi
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

# ─── Get top critical signal ───
TOP_ALERT=""
if [ -f "$BOS_DIR/state/context-bus.md" ]; then
  TOP_ALERT=$(grep -A3 'Priority: critical' "$BOS_DIR/state/context-bus.md" 2>/dev/null | grep 'Content:' | head -1 | sed 's/Content: //' | cut -c1-80)
fi

# ─── Get today's task count ───
TASK_COUNT=0
if [ -f "$BOS_DIR/state/tasks.md" ]; then
  TASK_COUNT=$(grep -c '☐' "$BOS_DIR/state/tasks.md" 2>/dev/null || echo "0")
fi

# ─── Check if energy_pm logged today ───
ENERGY_PM_TODAY="false"
if [ -f "$BOS_DIR/state/daily-log.md" ]; then
  TODAY_LINE=$(grep "^| $TODAY" "$BOS_DIR/state/daily-log.md" 2>/dev/null)
  if [ -n "$TODAY_LINE" ]; then
    # Check if PM column (4th) has a number (not — or empty)
    PM_VAL=$(echo "$TODAY_LINE" | awk -F'|' '{gsub(/^ +| +$/,"",$4); print $4}')
    if echo "$PM_VAL" | grep -q '^[0-9]'; then
      ENERGY_PM_TODAY="true"
    fi
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
    # Set 3-day silence
    SILENCE_UNTIL=$(date -v+3d '+%Y-%m-%d' 2>/dev/null || date -d '+3 days' '+%Y-%m-%d' 2>/dev/null || echo "")
    if [ -n "$SILENCE_UNTIL" ]; then
      echo "0" > "$SKIP_FILE"
      echo "$SILENCE_UNTIL" >> "$SKIP_FILE"
      SKIP_SILENCED="true"
    fi
  fi
fi

# ─── Detect long messages (proxy for hyperfocus/flow state) ───
# Note: night behavior handled by Circadian Engine MAINTAINER mode (CLAUDE.md)

# ─── Output context ───
echo "<bos-time-context>"
echo "time: $TIME_DISPLAY | block: $TIME_BLOCK | day: $DAY | first_today: $FIRST_TODAY"

# Micro-morning: ONLY on first message of the day (if not silenced)
# ADHD novelty rotation — 5 formats by day-of-week to prevent habituation
if [ "$FIRST_TODAY" = "true" ] && [ "$SKIP_SILENCED" = "false" ]; then
  echo "directive: MICRO-MORNING"
  VARIANT=$((DAY % 5))  # 0-4 rotation
  case $VARIANT in
    0) # Standard 3-liner
      echo "instruction: Prepend 3-line micro-briefing. Format:"
      echo "  💡 [top priority or alert]"
      echo "  ⚡ Energia wczoraj: $LAST_ENERGY"
      echo "  📋 $TASK_COUNT tasków otwartych"
      ;;
    1) # Challenge mode
      echo "instruction: Prepend a CHALLENGE micro-briefing. Format:"
      echo "  🎯 Wyzwanie dnia: [top task framed as challenge, e.g. 'Zamknij poprawki raportu przed 15:00']"
      echo "  ⚡ $LAST_ENERGY → dzisiejszy target?"
      ;;
    2) # Minimalist
      echo "instruction: Prepend ULTRA-SHORT briefing (1 line max):"
      echo "  → [single most important thing today + task count]"
      ;;
    3) # Score mode
      echo "instruction: Prepend a SCORE briefing. Format:"
      echo "  📊 Wczoraj: energia $LAST_ENERGY | Dziś: $TASK_COUNT tasków"
      echo "  🏆 [streak or progress note from context if available]"
      ;;
    4) # Question mode
      echo "instruction: Prepend a QUESTION briefing. Format:"
      echo "  ❓ Co dziś jest #1? [suggest based on tasks/alerts, let user confirm]"
      echo "  📋 ($TASK_COUNT tasków czeka)"
      ;;
  esac
  echo "Then proceed normally. MAX 3 lines. If user says skip/krótko, respect AND increment skip counter in state/.micro-morning-skips (line 1 = count)."
fi

# Evening energy: ONCE per evening session (not every response)
# Guard: skip if /evening was already run this session (energy_pm logged) or if energy already in daily-log
if [ "$TIME_BLOCK" = "EVENING" ] && [ "$ENERGY_PM_TODAY" = "false" ]; then
  echo "directive: EVENING-ENERGY-ONCE"
  echo "instruction: Ask energy ONCE at a natural pause. If /evening runs this session, skip. AskUserQuestion: 'Energia dziś?' [1-5]. After asking or declining, do NOT repeat."
fi

# Night mode: REMOVED — Circadian Engine MAINTAINER handles 22:00+ behavior
# (including flow/hyperfocus override via Affect Modulation)

# Friday review nudge
if [ "$DAY" = "5" ] && [ "$HOUR" -ge 16 ]; then
  echo "nudge: Piątek — /review-week kiedy będziesz gotowy"
fi

# Sunday plan nudge
if [ "$DAY" = "7" ] && [ "$HOUR" -ge 16 ]; then
  echo "nudge: Niedziela — /plan-week na nowy tydzień"
fi

echo "</bos-time-context>"
exit 0
