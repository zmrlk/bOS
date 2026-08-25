#!/bin/bash
# bOS SessionStart — short fact pack. stdout → Claude/Codex context.
# Grok ignores this stdout; it must Read AGENTS.md + state/handoff.md + state/ping.md.

BOS_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=ping-inject.sh
. "$BOS_DIR/.claude/hooks/ping-inject.sh"

echo "## bOS start"
echo "Date: $(date '+%Y-%m-%d %H:%M %Z (%A)')"
echo "Contract: AGENTS.md. Locators: state/tasks.md | state/finances.md | state/handoff.md | state/ping.md | state/rules.md | state/context-bus.jsonl"
echo ""

WORKING_FILE="$BOS_DIR/state/.working.md"
if [ -f "$WORKING_FILE" ]; then
  echo "### Crash buffer"
  cat "$WORKING_FILE"
  echo ""
  rm -f "$WORKING_FILE"
fi

if [ -f "$BOS_DIR/state/tasks.md" ]; then
  echo "### Tasks (max 3)"
  grep -E '^\|.*\|$|^- \[' "$BOS_DIR/state/tasks.md" | head -3
  echo ""
fi

if [ -f "$BOS_DIR/profile.md" ]; then
  GOAL=$(grep -i 'Primary goal' "$BOS_DIR/profile.md" | head -1 | sed 's/.*|[ ]*//;s/[ ]*|.*//;s/^|//;s/|$//' | head -c 120)
  [ -n "$GOAL" ] && echo "### Goal: $GOAL"
fi

if [ -f "$BOS_DIR/state/finances.md" ]; then
  BUFFER=$(grep -i 'buffer' "$BOS_DIR/state/finances.md" | head -1)
  MTIME=$(stat -f '%Sm' -t '%Y-%m-%d' "$BOS_DIR/state/finances.md" 2>/dev/null || stat -c '%y' "$BOS_DIR/state/finances.md" 2>/dev/null | cut -d' ' -f1)
  [ -n "$BUFFER" ] && echo "### Buffer (mtime $MTIME): $BUFFER"
  echo ""
fi

if [ -f "$BOS_DIR/state/handoff.md" ]; then
  echo "### Handoff"
  head -20 "$BOS_DIR/state/handoff.md"
  echo ""
fi

# Overdue reminders (written by /remind; ntfy-less fallback surfaces here)
if [ -f "$BOS_DIR/state/reminders.md" ]; then
  TODAY_DATE=$(date '+%Y-%m-%d')
  NOW_HM=$(date '+%H:%M')
  OVERDUE=$(grep -E '^\| [0-9]{4}-[0-9]{2}-[0-9]{2}' "$BOS_DIR/state/reminders.md" 2>/dev/null \
    | grep -v 'done' \
    | while IFS= read -r line; do
        # column 2 = "{YYYY-MM-DD HH:MM}" per remind/SKILL.md
        R_DT=$(printf '%s' "$line" | awk -F'|' '{sub(/^ +/,"",$2); sub(/ +$/,"",$2); print $2}')
        R_DATE=$(printf '%s' "$R_DT" | cut -c1-10)
        R_TIME=$(printf '%s' "$R_DT" | cut -c12-16)
        if [ "$R_DATE" \< "$TODAY_DATE" ] || { [ "$R_DATE" = "$TODAY_DATE" ] && [ -n "$R_TIME" ] && [ "$R_TIME" \< "$NOW_HM" ]; }; then
          echo "$line"
        fi
      done | head -5)
  if [ -n "$OVERDUE" ]; then
    echo "### Overdue reminders"
    echo "$OVERDUE"
    echo ""
  fi
fi

# Critical bus: read-filter by TTL. Do not rewrite jsonl.
if [ -f "$BOS_DIR/state/context-bus.jsonl" ]; then
  NOW_ISO=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
  CRITICAL=$(grep '"priority":"critical"' "$BOS_DIR/state/context-bus.jsonl" 2>/dev/null \
    | while IFS= read -r line; do
        TTL=$(printf '%s' "$line" | sed -n 's/.*"ttl":"\([^"]*\)".*/\1/p')
        [ -n "$TTL" ] && [ "$TTL" \< "$NOW_ISO" ] && continue
        TS=$(printf '%s' "$line" | sed -n 's/.*"ts":"\([^"]*\)".*/\1/p' | cut -c1-10)
        FROM=$(printf '%s' "$line" | sed -n 's/.*"from":"\([^"]*\)".*/\1/p')
        CONTENT=$(printf '%s' "$line" | sed -n 's/.*"content":"\(.*\)/\1/p' | sed 's/","[a-z_]*":.*$//; s/"}$//' | cut -c1-220)
        echo "- [$TS] $FROM: $CONTENT"
      done | tail -5)
  if [ -n "$CRITICAL" ]; then
    echo "### Critical bus (unexpired)"
    echo "$CRITICAL"
    echo ""
  fi
fi

_bos_inject_ping
