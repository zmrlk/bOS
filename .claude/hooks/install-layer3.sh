#!/usr/bin/env zsh
# ============================================================
# bOS Layer 3 — Installation Script
# Installs morning-push LaunchAgent + runs a dry-run test.
# Usage: zsh .claude/hooks/install-layer3.sh [--dry-run] [--uninstall]
# ============================================================

set -euo pipefail

# ── Paths ────────────────────────────────────────────────────
BOS_DIR="$HOME/bos"
PLIST_SRC="$BOS_DIR/com.bos.morning-push.plist"
PLIST_NAME="com.bos.morning-push"
PLIST_DEST="$HOME/Library/LaunchAgents/${PLIST_NAME}.plist"
HOOK_SCRIPT="$BOS_DIR/.claude/hooks/morning-push.sh"
LOG_DIR="$HOME/.claude/logs"
SECRETS_FILE="$BOS_DIR/.secrets/ntfy.env"

# ── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[0;33m'
BLU='\033[0;34m'
RST='\033[0m'

log()  { echo -e "${BLU}[install-layer3]${RST} $*"; }
ok()   { echo -e "${GRN}[install-layer3] ✓${RST} $*"; }
warn() { echo -e "${YLW}[install-layer3] ⚠${RST} $*"; }
err()  { echo -e "${RED}[install-layer3] ✗${RST} $*"; }

# ── Parse args ───────────────────────────────────────────────
DRY_RUN=0
UNINSTALL=0
for arg in "$@"; do
  [[ "$arg" == "--dry-run" ]] && DRY_RUN=1
  [[ "$arg" == "--uninstall" ]] && UNINSTALL=1
done

# ── Uninstall path ───────────────────────────────────────────
if [[ "$UNINSTALL" -eq 1 ]]; then
  log "Uninstalling $PLIST_NAME ..."
  launchctl unload "$PLIST_DEST" 2>/dev/null && ok "Unloaded from launchctl." || warn "Was not loaded."
  rm -f "$PLIST_DEST" && ok "Plist removed from LaunchAgents." || warn "Plist was not there."
  echo ""
  ok "Layer 3 uninstalled. Morning pushes stopped."
  exit 0
fi

echo ""
echo "┌────────────────────────────────────────────┐"
echo "│  bOS Layer 3 — Morning Push Installation   │"
echo "└────────────────────────────────────────────┘"
echo ""

# ── Pre-flight checks ────────────────────────────────────────
log "Running pre-flight checks ..."

ERRORS=0

# 1. Source plist exists
if [[ ! -f "$PLIST_SRC" ]]; then
  err "Plist not found: $PLIST_SRC"
  ERRORS=$((ERRORS + 1))
else
  ok "Plist source: $PLIST_SRC"
fi

# 2. Hook script exists and is executable
if [[ ! -f "$HOOK_SCRIPT" ]]; then
  err "Hook script not found: $HOOK_SCRIPT"
  ERRORS=$((ERRORS + 1))
else
  chmod +x "$HOOK_SCRIPT"
  ok "Hook script: $HOOK_SCRIPT (executable)"
fi

# 3. claude binary
CLAUDE_BIN=""
for p in \
  "$HOME/.local/bin/claude" \
  "/opt/homebrew/bin/claude" \
  "/usr/local/bin/claude" \
  "$HOME/.claude/local/claude"; do
  if [[ -x "$p" ]]; then CLAUDE_BIN="$p"; break; fi
done
command -v claude &>/dev/null && CLAUDE_BIN=$(command -v claude)

if [[ -z "$CLAUDE_BIN" ]]; then
  warn "claude binary not found in common locations. Fallback curl will be used."
  warn "Install: https://claude.ai/code  or  npm install -g @anthropic-ai/claude-code"
else
  ok "claude binary: $CLAUDE_BIN"
fi

# 4. node binary
NODE_BIN=""
command -v node &>/dev/null && NODE_BIN=$(command -v node)
[[ -z "$NODE_BIN" && -x "/usr/local/bin/node" ]] && NODE_BIN="/usr/local/bin/node"

if [[ -z "$NODE_BIN" ]]; then
  warn "node binary not found. MCP servers won't load — fallback curl will be used."
else
  ok "node binary: $NODE_BIN ($(node --version 2>/dev/null))"
fi

# 5. ntfy topic
NTFY_TOPIC="${NTFY_TOPIC:-}"
[[ -z "$NTFY_TOPIC" && -f "$SECRETS_FILE" ]] && source "$SECRETS_FILE" 2>/dev/null || true

