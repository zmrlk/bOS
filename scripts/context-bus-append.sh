#!/bin/bash
# bOS context-bus: the only writer. Append-only JSONL. No ACK. No TTL rewrite.
#
# Usage:
#   bash scripts/context-bus-append.sh <from> <to> <type> <priority> <content> [ttl_days]
#
# Example:
#   bash scripts/context-bus-append.sh "@boss" "ALL" "insight" "normal" "Buffer cited with mtime" 14
#
# Types: insight|decision|constraint|data|calibration|session-status|plan|system-migration|incident
# Priority: critical|normal|info
# from: @agent | session:name | cron-name
# calibration content MUST contain: BYŁO: | JEST: | ŹRÓDŁO:
# BUS_FILE override is for tests only.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FROM="${1:?usage: $0 <from> <to> <type> <priority> <content> [ttl_days]}"
TO="${2:?usage: $0 <from> <to> <type> <priority> <content> [ttl_days]}"
TYPE="${3:?usage: $0 <from> <to> <type> <priority> <content> [ttl_days]}"
PRIORITY="${4:?usage: $0 <from> <to> <type> <priority> <content> [ttl_days]}"
CONTENT="${5:?usage: $0 <from> <to> <type> <priority> <content> [ttl_days]}"
TTL_DAYS="${6:-14}"
BUS_FILE="${BUS_FILE:-$ROOT/state/context-bus.jsonl}"

case "$TYPE" in
  insight|decision|constraint|data|calibration|session-status|plan|system-migration|incident) ;;
  *) echo "BUS-REJECT: unknown type '$TYPE' (insight|decision|constraint|data|calibration|session-status|plan|system-migration|incident)" >&2; exit 1 ;;
esac
case "$PRIORITY" in
  critical|normal|info) ;;
  *) echo "BUS-REJECT: unknown priority '$PRIORITY' (critical|normal|info)" >&2; exit 1 ;;
esac
if ! printf '%s' "$FROM" | grep -qE '^(@[a-z][a-z-]*|session:[A-Za-z0-9._-]+|[a-z][a-z0-9-]*)$'; then
  echo "BUS-REJECT: from '$FROM' not (@agent | session:name | cron-name)" >&2; exit 1
fi
if [ "${#CONTENT}" -gt 2000 ]; then
  echo "BUS-REJECT: content ${#CONTENT} chars (max 2000) — signal, not a document" >&2; exit 1
fi
if [ "$TYPE" = "calibration" ]; then
  MISSING=""
  case "$CONTENT" in *"BYŁO:"*) ;; *) MISSING="$MISSING BYŁO:" ;; esac
  case "$CONTENT" in *"JEST:"*) ;; *) MISSING="$MISSING JEST:" ;; esac
  case "$CONTENT" in *"ŹRÓDŁO:"*) ;; *) MISSING="$MISSING ŹRÓDŁO:" ;; esac
  if [ -n "$MISSING" ]; then
    echo "BUS-REJECT: calibration missing:$MISSING" >&2
    echo "  Format: 'FAKT: <what> | BYŁO: <old literal> | JEST: <new> | ŹRÓDŁO: <Karol, date | file | live test>'" >&2
    exit 1
  fi
fi

TS=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
TTL_TS=$(date -u -v+${TTL_DAYS}d '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -u -d "+${TTL_DAYS} days" '+%Y-%m-%dT%H:%M:%SZ')
ESCAPED_CONTENT=$(printf '%s' "$CONTENT" | tr '\n' ' ' | sed 's/\\/\\\\/g; s/"/\\"/g')

mkdir -p "$(dirname "$BUS_FILE")"
echo "{\"ts\":\"$TS\",\"from\":\"$FROM\",\"to\":\"$TO\",\"type\":\"$TYPE\",\"priority\":\"$PRIORITY\",\"ttl\":\"$TTL_TS\",\"status\":\"pending\",\"content\":\"$ESCAPED_CONTENT\"}" >> "$BUS_FILE"
exit 0
