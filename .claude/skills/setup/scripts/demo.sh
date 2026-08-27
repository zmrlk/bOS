#!/usr/bin/env bash
# demo.sh — 30-second try-before-setup for /setup.
# start: materialize the Alex fixture (templates/demo/) into state/ — ONLY on a
#        fresh install. Never touches profile.md, refuses if any real state
#        file it would create already exists.
# end:   remove exactly the files the manifest says start created, and nothing else.
# Usage: bash .claude/skills/setup/scripts/demo.sh start|end [BOS_DIR]
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CMD="${1:-}"
BOS_DIR="${2:-$(cd "$SCRIPT_DIR/../../../.." && pwd)}"
DEMO_SRC="$BOS_DIR/templates/demo"
MARKER="$BOS_DIR/state/.demo-mode"

fail() { printf 'DEMO-REFUSED: %s\n' "$1" >&2; exit 1; }

case "$CMD" in
  start)
    [ -d "$DEMO_SRC" ] || fail "templates/demo/ missing"
    [ -f "$MARKER" ] && fail "demo already running (state/.demo-mode exists) — run 'end' first"
    # Never shadow a filled profile: demo is for fresh installs only.
    if [ -f "$BOS_DIR/profile.md" ] && grep -qE '\| \*\*Name\*\* \| *[^ |(]' "$BOS_DIR/profile.md"; then
      fail "profile.md has a real Name — demo is for fresh installs only"
    fi
    # Never overwrite real state: refuse if any target exists.
    for SRC in "$DEMO_SRC"/*.md; do
      [ -e "$BOS_DIR/state/$(basename "$SRC")" ] && fail "state/$(basename "$SRC") already exists — will not overwrite"
    done
    mkdir -p "$BOS_DIR/state"
    : > "$MARKER"
    for SRC in "$DEMO_SRC"/*.md; do
      cp "$SRC" "$BOS_DIR/state/$(basename "$SRC")"
      printf 'state/%s\n' "$(basename "$SRC")" >> "$MARKER"
    done
    echo "DEMO-STARTED: fixture persona Alex materialized. Try /morning, /habit, 'spent 40 on lunch'."
    echo "DEMO-NOTE: every file is marked DEMO DATA; 'bash .claude/skills/setup/scripts/demo.sh end' removes all of it."
    ;;
  end)
    [ -f "$MARKER" ] || fail "no demo running (state/.demo-mode missing)"
    while IFS= read -r REL; do
      case "$REL" in state/*.md) rm -f "$BOS_DIR/$REL";; esac
    done < "$MARKER"
    rm -f "$MARKER"
    echo "DEMO-ENDED: fixture data removed. state/ is clean for the real setup."
    ;;
  *)
    echo "Usage: demo.sh start|end [BOS_DIR]"; exit 1;;
esac
exit 0
