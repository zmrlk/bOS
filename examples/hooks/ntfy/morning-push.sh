#!/usr/bin/env zsh
# ============================================================
# bOS Layer 3 — Morning Push Notification
# Runs headless via launchd at 07:30, pushes briefing to phone.
# ============================================================

set -euo pipefail

# ── Config ──────────────────────────────────────────────────
BOS_DIR="${BOS_DIR:-$(cd "$(dirname "$0")/../../.." && pwd)}"  # repo root (script lives in examples/hooks/ntfy/)
LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/morning-push-$(date '+%Y%m%d').log"
SECRETS_FILE="$BOS_DIR/.secrets/ntfy.env"   # optional: NTFY_TOPIC=xxx
NTFY_BASE_URL="${NTFY_BASE_URL:-https://ntfy.sh}"

# ── Logging helper ──────────────────────────────────────────
mkdir -p "$LOG_DIR"
exec >> "$LOG_FILE" 2>&1

# Weekend: always push (user may work weekends too)
# To disable weekends: set MORNING_PUSH_SKIP_WEEKENDS=1
DOW=$(date '+%u')  # 1=Mon … 7=Sun
if [[ "$DOW" -ge 6 && "${MORNING_PUSH_SKIP_WEEKENDS:-0}" == "1" ]]; then
  echo "[morning-push] $(date '+%H:%M') Skipping weekend (DOW=$DOW)."
  exit 0
fi

# ── Dry run: print what would happen, send nothing ─────────
DRY_RUN="${MORNING_PUSH_DRY_RUN:-0}"

# ── Idempotency: only push ONCE per day ───────────────────
SENT_FILE="$LOG_DIR/.morning-push-last-date"
TODAY=$(date '+%Y-%m-%d')
if [[ -f "$SENT_FILE" ]] && [[ "$(cat "$SENT_FILE" 2>/dev/null)" == "$TODAY" ]]; then
  echo "[morning-push] $(date '+%H:%M') Already pushed today. Skipping."
  exit 0
fi
echo ""
echo "═══════════════════════════════════════════════"
echo "[morning-push] START $(date '+%Y-%m-%d %H:%M:%S')"
echo "═══════════════════════════════════════════════"

# ── Source environment ──────────────────────────────────────
# launchd gives a bare environment — manually bring in what we need.
export LANG="${MORNING_PUSH_LOCALE:-en_US.UTF-8}"
export LC_ALL="${MORNING_PUSH_LOCALE:-en_US.UTF-8}"

