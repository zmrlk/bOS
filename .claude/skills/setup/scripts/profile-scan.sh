#!/usr/bin/env bash
# profile-scan.sh — completeness scanner for bOS /setup (v2.1 po symulacji e2e 2026-08-04)
# Zamiast ankiety: policz co JUŻ wiemy, wykryj co się da, zwróć TYLKO luki niewykrywalne.
# Usage: profile-scan.sh [BOS_DIR]   (default: repo root two levels up from this script)
# Output: plain-text report for the model. Exit 0 always (degrade gracefully).

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOS_DIR="${1:-$(cd "$SCRIPT_DIR/../../../.." && pwd)}"
PROFILE="$BOS_DIR/profile.md"
TODAY_EPOCH=$(date +%s)

# ── Leverage map: pola, o które WOLNO zapytać przy luce (10 = pytaj pierwsze) ──
LEVERAGE="Name|10
Primary goal|9
Active packs|9
Proactive mode|8
Communication style|7
Tech comfort|6
User type|5
Language|4
Location|3
Interests|2
Household|1
Age|1"

# ── 1. AUTO-DETECTED (nigdy o to nie pytaj — potwierdź w prezentacji) ──
echo "== AUTO-DETECTED (use these, do NOT ask; confirm in one presentation card) =="
DETECTED_FIELDS=""
TZ_SYS=$(readlink /etc/localtime 2>/dev/null | sed 's|.*/zoneinfo/||') ; [ -n "${TZ_SYS:-}" ] && echo "timezone: $TZ_SYS" && DETECTED_FIELDS="$DETECTED_FIELDS Timezone"
LOCALE_SYS=$(defaults read -g AppleLocale 2>/dev/null || echo "${LANG:-}")
[ -n "$LOCALE_SYS" ] && echo "locale: $LOCALE_SYS" && DETECTED_FIELDS="$DETECTED_FIELDS Location"
LANG1=$(defaults read -g AppleLanguages 2>/dev/null | sed -n 's/[^"]*"\([a-z][a-z]\)[-"].*/\1/p' | head -1)
[ -n "${LANG1:-}" ] && echo "language_guess: $LANG1 (tie-break: język PIERWSZEJ WIADOMOŚCI usera wygrywa z locale)" && DETECTED_FIELDS="$DETECTED_FIELDS Language"
case "$LOCALE_SYS" in *PL*) echo "currency_guess: PLN";; *US*) echo "currency_guess: USD";; *GB*) echo "currency_guess: GBP";; *DE*|*FR*|*ES*|*IT*|*NL*) echo "currency_guess: EUR";; esac
GIT_NAME=$(git config --global user.name 2>/dev/null)
if [ -n "${GIT_NAME:-}" ]; then
  if [ ${#GIT_NAME} -le 3 ] || ! echo "$GIT_NAME" | grep -qi '[aeiouy]'; then
    echo "name_guess: $GIT_NAME (WEAK — wygląda na inicjały; pytaj o imię wprost, nie marnuj klika na potwierdzenie)"
  else
    echo "name_guess: $GIT_NAME (confirm 1 klikiem, nie pytaj otwarcie)"
    DETECTED_FIELDS="$DETECTED_FIELDS Name"
  fi
fi
command -v git >/dev/null && echo "has_git: yes"
[ -d "$HOME/.claude/projects" ] && MEMDIRS=$(ls "$HOME/.claude/projects" 2>/dev/null | wc -l | tr -d ' ') && [ "$MEMDIRS" -gt 0 ] && echo "existing_claude_memory_dirs: $MEMDIRS (zaproponuj import — WYMAGA OSOBNEJ ZGODY, to inny zakres prywatności niż skan appek)"
[ -d "$HOME/bos-wiki" ] && echo "existing_bos_wiki: yes (import za osobną zgodą)"
ls /Applications 2>/dev/null | head -60 | tr '\n' ',' | sed 's/,$//' | awk '{print "apps_sample: " $0}'

# ── 2. SYSTEM INVENTORY (surowe liczby; welcome cytuje TE liczby, nie inne) ──
echo ""
echo "== SYSTEM INVENTORY (raw counts — welcome must not exceed these) =="
N_SKILLS=$(find "$BOS_DIR/.claude/skills" -maxdepth 2 -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
N_AGENTS=$(find "$BOS_DIR/.claude/agents" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
N_HOOKS=$(grep -o '"command"' "$BOS_DIR/.claude/settings.json" 2>/dev/null | wc -l | tr -d ' ')
echo "skills: $N_SKILLS | agents: $N_AGENTS | hooks_wired: $N_HOOKS"

# ── 3. PROFILE COMPLETENESS (tryb liczony po sekcji Core — reszta narasta z użycia) ──
echo ""
echo "== PROFILE =="
emit_gaps() {
  # $1 = raw gaps "Field|lev\n..."; filtruje pola pokryte auto-detekcją, cap 5
  local RAW="$1"
  local OUT=""
  while IFS='|' read -r F L; do
    [ -z "$F" ] && continue
    case " $DETECTED_FIELDS " in *" $F "*) continue;; esac
    OUT="$OUT$F|$L\n"
  done <<EOF
$(printf "%b" "$RAW")
EOF
  echo "gaps_by_leverage (ask ONLY these, top-down, HARD CAP 5 questions):"
  printf "%b" "$OUT" | sort -t'|' -k2 -rn | head -5 | awk -F'|' '{print "  - " $1 " (leverage " $2 ")"}'
  [ -z "$(printf "%b" "$OUT")" ] && echo "  (none — no questions allowed)"
}

if [ ! -f "$PROFILE" ]; then
  echo "mode: FRESH_INSTALL (no profile.md)"
  emit_gaps "$(echo "$LEVERAGE" | tr '\n' '\n')"
  exit 0
fi

CORE_FILLED=0; CORE_EMPTY=0; ALL_FILLED=0; ALL_EMPTY=0; GAPS=""; IN_CORE=0
while IFS= read -r line; do
  case "$line" in "## Core"*) IN_CORE=1;; "## "*) [ "$IN_CORE" = "1" ] && [ "${line#\#\# Core}" = "$line" ] && IN_CORE=0;; esac
  FIELD=$(echo "$line" | sed -n 's/^| \*\*\([^*]*\)\*\* |.*/\1/p')
  [ -z "$FIELD" ] && continue
  VALUE=$(echo "$line" | awk -F'|' '{gsub(/^ +| +$/,"",$3); print $3}')
  if [ -z "$VALUE" ] || echo "$VALUE" | grep -q '^(.*)$'; then
    ALL_EMPTY=$((ALL_EMPTY+1)); [ "$IN_CORE" = "1" ] && CORE_EMPTY=$((CORE_EMPTY+1))
    LEV=$(echo "$LEVERAGE" | grep "^$FIELD|" | cut -d'|' -f2)
    [ -n "${LEV:-}" ] && GAPS="$GAPS$FIELD|$LEV\n"
  else
    ALL_FILLED=$((ALL_FILLED+1)); [ "$IN_CORE" = "1" ] && CORE_FILLED=$((CORE_FILLED+1))
  fi
done < "$PROFILE"

CORE_TOTAL=$((CORE_FILLED+CORE_EMPTY)); CORE_PCT=0; [ "$CORE_TOTAL" -gt 0 ] && CORE_PCT=$((CORE_FILLED*100/CORE_TOTAL))
ALL_TOTAL=$((ALL_FILLED+ALL_EMPTY))
echo "core_filled: $CORE_FILLED / $CORE_TOTAL (${CORE_PCT}%) — MODE DECYDUJE CORE"
echo "all_fields: $ALL_FILLED / $ALL_TOTAL (reszta narasta z użycia, NIE pytaj o nią)"

# Staleness: linia freshness → nazwa sekcji (najbliższy nagłówek ## powyżej)
echo "stale_sections:"
grep -n 'freshness: 20' "$PROFILE" 2>/dev/null | while IFS= read -r fl; do
  LN=$(echo "$fl" | cut -d: -f1)
  D=$(echo "$fl" | sed -n 's/.*freshness: \(20[0-9-]*\).*/\1/p'); [ -z "$D" ] && continue
  D_EPOCH=$(date -j -f "%Y-%m-%d" "$D" +%s 2>/dev/null || date -d "$D" +%s 2>/dev/null || echo "$TODAY_EPOCH")
  AGE=$(( (TODAY_EPOCH - D_EPOCH) / 86400 ))
  if [ "$AGE" -gt 30 ]; then
    SEC=$(head -n "$LN" "$PROFILE" | grep '^## ' | tail -1 | sed 's/^## //')
    echo "  - ${SEC:-?}: ${AGE}d old (review — 'nadal aktualne?', nie pytaj od zera)"
  fi
done

if [ "$CORE_PCT" -ge 80 ]; then
  echo "mode: REVIEW (Core >=80% — read values back, 'still accurate?' na stęchłe sekcje JEDNYM multiSelect, NEVER re-interview)"
elif [ "$CORE_PCT" -ge 30 ]; then
  echo "mode: PARTIAL (fill gaps only)"
else
  echo "mode: FRESH_INSTALL"
fi
emit_gaps "$GAPS"
exit 0
