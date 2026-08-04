#!/bin/bash
# bOS Pre-Compact Hook
# Saves critical state before context compaction wipes the conversation.
# Runs asynchronously (should not block compaction).

BOS_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
TIMESTAMP=$(date '+%Y-%m-%d_%H%M')
BACKUP_DIR="$BOS_DIR/state/.backup"

mkdir -p "$BACKUP_DIR"

# Save session snapshot
SNAPSHOT="$BACKUP_DIR/pre-compact-$TIMESTAMP.md"
{
  echo "# Pre-Compact Snapshot — $TIMESTAMP"
  echo ""
  echo "## Pending Context-Bus Entries (critical first)"
  if [ -f "$BOS_DIR/state/context-bus.md" ]; then
    grep -B1 -A4 'Priority: critical' "$BOS_DIR/state/context-bus.md" 2>/dev/null | head -30
    echo "---"
    grep -A3 'Status: pending' "$BOS_DIR/state/context-bus.md" 2>/dev/null | head -20
  fi
  echo ""
  echo "## Active Goals"
  if [ -f "$BOS_DIR/state/goals.md" ]; then
    grep -A2 'status.*active\|Status.*Active\|IN PROGRESS\|in_progress' "$BOS_DIR/state/goals.md" 2>/dev/null | head -15
  fi
  echo ""
  echo "## Recent Task Changes"
  if [ -f "$BOS_DIR/state/tasks.md" ]; then
    head -25 "$BOS_DIR/state/tasks.md"
  fi
  echo ""
  echo "## Buffer Status"
  if [ -f "$BOS_DIR/state/finances.md" ]; then
    grep -i 'buffer\|bufor' "$BOS_DIR/state/finances.md" | head -3
  fi
  echo ""
  echo "## Last Daily Log Entry"
  if [ -f "$BOS_DIR/state/daily-log.md" ]; then
    tail -5 "$BOS_DIR/state/daily-log.md" 2>/dev/null
  fi
  echo ""
  echo "## Habit Streaks"
  if [ -f "$BOS_DIR/state/habits.md" ]; then
    head -15 "$BOS_DIR/state/habits.md"
  fi
} > "$SNAPSHOT" 2>/dev/null

# Rotate: keep only last 5 snapshots
ls -t "$BACKUP_DIR"/pre-compact-*.md 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null

# Validate daily-log Summary against raw data
DAILY_LOG="$BOS_DIR/state/daily-log.md"
if [ -f "$DAILY_LOG" ]; then
  # Count actual energy entries (non-empty AM or PM fields)
  ENERGY_COUNT=$(awk -F'|' '/^\| 2026/ { am=$3; pm=$4; gsub(/[ —-]/, "", am); gsub(/[ —-]/, "", pm); if (am != "" || pm != "") count++ } END { print count+0 }' "$DAILY_LOG")

  # Count entries with dates this month
  CURRENT_MONTH=$(date '+%Y-%m')
  MONTH_ENTRIES=$(grep -c "^| $CURRENT_MONTH" "$DAILY_LOG" 2>/dev/null || echo 0)

  # Calculate AM and PM averages
  AM_AVG=$(awk -F'|' '/^\| 2026/ { v=$3; gsub(/[ ]/, "", v); if (v ~ /^[0-9]+$/) { sum+=v; n++ } } END { if(n>0) printf "%.1f", sum/n; else print "—" }' "$DAILY_LOG")
  PM_AVG=$(awk -F'|' '/^\| 2026/ { v=$4; gsub(/[ ]/, "", v); if (v ~ /^[0-9]+$/) { sum+=v; n++ } } END { if(n>0) printf "%.1f", sum/n; else print "—" }' "$DAILY_LOG")

  # Output validation for Claude to see
  echo "DAILY-LOG-VALIDATION: energy_entries=$ENERGY_COUNT month_entries=$MONTH_ENTRIES AM_avg=$AM_AVG PM_avg=$PM_AVG"
fi

# Signal to stdout (Claude sees this)
echo "Pre-compact snapshot saved. Pending state preserved."
