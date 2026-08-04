#!/bin/bash
# bOS Guard Hook — PreToolUse file protection (ISI-11)
# Deterministic enforcement: blocks dangerous writes BEFORE they happen.
# Exit code 2 = BLOCK the tool call. Exit code 0 = allow.
#
# Source: Codex-OS protect-archive.sh + PAI SecurityValidator
# Must execute in <50ms.

# Read the tool use JSON from stdin
INPUT=$(cat)

# Extract tool name and file path from JSON
TOOL=$(echo "$INPUT" | grep -o '"tool_name":"[^"]*"' | head -1 | cut -d'"' -f4)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4)
COMMAND=$(echo "$INPUT" | grep -o '"command":"[^"]*"' | head -1 | cut -d'"' -f4)

# Only check Write and Edit tools
case "$TOOL" in
  Write|Edit)
    ;;
  Bash)
    # Check for dangerous bash commands on protected paths
    if echo "$COMMAND" | grep -qE 'rm\s+.*state/(archive|\.backup)'; then
      echo "BLOCKED: Cannot delete files in state/archive/ or state/.backup/"
      exit 2
    fi
    exit 0
    ;;
  *)
    exit 0
    ;;
esac

# No file path = nothing to protect
[ -z "$FILE_PATH" ] && exit 0

# ── Protected paths ──

# Block writes to archive (historical data, never modify)
if echo "$FILE_PATH" | grep -q 'state/archive/'; then
  echo "BLOCKED: state/archive/ is read-only. Historical data cannot be modified."
  exit 2
fi

# Block writes to backup (auto-generated, never manual edit)
if echo "$FILE_PATH" | grep -q 'state/\.backup/'; then
  echo "BLOCKED: state/.backup/ is auto-managed. Do not write directly."
  exit 2
fi

# Block overwriting .claude/settings.json (use update-config skill instead)
# Exception: allow when /update-config skill is active (detected by update-config in conversation)
if echo "$FILE_PATH" | grep -q '\.claude/settings\.json$'; then
  echo "BLOCKED: Use /update-config skill to modify settings.json safely."
  exit 2
fi

# All other writes allowed
exit 0
