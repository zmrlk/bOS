#!/usr/bin/env bash
# check-telemetry-freshness.sh — ewaluator FM-5: "plik wygląda świeżo (mtime), dane martwe".
# NIE ufa mtime (session-end.sh sedem odświeża licznik Sessions co sesję) — czyta datę OKNA danych.
# Użycie: bash scripts/check-telemetry-freshness.sh [plik] ; STALE_DAYS=14 domyślnie. Exit 1 = FAIL.
set -euo pipefail
F="${1:-state/telemetry.md}"
STALE_DAYS="${STALE_DAYS:-14}"

[ -f "$F" ] || { echo "SKIP: $F missing"; exit 0; }

WINDOW_END=$(grep -m1 -oE '30d do [0-9]{4}-[0-9]{2}-[0-9]{2}' "$F" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || true)
if [ -z "$WINDOW_END" ]; then
  echo "FAIL: brak markera '30d do YYYY-MM-DD' w $F — nie da się zweryfikować świeżości danych"
  exit 1
fi

TODAY_EPOCH=$(date +%s)
WINDOW_EPOCH=$(date -j -f "%Y-%m-%d" "$WINDOW_END" +%s 2>/dev/null || date -d "$WINDOW_END" +%s)
AGE_DAYS=$(( (TODAY_EPOCH - WINDOW_EPOCH) / 86400 ))

if [ "$AGE_DAYS" -gt "$STALE_DAYS" ]; then
  echo "FAIL: $F — okno danych ma ${AGE_DAYS}d (koniec okna: $WINDOW_END, próg ${STALE_DAYS}d). Nie ufaj mtime. Napraw: python3 tools/aggregate-skill-runs.py"
  exit 1
fi
echo "OK: $F — okno danych do $WINDOW_END (${AGE_DAYS}d <= ${STALE_DAYS}d)"
exit 0

# Test regresji (odtwarza incydent FM-5):
#   echo '## Tool usage (30d do 2026-07-16, 4 473 calls)' > /tmp/t.md && touch /tmp/t.md
#   STALE_DAYS=14 bash scripts/check-telemetry-freshness.sh /tmp/t.md   # oczekiwane: FAIL mimo świeżego mtime