# Homebrew
[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

# nvm (node version manager)
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh" --no-use 2>/dev/null || true

# PATH enrichment — cover common install locations
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin:$HOME/.nvm/versions/node/$(ls $HOME/.nvm/versions/node 2>/dev/null | tail -1)/bin:$PATH"

# ── Resolve binaries ────────────────────────────────────────
find_binary() {
  local name="$1"
  local candidates=("$@")
  shift
  # first check PATH
  if command -v "$name" &>/dev/null; then
    command -v "$name"
    return 0
  fi
  # then check explicit paths
  for p in "$@"; do
    [[ -x "$p" ]] && echo "$p" && return 0
  done
  return 1
}

CLAUDE_BIN=$(find_binary claude \
  "$HOME/.local/bin/claude" \
  "/opt/homebrew/bin/claude" \
  "/usr/local/bin/claude" \
  "$HOME/.claude/local/claude" \
  "$HOME/Library/Application Support/ClaudeCode/claude" \
) || { echo "[morning-push] ERROR: claude binary not found"; CLAUDE_BIN=""; }

NODE_BIN=$(find_binary node \
  "/usr/local/bin/node" \
  "/opt/homebrew/bin/node" \
  "$HOME/.nvm/versions/node/$(ls $HOME/.nvm/versions/node 2>/dev/null | tail -1)/bin/node" \
) || { echo "[morning-push] WARN: node binary not found — MCP servers may not load"; NODE_BIN=""; }

echo "[morning-push] claude=$CLAUDE_BIN"
echo "[morning-push] node=$NODE_BIN"

# ── Load ntfy topic ─────────────────────────────────────────
# Priority: env var > .secrets/ntfy.env > state/schedules.md
NTFY_TOPIC="${NTFY_TOPIC:-}"

if [[ -z "$NTFY_TOPIC" && -f "$SECRETS_FILE" ]]; then
  source "$SECRETS_FILE" 2>/dev/null || true
fi

# (No fallback to state files — the topic works like a password; keep it in .secrets/ or env only.)

if [[ -z "$NTFY_TOPIC" ]]; then
  echo "[morning-push] ERROR: NTFY_TOPIC not configured."
  echo "[morning-push] Set it in:"
  echo "  1. $SECRETS_FILE  → NTFY_TOPIC=your-topic"
  echo "  2. Environment variable NTFY_TOPIC"
  # Never publish user data to a shared public topic — refuse to run instead.
  exit 1
fi

# ── Read state for briefing ─────────────────────────────────
TASKS_SUMMARY=""
if [[ -f "$BOS_DIR/state/tasks.md" ]]; then
  # First 25 lines = summary section per bOS Smart Context Loading spec
  TASKS_SUMMARY=$(head -25 "$BOS_DIR/state/tasks.md" 2>/dev/null | grep -E '^[-|*]|TODO|URGENT|overdue' | head -5 | tr '\n' ' ')
fi

CRITICAL_SIGNALS=""
if [[ -f "$BOS_DIR/state/context-bus.jsonl" ]]; then
  CRITICAL_SIGNALS=$(grep '"priority":"critical"' "$BOS_DIR/state/context-bus.jsonl" 2>/dev/null \
    | tail -2 \
    | sed -n 's/.*"content":"\([^"]*\)".*/\1/p' \
    | tr '\n' ' ')
fi

BUFFER_STATUS=""
if [[ -f "$BOS_DIR/state/finances.md" ]]; then
  BUFFER_STATUS=$(grep -i 'buffer' "$BOS_DIR/state/finances.md" 2>/dev/null | head -1 | sed 's/.*buffer[^:]*: *//' | cut -c1-40)
fi

DATE_LABEL=$(date '+%a %d.%m')  # e.g. "Thu 05.03"

echo "[morning-push] tasks_summary: ${TASKS_SUMMARY:-(empty)}"
echo "[morning-push] critical_signals: ${CRITICAL_SIGNALS:-(none)}"
echo "[morning-push] buffer: ${BUFFER_STATUS:-(unknown)}"

# ── Attempt 1: claude -p with MCP ───────────────────────────
PUSH_SUCCESS=0

if [[ -n "$CLAUDE_BIN" && -n "$NODE_BIN" ]]; then
  echo "[morning-push] Attempting claude -p ..."

  # Export node path so MCP stdio servers can find it
  export PATH="$(dirname "$NODE_BIN"):$PATH"

  # Pass ntfy config to MCP env
  export NTFY_TOPIC="$NTFY_TOPIC"
  export NTFY_BASE_URL="$NTFY_BASE_URL"

  # Build context string (injected into the prompt as data — no file reads by claude needed)
  CONTEXT_DATA="Date: $DATE_LABEL
Tasks: ${TASKS_SUMMARY:-(no tasks data)}
Critical: ${CRITICAL_SIGNALS:-(none)}
Buffer: ${BUFFER_STATUS:-(unknown)}"

  # Minimal prompt — saves tokens, focused task
  PROMPT="You are bOS morning push agent. Using the data below, call send_notification ONCE with:
- title: 'bOS $DATE_LABEL'
- message: max 250 chars, in the user's language, key tasks + critical alerts (if any). No markdown, plain text.
- priority: high
- tags: [\"sunrise\", \"calendar\"]
- topic: $NTFY_TOPIC

DATA:
$CONTEXT_DATA

Call send_notification now. No other output."

  if [[ "$DRY_RUN" == "1" ]]; then
    echo "[morning-push] DRY RUN — would call claude -p with prompt:"
    echo "$PROMPT"
    PUSH_SUCCESS=1
  elif [[ -f "$BOS_DIR/.mcp.json" ]]; then
    # Requires a notification MCP tool in your own .mcp.json (not shipped with bOS).
    "$CLAUDE_BIN" -p "$PROMPT" \
      --allowedTools "mcp__bos-compound__send_notification" \
      --mcp-config "$BOS_DIR/.mcp.json" \
      --output-format text \
      2>&1 | head -30 && PUSH_SUCCESS=1 || true
  else
    echo "[morning-push] No .mcp.json in $BOS_DIR — skipping claude -p, using curl fallback."
  fi

  if [[ "$PUSH_SUCCESS" -eq 1 ]]; then
    echo "[morning-push] claude -p succeeded."
  else
    echo "[morning-push] WARN: claude -p exited non-zero. Falling back to direct curl."
  fi
else
  echo "[morning-push] Skipping claude -p — binary not available. Using curl fallback."
fi

# ── Fallback: direct curl to ntfy.sh ────────────────────────
if [[ "$PUSH_SUCCESS" -eq 0 ]]; then
  echo "[morning-push] Fallback: curl to ntfy.sh ..."

  # Build a basic briefing message (max 250 chars)
  FALLBACK_MSG="$DATE_LABEL"
  [[ -n "$TASKS_SUMMARY" ]] && FALLBACK_MSG="$FALLBACK_MSG | $TASKS_SUMMARY"
  [[ -n "$CRITICAL_SIGNALS" ]] && FALLBACK_MSG="$FALLBACK_MSG | !! $CRITICAL_SIGNALS"
  FALLBACK_MSG="${FALLBACK_MSG:0:250}"  # hard cap

  if [[ "$DRY_RUN" == "1" ]]; then
    echo "[morning-push] DRY RUN — would curl to $NTFY_BASE_URL/<topic> with: $FALLBACK_MSG"
    echo "[morning-push] DRY RUN complete. Nothing was sent."
    exit 0
  fi

  CURL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Title: bOS $DATE_LABEL" \
    -H "Priority: high" \
    -H "Tags: sunrise,calendar" \
    -d "$FALLBACK_MSG" \
    "$NTFY_BASE_URL/$NTFY_TOPIC" 2>&1) || CURL_STATUS="ERR"

  if [[ "$CURL_STATUS" == "200" ]]; then
    echo "[morning-push] Fallback curl succeeded (HTTP 200)."
    PUSH_SUCCESS=1
  else
    echo "[morning-push] ERROR: Fallback curl failed (HTTP $CURL_STATUS)."
  fi
fi

# ── Done ─────────────────────────────────────────────────────
if [[ "$DRY_RUN" == "1" ]]; then
  echo "[morning-push] DRY RUN complete. Nothing was sent."
  exit 0
fi
if [[ "$PUSH_SUCCESS" -eq 1 ]]; then
  echo "$TODAY" > "$SENT_FILE"
  echo "[morning-push] DONE ✓ $(date '+%H:%M:%S') — marked $TODAY as sent"
  exit 0
else
  echo "[morning-push] DONE with errors ✗ $(date '+%H:%M:%S')"
  exit 1
fi
