#!/usr/bin/env bash
# profile-scan.sh — completeness scanner for bOS /setup (F1 detection-first, 2026-08-04)
# Zamiast ankiety: policz co JUŻ wiemy, wykryj co się da, zwróć TYLKO luki.
# Usage: profile-scan.sh [BOS_DIR]   (default: repo root two levels up from this script)
# Output: plain-text report for the model. Exit 0 always (degrade gracefully).

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOS_DIR="${1:-$(cd "$SCRIPT_DIR/../../../.." && pwd)}"
PROFILE="$BOS_DIR/profile.md"
TODAY_EPOCH=$(date +%s)

# ── Leverage map: pola Core wg tego, ile kontekstu odblokowują (10 = pytaj pierwsze) ──
# format: Field|leverage  (tylko pola, o które WOLNO zapytać przy luce)
LEVERAGE="Name|10
Primary goal|9
Active packs|9
Language|8
Tech comfort|8
Communication style|7
User type|6
Proactive mode|6
Location|4
Interests|3
Age|2
Household|2"

# ── 1. AUTO-DETECTED (nigdy o to nie pytaj — wykryte z systemu) ──
echo "== AUTO-DETECTED (use these, do NOT ask) =="
TZ_SYS=$(readlink /etc/localtime 2>/dev/null | sed 's|.*/zoneinfo/||') ; [ -n "${TZ_SYS:-}" ] && echo "timezone: $TZ_SYS"
LOCALE_SYS=$(defaults read -g AppleLocale 2>/dev/null || echo "${LANG:-}")
[ -n "$LOCALE_SYS" ] && echo "locale: $LOCALE_SYS"
LANG1=$(defaults read -g AppleLanguages 2>/dev/null | sed -n 's/[^"]*"\([a-z][a-z]\)[-"].*/\1/p' | head -1)
[ -n "${LANG1:-}" ] && echo "language_guess: $LANG1"
case "$LOCALE_SYS" in *PL*) echo "currency_guess: PLN";; *US*) echo "currency_guess: USD";; *GB*) echo "currency_guess: GBP";; *DE*|*FR*|*ES*|*IT*|*NL*) echo "currency_guess: EUR";; esac
GIT_NAME=$(git config --global user.name 2>/dev/null); [ -n "${GIT_NAME:-}" ] && echo "name_guess: $GIT_NAME (from git config — confirm, don't ask open)"
command -v git >/dev/null && echo "has_git: yes"
[ -d "$HOME/.claude/projects" ] && MEMDIRS=$(ls "$HOME/.claude/projects" 2>/dev/null | wc -l | tr -d ' ') && [ "$MEMDIRS" -gt 0 ] && echo "existing_claude_memory_dirs: $MEMDIRS (offer import, don't interview)"
[ -d "$HOME/bos-wiki" ] && echo "existing_bos_wiki: yes (offer import)"
ls /Applications 2>/dev/null | head -60 | tr '\n' ',' | sed 's/,$//' | awk '{print "apps_sample: " $0}'

# ── 2. SYSTEM INVENTORY (prawdziwe liczby do welcome — Rule 18, zero zmyślonych) ──
echo ""
echo "== SYSTEM INVENTORY (honest numbers for welcome screen) =="
N_SKILLS=$(find "$BOS_DIR/.claude/skills" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
N_AGENTS=$(find "$BOS_DIR/.claude/agents" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
N_HOOKS=$(grep -o '"command"' "$BOS_DIR/.claude/settings.json" 2>/dev/null | wc -l | tr -d ' ')
echo "skills: $N_SKILLS | agents: $N_AGENTS | hooks_wired: $N_HOOKS"

# ── 3. PROFILE COMPLETENESS ──
echo ""
echo "== PROFILE =="
if [ ! -f "$PROFILE" ]; then
  echo "mode: FRESH_INSTALL (no profile.md)"
  echo "gaps_by_leverage:"
  echo "$LEVERAGE" | sort -t'|' -k2 -rn | awk -F'|' '{print "  - " $1 " (leverage " $2 ")"}'
  exit 0
fi

# Parsuj wiersze tabel: | **Field** | value |
FILLED=0; EMPTY=0; GAPS=""
while IFS= read -r line; do
  FIELD=$(echo "$line" | sed -n 's/^| \*\*\([^*]*\)\*\* |.*/\1/p')
  [ -z "$FIELD" ] && continue
  VALUE=$(echo "$line" | awk -F'|' '{gsub(/^ +| +$/,"",$3); print $3}')
  # wartość pusta albo sam placeholder w nawiasach = luka
  if [ -z "$VALUE" ] || echo "$VALUE" | grep -q '^(.*)$'; then
    EMPTY=$((EMPTY+1))
    LEV=$(echo "$LEVERAGE" | grep "^$FIELD|" | cut -d'|' -f2)
    [ -n "${LEV:-}" ] && GAPS="$GAPS$FIELD|$LEV\n"
  else
    FILLED=$((FILLED+1))
  fi
done < "$PROFILE"

TOTAL=$((FILLED+EMPTY)); PCT=0; [ "$TOTAL" -gt 0 ] && PCT=$((FILLED*100/TOTAL))
echo "fields_filled: $FILLED / $TOTAL (${PCT}%)"

# Staleness z komentarzy freshness
echo "stale_sections:"
grep -n 'freshness: 20' "$PROFILE" 2>/dev/null | while IFS= read -r fl; do
  D=$(echo "$fl" | sed -n 's/.*freshness: \(20[0-9-]*\).*/\1/p')
  [ -z "$D" ] && continue
  D_EPOCH=$(date -j -f "%Y-%m-%d" "$D" +%s 2>/dev/null || date -d "$D" +%s 2>/dev/null || echo "$TODAY_EPOCH")
  AGE=$(( (TODAY_EPOCH - D_EPOCH) / 86400 ))
  [ "$AGE" -gt 30 ] && echo "  - line $(echo "$fl" | cut -d: -f1): ${AGE}d old (review, don't re-ask from scratch)"
done

if [ "$PCT" -ge 80 ]; then
  echo "mode: REVIEW (>=80% — read values back, ask 'still accurate?', NEVER re-interview)"
elif [ "$PCT" -ge 30 ]; then
  echo "mode: PARTIAL (fill gaps only, max 5 questions, leverage order)"
else
  echo "mode: FRESH_INSTALL"
fi

echo "gaps_by_leverage (ask ONLY these, top-down, max 5):"
printf "%b" "$GAPS" | sort -t'|' -k2 -rn | head -8 | awk -F'|' '{print "  - " $1 " (leverage " $2 ")"}'
[ -z "$GAPS" ] && echo "  (none — no questions allowed, review mode only)"
exit 0