if [[ -z "$NTFY_TOPIC" ]]; then
  warn "NTFY_TOPIC not configured."
  warn "Options:"
  warn "  A) Create $SECRETS_FILE with: NTFY_TOPIC=your-topic-name"
  warn "  B) Edit the plist NTFY_TOPIC key after install"
  warn "  C) Set env var: export NTFY_TOPIC=your-topic-name"
  echo ""
  read -r "TOPIC?  Enter your ntfy topic now (or press Enter to skip): "
  if [[ -n "$TOPIC" ]]; then
    mkdir -p "$(dirname "$SECRETS_FILE")"
    echo "NTFY_TOPIC=$TOPIC" > "$SECRETS_FILE"
    chmod 600 "$SECRETS_FILE"
    NTFY_TOPIC="$TOPIC"
    ok "Saved to $SECRETS_FILE"
    # Also patch the plist with the topic
    if [[ -f "$PLIST_SRC" ]]; then
      # Replace the empty NTFY_TOPIC string in plist
      sed -i '' "s|<key>NTFY_TOPIC</key>.*$|<key>NTFY_TOPIC</key>|" "$PLIST_SRC" 2>/dev/null || true
    fi
  else
    warn "Skipped. The script will look for topic in .secrets/ntfy.env at runtime."
  fi
else
  ok "NTFY_TOPIC: $NTFY_TOPIC"
fi

# 6. logs directory
mkdir -p "$LOG_DIR"
ok "Log directory: $LOG_DIR"

# 7. MCP compound server built
MCP_INDEX="$BOS_DIR/pcc/bos-compound-mcp/dist/index.js"
if [[ ! -f "$MCP_INDEX" ]]; then
  warn "bos-compound MCP not built: $MCP_INDEX"
  warn "Run: cd $BOS_DIR/pcc/bos-compound-mcp && npm run build"
else
  ok "bos-compound MCP: $MCP_INDEX"
fi

echo ""
[[ "$ERRORS" -gt 0 ]] && { err "$ERRORS critical error(s) found. Fix before installing."; exit 1; }

# ── Dry-run mode ─────────────────────────────────────────────
if [[ "$DRY_RUN" -eq 1 ]]; then
  log "DRY RUN — testing hook script now (no launchd install) ..."
  echo ""
  echo "━━━ DRY RUN OUTPUT ━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  # Run with DRY_RUN flag so script just prints what it would do
  MORNING_PUSH_DRY_RUN=1 zsh "$HOOK_SCRIPT" || true
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  ok "Dry run complete. Run without --dry-run to install."
  exit 0
fi

# ── Install plist ────────────────────────────────────────────
log "Installing LaunchAgent ..."

# Unload existing if already loaded (ignore errors)
launchctl unload "$PLIST_DEST" 2>/dev/null || true

# Copy plist with placeholder substitution
sed -e "s|REPLACE_WITH_HOME|$HOME|g" -e "s|REPLACE_WITH_USER|$USER|g" "$PLIST_SRC" > "$PLIST_DEST"
chmod 644 "$PLIST_DEST"
ok "Plist installed: $PLIST_DEST"

# Validate plist XML
if plutil -lint "$PLIST_DEST" &>/dev/null; then
  ok "Plist XML is valid."
else
  err "Plist XML validation failed. Check $PLIST_DEST"
  exit 1
fi

# Load it
launchctl load "$PLIST_DEST"
ok "LaunchAgent loaded."

# ── Verify status ────────────────────────────────────────────
log "Checking launchctl status ..."
sleep 1
STATUS=$(launchctl list | grep "$PLIST_NAME" || echo "not found")
echo "  $STATUS"

if echo "$STATUS" | grep -q "$PLIST_NAME"; then
  ok "LaunchAgent is registered."
else
  warn "Agent not visible in launchctl list yet (may need re-login on some macOS versions)."
fi

# ── Test run ─────────────────────────────────────────────────
echo ""
read -r "DO_TEST?Test send a notification now? [Y/n]: "
if [[ "${DO_TEST:-Y}" =~ ^[Yy]?$ ]]; then
  log "Triggering test run via launchctl start ..."
  echo ""
  launchctl start "$PLIST_NAME" 2>&1 || warn "launchctl start returned non-zero (check logs)"
  sleep 3
  TODAY_LOG="$LOG_DIR/morning-push-$(date '+%Y%m%d').log"
  echo ""
  log "Last 20 lines of log ($TODAY_LOG):"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  tail -20 "$TODAY_LOG" 2>/dev/null || echo "(log not yet written)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

# ── Summary ──────────────────────────────────────────────────
echo ""
echo "┌────────────────────────────────────────────┐"
echo "│  Installation complete                     │"
echo "└────────────────────────────────────────────┘"
echo ""
echo "  Schedule : 07:30 daily (weekdays)"
echo "  Plist    : $PLIST_DEST"
echo "  Hook     : $HOOK_SCRIPT"
echo "  Logs     : $LOG_DIR/morning-push-YYYYMMDD.log"
echo ""
echo "  Useful commands:"
echo "    Test now   : launchctl start $PLIST_NAME"
echo "    Status     : launchctl list | grep bos"
echo "    Uninstall  : zsh $BOS_DIR/.claude/hooks/install-layer3.sh --uninstall"
echo "    Logs today : tail -f $LOG_DIR/morning-push-$(date '+%Y%m%d').log"
echo ""
echo "  To change time: edit Hour/Minute in $PLIST_DEST"
echo "  then run: launchctl unload $PLIST_DEST && launchctl load $PLIST_DEST"
echo ""
