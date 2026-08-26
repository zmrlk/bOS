#!/bin/bash
# bOS Guard Hook — PreToolUse file protection (ISI-11)
# Best-effort guard: catches the model's own mistakes BEFORE they happen.
# It is a speed bump against accidents, NOT a security boundary against a
# determined adversary (any interpreter can sidestep a grep — see HONESTY.md).
# Exit code 2 = BLOCK the tool call. Exit code 0 = allow.
# Must execute in <50ms.

# Read the tool use JSON from stdin
INPUT=$(cat)

# Extract tool name, file path and command from JSON.
# sed -E with an escaped-char-aware group — a naive [^"]* stops at the first
# \" inside the command and lets the rest of the payload slip past the guard.
json_field() {
  printf '%s' "$INPUT" | sed -nE 's/.*"'"$1"'":"(([^"\\]|\\.)*)".*/\1/p' | head -1
}
TOOL=$(json_field tool_name)
FILE_PATH=$(json_field file_path)
COMMAND=$(json_field command)

# Write/Edit/MultiEdit: path guards. Bash: archive-rm + bus helper.
case "$TOOL" in
  Write|Edit|MultiEdit)
    ;;
  Bash)
    # Archive/backup: block every destructive verb we can name, not just rm.
    if echo "$COMMAND" | grep -qE '(rm\s+|find\s+.*-delete|unlink\s+|truncate\s+|shred\s+|dd\s+.*of=|mv\s+|cp\s+)[^;|&]*state/(archive|\.backup)|state/(archive|\.backup)[^;|&]*(-delete)|(>|>>|tee\s)[^;|&]*state/(archive|\.backup)'; then
      echo "BLOCKED: Cannot delete, move, truncate or overwrite files in state/archive/ or state/.backup/"
      exit 2
    fi
    # settings.json: the Write/Edit guard below is useless if Bash can write it.
    if echo "$COMMAND" | grep -q '\.claude/settings\.json'; then
      if echo "$COMMAND" | grep -qE '(>|>>|tee\s|sed\s+-i|truncate|mv\s|cp\s|python[0-9.]*\s|node\s|perl\s|ruby\s)[^;|&]*'; then
        if ! echo "$COMMAND" | grep -qE '^\s*(cat|head|tail|grep|diff|wc|stat|ls|jq|python[0-9.]*\s+-m\s+json\.tool)\s[^>]*$'; then
          echo "BLOCKED: settings.json is not editable from a session. Edit it in your own editor."
          exit 2
        fi
      fi
    fi
    # Bus: one helper. NO early-exit on the helper's name — a chained command
    # ("helper.sh …; echo x >> bus") must still hit the write patterns below.
    if echo "$COMMAND" | grep -qE 'context-bus\.(jsonl|md)'; then
      if echo "$COMMAND" | grep -qE '(>>|>)[[:space:]]*[^[:space:]]*context-bus\.(jsonl|md)|(tee|truncate|cp|mv|dd|shred|unlink|rm)[[:space:]][^;|&]*context-bus\.(jsonl|md)|sed[[:space:]]+-i.*context-bus\.(jsonl|md)|(python[0-9.]*|node|perl|ruby)[[:space:]].*context-bus\.(jsonl|md)'; then
        echo "BLOCKED: write the bus only via bash scripts/context-bus-append.sh"
        exit 2
      fi
    fi
    # Durable memory: direct writes bypass provenance, secret/crisis filters,
    # conflict quarantine and the append-only ledger. The helper is allowed,
    # but a chained direct write must still be blocked.
    if echo "$COMMAND" | grep -qE 'memory/'; then
      if echo "$COMMAND" | grep -qE '(>>|>)[[:space:]]*[^[:space:]]*memory/|(tee|truncate|cp|mv|dd|shred|unlink|rm)[[:space:]][^;|&]*memory/|sed[[:space:]]+-i.*memory/|(python[0-9.]*|node|perl|ruby)[[:space:]].*memory/'; then
        echo "BLOCKED: write durable memory only via bash scripts/bos-memory.sh"
        exit 2
      fi
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

# Block overwriting .claude/settings.json from inside a session (no exceptions)
if echo "$FILE_PATH" | grep -q '\.claude/settings\.json$'; then
  echo "BLOCKED: settings.json is not editable from a session. Edit it in your own editor."
  exit 2
fi

if echo "$FILE_PATH" | grep -qE 'state/context-bus\.(jsonl|md)$'; then
  echo "BLOCKED: write the bus only via bash scripts/context-bus-append.sh"
  exit 2
fi

# Durable memory records, hot cache and ledger are helper-managed. This is a
# best-effort Claude guard; Codex/Grok rely on the shared contract.
if echo "$FILE_PATH" | grep -qE '(^|/)memory/'; then
  echo "BLOCKED: write durable memory only via bash scripts/bos-memory.sh"
  exit 2
fi

# All other writes allowed
exit 0
