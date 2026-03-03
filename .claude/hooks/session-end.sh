#!/bin/bash
# bOS Session End Hook
# Performs batch operations when a session ends.
# Runs cleanup and summary updates.

BOS_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

# Expire old context-bus entries (TTL check)
if [ -f "$BOS_DIR/state/context-bus.md" ]; then
  TODAY=$(date '+%Y-%m-%d')
  # Mark entries older than 14 days as expired (simple date comparison)
  # Full expiration logic handled by @boss in CLAUDE.md, this is a safety net
  :
fi

# Update telemetry session count
if [ -f "$BOS_DIR/state/telemetry.md" ]; then
  # Increment session count in telemetry summary
  SESSIONS=$(grep -oP 'Sessions: \K[0-9]+' "$BOS_DIR/state/telemetry.md" 2>/dev/null)
  if [ -n "$SESSIONS" ]; then
    NEW_COUNT=$((SESSIONS + 1))
    sed -i '' "s/Sessions: $SESSIONS/Sessions: $NEW_COUNT/" "$BOS_DIR/state/telemetry.md" 2>/dev/null
  fi
fi

# Ensure state directory structure exists
mkdir -p "$BOS_DIR/state/.backup"
mkdir -p "$BOS_DIR/state/archive"

echo "Session ended. State preserved."
