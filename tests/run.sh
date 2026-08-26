#!/usr/bin/env bash
# bOS test suite — plain bash, zero dependencies.
# Usage: bash tests/run.sh   (from the repo root or anywhere)
# Exit 0 = all green. Every failure prints FAIL with context.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0; FAIL=0

ok()   { PASS=$((PASS+1)); echo "  PASS $1"; }
bad()  { FAIL=$((FAIL+1)); echo "  FAIL $1 ${2:-}"; }

# ── Sandbox: a throwaway copy so tests never touch the real folder ──
SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/bos-tests-XXXXXX")"
trap 'rm -rf "$SANDBOX"' EXIT
( cd "$REPO" && tar cf - --exclude .git --exclude .memsearch --exclude tests . ) | ( cd "$SANDBOX" && tar xf - )

echo "== 1. Shell syntax (bash -n on every script) =="
for f in "$REPO"/.claude/hooks/*.sh "$REPO"/scripts/*.sh "$REPO"/update.sh "$REPO"/tests/run.sh; do
  if bash -n "$f" 2>/dev/null; then ok "syntax $(basename "$f")"; else bad "syntax $(basename "$f")"; fi
done

echo "== 2. Guard hook (protect-state.sh) =="
guard() { # name payload want_rc
  printf '%s' "$2" | bash "$SANDBOX/.claude/hooks/protect-state.sh" >/dev/null 2>&1
  local rc=$?
  if [ "$rc" = "$3" ]; then ok "guard $1"; else bad "guard $1" "(rc=$rc want=$3)"; fi
}
# must BLOCK (exit 2)
guard "rm-archive"        '{"tool_name":"Bash","command":"rm -rf state/archive/x"}' 2
guard "find-delete"       '{"tool_name":"Bash","command":"find state/archive -delete"}' 2
guard "truncate-backup"   '{"tool_name":"Bash","command":"truncate -s 0 state/.backup/a.md"}' 2
guard "interp-settings"   '{"tool_name":"Bash","command":"python3 -c x > .claude/settings.json"}' 2
guard "sed-settings-esc"  '{"tool_name":"Bash","command":"sed -i \"\" s/a/b/ .claude/settings.json"}' 2
guard "echo-bus"          '{"tool_name":"Bash","command":"echo x >> state/context-bus.jsonl"}' 2
guard "interp-bus"        '{"tool_name":"Bash","command":"node write.js state/context-bus.jsonl"}' 2
guard "helper-chain"      '{"tool_name":"Bash","command":"bash scripts/context-bus-append.sh a b insight info hi; echo x >> state/context-bus.jsonl"}' 2
guard "mv-archive"        '{"tool_name":"Bash","command":"mv state/archive/old.md /tmp/"}' 2
guard "redirect-archive"  '{"tool_name":"Bash","command":"echo x > state/archive/old.md"}' 2
guard "write-settings"    '{"tool_name":"Write","file_path":".claude/settings.json"}' 2
guard "write-archive"     '{"tool_name":"Write","file_path":"state/archive/old.md"}' 2
guard "edit-bus"          '{"tool_name":"Edit","file_path":"state/context-bus.jsonl"}' 2
# must ALLOW (exit 0)
guard "bus-helper"        '{"tool_name":"Bash","command":"bash scripts/context-bus-append.sh a b insight info hi"}' 0
guard "cat-settings"      '{"tool_name":"Bash","command":"cat .claude/settings.json"}' 0
guard "grep-bus"          '{"tool_name":"Bash","command":"grep critical state/context-bus.jsonl"}' 0
guard "ls-archive"        '{"tool_name":"Bash","command":"ls state/archive/"}' 0
guard "normal-write"      '{"tool_name":"Write","file_path":"state/tasks.md"}' 0
guard "empty-json"        '{}' 0
guard "garbage-stdin"     'not json at all' 0

echo "== 3. Bus helper (context-bus-append.sh) =="
bus() { ( cd "$SANDBOX" && bash scripts/context-bus-append.sh "$@" ) >/dev/null 2>&1; }
if bus "@boss" "ALL" "insight" "info" "test entry"; then ok "bus valid entry"; else bad "bus valid entry"; fi
if grep -q '"content":"test entry"' "$SANDBOX/state/context-bus.jsonl" 2>/dev/null; then ok "bus entry written"; else bad "bus entry written"; fi
if bus "@boss" "ALL" "nonsense-type" "info" "x"; then bad "bus rejects bad type"; else ok "bus rejects bad type"; fi
if bus "@boss" "ALL" "insight" "nonsense-prio" "x"; then bad "bus rejects bad priority"; else ok "bus rejects bad priority"; fi
if bus "@boss" "ALL" "calibration" "critical" "no keys here"; then bad "bus rejects calibration w/o keys"; else ok "bus rejects calibration w/o keys"; fi
if bus "@boss" "ALL" "calibration" "critical" "FACT: a | WAS: b | NOW: c | SOURCE: test"; then ok "bus accepts full calibration"; else bad "bus accepts full calibration"; fi
LONG=$(printf 'a%.0s' $(seq 1 2100))
if bus "@boss" "ALL" "insight" "info" "$LONG"; then bad "bus rejects >2000 chars"; else ok "bus rejects >2000 chars"; fi
if bus "@boss" 'x","injected":"y' "insight" "info" "x"; then bad "bus rejects bad to"; else ok "bus rejects bad to"; fi
TAB_CONTENT=$(printf 'col1\tcol2 "quoted" back\\slash')
if bus "@boss" "ALL" "insight" "info" "$TAB_CONTENT"; then ok "bus accepts tab/quote content"; else bad "bus accepts tab/quote content"; fi
if command -v python3 >/dev/null 2>&1; then
  if python3 - "$SANDBOX/state/context-bus.jsonl" <<'PYCHK'
import json,sys
ok=True
for i,line in enumerate(open(sys.argv[1]),1):
    line=line.strip()
    if not line: continue
    try: json.loads(line)
    except Exception as e: print(f"line {i}: {e}"); ok=False
sys.exit(0 if ok else 1)
PYCHK
  then ok "bus file is valid JSONL (every line parses)"; else bad "bus file is valid JSONL (every line parses)"; fi
fi

echo "== 4. Hooks survive empty and malformed stdin =="
for h in "$SANDBOX"/.claude/hooks/*.sh; do
  name=$(basename "$h")
  printf '' | bash "$h" >/dev/null 2>&1; rc1=$?
  printf '%s' '{{{broken' | bash "$h" >/dev/null 2>&1; rc2=$?
  if [ "$rc1" = 0 ] && [ "$rc2" = 0 ]; then ok "stdin-safe $name"; else bad "stdin-safe $name" "(rc empty=$rc1 broken=$rc2)"; fi
done

echo "== 5. session-start: overdue reminders =="
printf '# Reminders\n| 2020-01-01 17:00 | overdue thing | pending | high |\n| 2099-01-01 09:00 | future thing | pending | low |\n' > "$SANDBOX/state/reminders.md"
OUT=$(bash "$SANDBOX/.claude/hooks/session-start.sh" 2>/dev/null)
if echo "$OUT" | grep -q "overdue thing"; then ok "overdue reminder surfaced"; else bad "overdue reminder surfaced"; fi
if echo "$OUT" | grep -q "future thing"; then bad "future reminder filtered"; else ok "future reminder filtered"; fi
rm -f "$SANDBOX/state/reminders.md"

echo "== 6. Roster: clean pass + drift detection =="
if ( cd "$SANDBOX" && bash scripts/bos-roster.sh >/dev/null 2>&1 ); then ok "roster clean exit 0"; else bad "roster clean exit 0"; fi
mkdir -p "$SANDBOX/.claude/skills/zz-drift-fixture"
printf -- '---\nname: zz-drift-fixture\ndescription: "fixture"\n---\n# x\n' > "$SANDBOX/.claude/skills/zz-drift-fixture/SKILL.md"
if ( cd "$SANDBOX" && bash scripts/bos-roster.sh >/dev/null 2>&1 ); then bad "roster flags missing tier"; else ok "roster flags missing tier"; fi
rm -rf "$SANDBOX/.claude/skills/zz-drift-fixture"

echo "== 7. Data boundary (P0): user state never tracked =="
for f in state/finances.md state/journal.md state/tasks.md state/network.md; do
  if ( cd "$REPO" && git check-ignore -q "$f" ); then ok "gitignored $f"; else bad "gitignored $f"; fi
done
TRACKED_STATE=$( cd "$REPO" && git ls-files state/ | grep -vE '^state/(SCHEMAS\.md|context-bus\.md|\.gitkeep)$' | wc -l | tr -d ' ' )
if [ "$TRACKED_STATE" = "0" ]; then ok "only SCHEMAS/stub/.gitkeep tracked in state/"; else bad "only SCHEMAS/stub/.gitkeep tracked in state/" "($TRACKED_STATE extra)"; fi
TPL_COUNT=$(ls "$REPO/templates/state"/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$TPL_COUNT" -ge 15 ]; then ok "templates/state ships $TPL_COUNT templates"; else bad "templates/state ships templates" "(got $TPL_COUNT)"; fi
rm -f "$SANDBOX/state/tasks.md"
bash "$SANDBOX/.claude/hooks/session-start.sh" >/dev/null 2>&1
if [ -f "$SANDBOX/state/tasks.md" ]; then ok "session-start bootstraps missing state from template"; else bad "session-start bootstraps missing state from template"; fi

echo "== 8. Clean-clone: hooks never mutate shipped files =="
# Record checksums of everything that shipped, run every hook, then verify
# that any file which changed or appeared is gitignored in the real repo.
BEFORE="$SANDBOX/.before-sums"
( cd "$SANDBOX" && find . -type f ! -path './.before-sums' -exec cksum {} + | sort ) > "$BEFORE"
for h in "$SANDBOX"/.claude/hooks/*.sh; do printf '{}' | bash "$h" >/dev/null 2>&1; done
DIRTY=0
( cd "$SANDBOX" && find . -type f ! -path './.before-sums' -exec cksum {} + | sort ) > "$SANDBOX/.after-sums"
while IFS= read -r line; do
  f=$(echo "$line" | awk '{print $3}' | sed 's|^\./||')
  if ! ( cd "$REPO" && git check-ignore -q "$f" 2>/dev/null ); then
    if ( cd "$REPO" && git ls-files --error-unmatch "$f" >/dev/null 2>&1 ); then
      echo "  DIRTY tracked file: $f"; DIRTY=1
    fi
  fi
done < <(comm -13 "$BEFORE" "$SANDBOX/.after-sums")
if [ "$DIRTY" = 0 ]; then ok "no tracked file mutated by hooks"; else bad "no tracked file mutated by hooks"; fi

echo ""
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" = 0 ] || exit 1
exit 0
