# Shared consume-once ping. Source after BOS_DIR is set.
# REAL on Claude/Codex (stdout into next turn). BEST-EFFORT on Grok (Read ping.md).
_bos_inject_ping() {
  local ping="$BOS_DIR/state/ping.md"
  if [ -f "$ping" ] && [ -s "$ping" ]; then
    echo "### Incoming ping (consume-once, next-turn only — not mid-generation)"
    cat "$ping"
    echo ""
    rm -f "$ping"
  fi
}
