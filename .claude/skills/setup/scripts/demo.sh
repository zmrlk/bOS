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
    # First-run reality: session-start bootstraps state/ from blank templates
    # BEFORE /setup runs. A file byte-identical to its blank template is not
    # user data — it may be replaced (and is restored on 'end'). Anything the
    # user actually touched refuses, as before.
    for SRC in "$DEMO_SRC"/*.md; do
      NAME="$(basename "$SRC")"; DEST="$BOS_DIR/state/$NAME"; TPL="$BOS_DIR/templates/state/$NAME"
      if [ -e "$DEST" ] && ! { [ -f "$TPL" ] && cmp -s "$DEST" "$TPL"; }; then
        fail "state/$NAME has real content — will not overwrite"
      fi
    done
    mkdir -p "$BOS_DIR/state"
    : > "$MARKER"
    for SRC in "$DEMO_SRC"/*.md; do
      NAME="$(basename "$SRC")"; DEST="$BOS_DIR/state/$NAME"
      if [ -e "$DEST" ]; then KIND=blank; else KIND=new; fi
      cp "$SRC" "$DEST"
      printf '%s:state/%s\n' "$KIND" "$NAME" >> "$MARKER"
    done
    echo "DEMO-STARTED: fixture persona Alex materialized. Try /morning, /habit, 'spent 40 on lunch'."
    echo "DEMO-NOTE: every file is marked DEMO DATA; 'bash .claude/skills/setup/scripts/demo.sh end' removes all of it."
    ;;
  end)
    [ -f "$MARKER" ] || fail "no demo running (state/.demo-mode missing)"
    while IFS= read -r LINE; do
      KIND="${LINE%%:*}"; REL="${LINE#*:}"
      case "$REL" in
        state/*.md)
          rm -f "$BOS_DIR/$REL"
          # A file that was a bootstrapped blank template goes back to being one.
          if [ "$KIND" = blank ] && [ -f "$BOS_DIR/templates/$REL" ]; then
            cp "$BOS_DIR/templates/$REL" "$BOS_DIR/$REL"
          fi
          ;;
      esac
    done < "$MARKER"
    rm -f "$MARKER"
    echo "DEMO-ENDED: fixture data removed. state/ is clean for the real setup."
    ;;
  *)
    echo "Usage: demo.sh start|end [BOS_DIR]"; exit 1;;
esac
exit 0
