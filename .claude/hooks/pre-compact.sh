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
  echo "## Pending Context-Bus Entries"
  if [ -f "$BOS_DIR/state/context-bus.md" ]; then
    grep -A3 'Status: pending' "$BOS_DIR/state/context-bus.md" 2>/dev/null | head -20
  fi
  echo ""
  echo "## Recent Task Changes"
  if [ -f "$BOS_DIR/state/tasks.md" ]; then
    head -25 "$BOS_DIR/state/tasks.md"
  fi
  echo ""
  echo "## Buffer Status"
  if [ -f "$BOS_DIR/state/finances.md" ]; then
    grep -i 'buffer' "$BOS_DIR/state/finances.md" | head -3
  fi
} > "$SNAPSHOT" 2>/dev/null

# Rotate: keep only last 5 snapshots
ls -t "$BACKUP_DIR"/pre-compact-*.md 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null

# Signal to stdout (Claude sees this)
echo "Pre-compact snapshot saved. Pending state preserved."
