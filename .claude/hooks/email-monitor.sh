#!/usr/bin/env zsh
# ============================================================
# bOS — Email Monitor (every 15 min)
# Checks Gmail + Outlook for important emails, pushes via ntfy.
# Filters noise: system alerts, client notifications, parcel tracking
# ============================================================

set -euo pipefail

# ── Config ──────────────────────────────────────────────────
BOS_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/email-monitor-$(date '+%Y%m%d').log"
STATE_FILE="$BOS_DIR/state/.email-monitor-last-check"
SECRETS_FILE="$BOS_DIR/.secrets/ntfy.env"
NTFY_BASE_URL="${NTFY_BASE_URL:-https://ntfy.sh}"
COOLDOWN_FILE="$LOG_DIR/.email-monitor-cooldown"

# ── Logging ────────────────────────────────────────────────
mkdir -p "$LOG_DIR"
exec >> "$LOG_FILE" 2>&1
echo ""
echo "[email-monitor] $(date '+%H:%M:%S') START"

# ── Cooldown: max 1 push per 30 min ───────────────────────
# Prevents notification spam even if cron runs every 15 min
if [[ -f "$COOLDOWN_FILE" ]]; then
  LAST_PUSH=$(cat "$COOLDOWN_FILE" 2>/dev/null || echo "0")
  NOW_EPOCH=$(date '+%s')
  DIFF=$(( NOW_EPOCH - LAST_PUSH ))
  if [[ "$DIFF" -lt 1800 ]]; then
    echo "[email-monitor] Cooldown active (${DIFF}s < 1800s). Checking but won't push."
    PUSH_ALLOWED=0
  else
    PUSH_ALLOWED=1
  fi
else
  PUSH_ALLOWED=1
fi

# ── Environment ────────────────────────────────────────────
export LANG="pl_PL.UTF-8"
export LC_ALL="pl_PL.UTF-8"
[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh" --no-use 2>/dev/null || true
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin:$HOME/.nvm/versions/node/$(ls $HOME/.nvm/versions/node 2>/dev/null | tail -1)/bin:$PATH"

# ── Resolve claude binary ──────────────────────────────────
find_binary() {
  local name="$1"; shift
  command -v "$name" 2>/dev/null && return 0
  for p in "$@"; do [[ -x "$p" ]] && echo "$p" && return 0; done
  return 1
}

CLAUDE_BIN=$(find_binary claude \
  "$HOME/.local/bin/claude" \
  "/opt/homebrew/bin/claude" \
  "/usr/local/bin/claude" \
) || { echo "[email-monitor] ERROR: claude not found"; exit 1; }

echo "[email-monitor] claude=$CLAUDE_BIN"

# ── Load ntfy topic ─────────────────────────────────────────
NTFY_TOPIC="${NTFY_TOPIC:-}"
[[ -z "$NTFY_TOPIC" && -f "$SECRETS_FILE" ]] && source "$SECRETS_FILE" 2>/dev/null || true
[[ -z "$NTFY_TOPIC" ]] && { echo "[email-monitor] ERROR: NTFY_TOPIC not set"; exit 1; }

# ── Determine time window ──────────────────────────────────
if [[ -f "$STATE_FILE" ]]; then
  LAST_CHECK=$(cat "$STATE_FILE" 2>/dev/null)
  echo "[email-monitor] Last check: $LAST_CHECK"
else
  # First run — check last 30 minutes
  LAST_CHECK=$(date -v-30M '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date -d '30 minutes ago' '+%Y-%m-%dT%H:%M:%S')
  echo "[email-monitor] First run, checking last 30 min"
fi

NOW_ISO=$(date '+%Y-%m-%dT%H:%M:%S')

# ── Build the prompt ────────────────────────────────────────
PROMPT="You are bOS email monitor. Check both Gmail and Outlook for NEW important emails.

TIME WINDOW: since $LAST_CHECK

STEP 1 — Gmail:
Call gmail_search_messages with q='is:unread newer_than:1d -from:[company-system.com] -from:[client-company.com] -from:inpost -category:promotions -category:social' maxResults=10

STEP 2 — Outlook:
Call outlook_email_search with afterDateTime='$LAST_CHECK' limit=10
From Outlook results, IGNORE emails from these senders (system noise):
- powiadomienia@[company-system.com]
- noreply@[client-company.com]
- Any sender containing 'inpost'

STEP 3 — Evaluate:
Count truly important emails (not noise, not newsletters). Important = requires action, is from a real person, mentions money/deadline/urgent, or is a new B2B order.

STEP 4 — If 0 important emails:
Output exactly: NO_IMPORTANT

STEP 5 — If 1+ important emails:
Call send_notification with:
- topic: $NTFY_TOPIC
- title: '📬 bOS: [count] nowych maili'
- message: For each important email (max 5): '[sender short] — [subject]' on separate lines. Max 300 chars total. Polish. Plain text, no markdown.
- priority: default (or high if any email mentions payment/urgent/deadline)
- tags: [\"email\",\"inbox\"]

Then output: PUSHED:[count]

CRITICAL: Output ONLY 'NO_IMPORTANT' or 'PUSHED:[count]' as your final text. Nothing else."

# ── Run claude ──────────────────────────────────────────────
RESULT=$("$CLAUDE_BIN" -p "$PROMPT" \
  --allowedTools "mcp__claude_ai_Gmail__gmail_search_messages,mcp__claude_ai_Microsoft_365__outlook_email_search,mcp__bos-compound__send_notification" \
  --mcp-config "$BOS_DIR/.mcp.json" \
  --output-format text \
  2>&1 | tail -5) || RESULT="ERROR"

echo "[email-monitor] Result: $RESULT"

# ── Update state ────────────────────────────────────────────
echo "$NOW_ISO" > "$STATE_FILE"

if echo "$RESULT" | grep -q "PUSHED"; then
  date '+%s' > "$COOLDOWN_FILE"
  echo "[email-monitor] Push sent, cooldown started"
fi

echo "[email-monitor] $(date '+%H:%M:%S') DONE"
exit 0
