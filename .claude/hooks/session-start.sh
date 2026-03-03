#!/bin/bash
# bOS Session Start Hook
# Injects essential daily context into Claude's context at session start.
# Output goes to stdout → Claude sees it as injected context.

BOS_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

echo "## bOS Session Context"
echo "Date: $(date '+%Y-%m-%d %H:%M %Z (%A)')"
echo ""

# Top tasks (first 5 lines of tasks summary)
if [ -f "$BOS_DIR/state/tasks.md" ]; then
  echo "### Tasks"
  head -15 "$BOS_DIR/state/tasks.md" | grep -E '^\|.*\|$|^- ' | head -5
  echo ""
fi

# Buffer status (critical financial safety)
if [ -f "$BOS_DIR/state/finances.md" ]; then
  BUFFER=$(grep -i 'buffer' "$BOS_DIR/state/finances.md" | head -1)
  if [ -n "$BUFFER" ]; then
    echo "### Buffer: $BUFFER"
    echo ""
  fi
fi

# Critical context-bus signals
if [ -f "$BOS_DIR/state/context-bus.md" ]; then
  CRITICAL=$(grep -A2 'Priority: critical' "$BOS_DIR/state/context-bus.md" | grep -v '^--$' | head -6)
  if [ -n "$CRITICAL" ]; then
    echo "### Critical Signals"
    echo "$CRITICAL"
    echo ""
  fi
fi

# Telemetry summary (if exists)
if [ -f "$BOS_DIR/state/telemetry.md" ]; then
  echo "### Agent Performance"
  head -10 "$BOS_DIR/state/telemetry.md" | grep -E '^\|.*\|$|^Total|^Top|^Avg' | head -3
  echo ""
fi

# Pending evolution proposals
if [ -f "$BOS_DIR/state/evolution-proposals.md" ]; then
  PENDING=$(grep -c 'Status: pending' "$BOS_DIR/state/evolution-proposals.md" 2>/dev/null)
  if [ "$PENDING" -gt 0 ] 2>/dev/null; then
    echo "### Evolution: $PENDING pending proposals"
    echo ""
  fi
fi
