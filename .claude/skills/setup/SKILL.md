---
name: Setup
description: "Onboard a bOS user, detection-first: silent scan → present what we know → first value → max 5 gap questions → done in under 3 minutes of user attention. Also handles profile refresh (review mode) when profile already exists."
user_invocable: true
command: /setup
---

# bOS — Setup v2.1 (detection-first; poprawki po symulacji e2e 08-04)

## Filozofia (3 zdania)

Nikt dojrzały w tej kategorii nie wypytuje usera, kim jest — profil narasta z użycia. Setup WYKRYWA wszystko, co się da, prezentuje to do potwierdzenia, dowozi pierwszą wartość PRZED pytaniami i pyta wyłącznie o luki, których wykryć się nie da. Kolejność jest święta: wartość przed ankietą, nigdy odwrotnie.

## Twarde reguły (obowiązują w każdym kroku)

1. **Najpierw skaner, potem usta.** Zanim napiszesz COKOLWIEK: `bash <KATALOG_BOS>/.claude/skills/setup/scripts/profile-scan.sh <KATALOG_BOS>` (pełna ścieżka — nie zakładaj cwd). Sekcja `gaps_by_leverage` = JEDYNE pola, o które wolno zapytać; skaner sam odejmuje wykryte i tnie do 5.
2. **Nigdy nie pytaj o to, co wykryte albo zapisane.** AUTO-DETECTED i wypełnione pola = potwierdzenie w JEDNEJ karcie prezentacji, nie osobne pytania.
3. **Jedno pytanie naraz**, każde jako AskUserQuestion (fallback: numerowane opcje). **System zadaje max DWA pytania otwarte**: imię (tylko przy WEAK/braku name_guess) i cel główny. Korekty inicjowane przez usera ("prawie — poprawię") nie liczą się do tego limitu, ale nie wolno ich prowokować dodatkowymi "a może coś jeszcze?".
4. **Każde pytanie pomijalne.** AskUserQuestion zawsze ma wbudowane "Other" — traktuj je i wpisane "pomiń" jako skip (pole zostaje puste, wypełni się z użycia). Przy <4 opcjach dodawaj jawną opcję "Pomiń".
5. **Budżet: max 5 pytań o luki + max 3 interakcje potwierdzające** (imię-confirm, zgoda, prezentacja). Razem ≤8. Skaner mówi WEAK przy name_guess-inicjałach → wtedy pytaj o imię wprost (1 typed zamiast 2 interakcji).
6. **Liczby w welcome = dosłownie ze skanera** (skills/agents/hooks_wired). Zero funkcji, których inwentarz nie potwierdza (Rule 18).
7. **Język: pierwsza wiadomość usera WYGRYWA z locale.** Brak wiadomości → language_guess ze skanera.
8. **Wznawialność.** Po każdym kroku aktualizuj `state/.setup-progress.md` w formacie:
   ```
   step: <ostatni ukończony>
   collected: pole=wartość; pole=wartość
   remaining_gaps: pole, pole
   ```
   Start sesji z istniejącym .setup-progress → przywitaj "dokończymy konfigurację? zostały [N] pytania" i kontynuuj od `remaining_gaps` — zero powtórek. Po ukończeniu SKASUJ plik.
9. **Sekrety tylko potwierdzaj faktem przechwycenia** — nigdy nie powtarzaj ich wartości.
10. **Staleness = informacja, nie zarzut.** "[Sekcja] ma [N] dni — nadal aktualne?", nigdy "jesteś do tyłu".

## Krok 0 — SKANER (cicho)

Uruchom skaner (reguła 1). `mode:` rozgałęzia flow:

| mode | Co robisz |
|------|-----------|
| FRESH_INSTALL | Kroki 1→6 |
| PARTIAL | Krótkie powitanie → Krok 3.5 (wartość) → Krok 4 (tylko `gaps_by_leverage`) → Krok 6 |
| REVIEW | Karta profilu + JEDNO AskUserQuestion multiSelect ze WSZYSTKIMI stęchłymi sekcjami naraz ("co się zmieniło?") → zaktualizuj wskazane (follow-up tylko dla zaznaczonych) → koniec. ≤2 interakcje przy braku zmian |

## Krok 1 — WELCOME (krótki, uczciwy)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🖥️ bOS — twój osobisty system
  [skills] skilli · [agents] agentów · pamięć, która rośnie z użycia
  Skonfiguruję się sam — potwierdzisz kilka rzeczy klikiem.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Imię: `name_guess` bez flagi WEAK → AskUserQuestion "Jesteś [name]?" (Tak / Inne imię / Pomiń). Z flagą WEAK albo bez guessa → jedno typed "Jak masz na imię?".

## Krok 2 — JEDNA ZGODA NA ROZEJRZENIE SIĘ

AskUserQuestion (header "Zgoda"): "Rozejrzę się po tym komputerze, żeby nie zadawać ci pytań: aplikacje, foldery Desktop/Documents (nazwy, nie treść), kalendarz jeśli podpięty. Nic nie wysyłam na zewnątrz. OK?"
- "Jasne, rozejrzyj się" (Recommended) / "Tylko to, co już wykryłeś" / "Nic nie skanuj — sam opowiem"

⚠️ Ta zgoda NIE obejmuje `~/.claude/projects/*` ani `~/bos-wiki` (pamięć innych instalacji). Jeśli skaner je zgłosił → OSOBNE pytanie o import, dopiero w Kroku 3.
Pełna odmowa → jedno otwarte "Opowiedz w 2-3 zdaniach — czym się zajmujesz i w czym mam pomagać?" (to zastępuje pytanie o cel z Kroku 4) → Krok 3.5.

## Krok 3 — PREZENTACJA: "OTO CO WIEM"

Jedna karta z dowodami (skaner + skan): strefa/język/waluta → z systemu · praca → wniosek + dowód ("Docker + DBeaver — budujesz oprogramowanie") · narzędzia · kalendarz dziś · [jeśli wykryto pamięć poprzednich instalacji: "znalazłem pamięć z [N] projektów Claude — zaimportować? (osobna zgoda)"].

AskUserQuestion "Zgadza się?" → "Tak, to ja" / "Prawie — poprawię" / "Nie — opowiem sam" / (Other=pomiń).
⚠️ Wnioski ze skanu appek to HIPOTEZY, nie fakty — laptop może być cudzy/służbowy. Odrzucenie prezentacji = wyrzuć wnioski, w tym tech_comfort.

## Krok 3.5 — PIERWSZA WARTOŚĆ (PRZED pytaniami — to jest sedno v2.1)

Natychmiast po prezentacji dowieź jeden mały artefakt z tego, co JUŻ masz:
- Kalendarz dostępny → "Twoje dziś w 3 punktach + jedna kolizja/luka, którą widzę"
- Desktop ze starymi plikami → "3 najstarsze sprawy wiszące na pulpicie — ogarnąć którąś?"
- Nic z powyższych (pusta maszyna / odmowa skanu) → przesuń ten krok ZA pytanie o cel (Krok 4.1) i zrób artefakt z celu: pierwszy task w /task albo pierwszy nawyk w /habit — to zawsze możliwe bez żadnych danych.
Artefakt jest STWIERDZENIEM, nie pytaniem — nie renderuj go jako AskUserQuestion (nie liczy się do budżetu). Format: `[emoji] @Agent — [artefakt]` + ⏭️ Next step ≤30 min. Potem dopiero pytania, sframowane jako "dostroję się — [N] szybkich pytań".

## Krok 4 — LUKI (wyłącznie `gaps_by_leverage` ze skanera, po jednym)

Kanoniczne brzmienia (użyj gdy pole jest w lukach):
1. **Primary goal** — JEDYNE otwarte: "Co ma się zmienić dzięki temu systemowi w 3 miesiące?"
2. **Active packs** — multiSelect (Business / Życie i nawyki / Zdrowie / Nauka), pre-podświetlone wg celu i skanu.
3. **Proactive mode** — drabinka (4 opcje = limit; skip przez "Other"):
   - Observer — tylko alerty, gdy coś się pali
   - Advisor — proponuję drafty i kroki, ty klepiesz (Recommended)
   - Assistant — sam porządkuję rutynę, pytam przy działaniach na zewnątrz
   - Partner — wykonuję rutynę autonomicznie, raportuję
   Zapisz do profile.md. Egzekwowanie: pole zapisywane POD przyszłe spięcie (faza F3) — dziś nic go jeszcze automatycznie nie czyta; traktuj wybór jako dyrektywę dla SIEBIE w tej i kolejnych sesjach. Niezależnie od poziomu: śmiało wewnątrz (pliki, notatki), ZAWSZE pytaj przed działaniem na zewnątrz (mail, wiadomość, pieniądze).
4. **Communication style** — direct / casual / detailed / motivational.
5. **Tech comfort** — pytaj, chyba że user POTWIERDZIŁ prezentację zawierającą wniosek o kodowaniu.

Reaguj konwersacyjnie na odpowiedzi; wzmianki o ludziach/frustracjach zapisuj do pamięci bez dopytywania.

## Krok 5 — DYSTRAKCJA / ZADANIE UŻYTKOWNIKA (w dowolnym momencie)

User prosi o konkretne zadanie w trakcie → PRZERWIJ setup i zrób zadanie (to JEST pierwsza wartość). Zadanie wymaga niepodpiętego konektora (np. maile bez Gmail MCP) → powiedz to wprost i zaproponuj podpięcie JAKO CZĘŚĆ zadania (1 interakcja zgody OAuth), nie wracaj do ankiety zamiast tego. Po zadaniu: "dokończymy 3 pytania konfiguracji teraz czy później?" — "później" = zapisz .setup-progress i ZAKOŃCZ; kontynuacja nastąpi na starcie następnej sesji (reguła 8), nie nachalnie w tej samej.

## Krok 6 — BUDOWA + ZAMKNIĘCIE (cicho, potem 1 karta)

Za kulisami: utwórz `profile.md` z profile-template.md — wpisz odpowiedzi usera ORAZ WSZYSTKIE wartości z AUTO-DETECTED (Language, Location, Currency, Timezone; freshness = dziś). Bez tego drugi /setup wraca do pełnej ankiety. **State/: twórz TYLKO brakujące pliki; istniejących NIGDY nie nadpisuj ani nie czyść** (read-before-write). Wpis do session-log ("setup ukończony"). SKASUJ `state/.setup-progress.md`.

```
✅ Gotowe. Profil: [X] pól, reszta urośnie z rozmów.
Tryb proaktywności: [wybrany] — zmienisz jednym zdaniem.
Warto znać: /task · /expense · /habit · [1 skill wg packa]
```

## Odświeżanie (mode: REVIEW)

Ten sam skill po miesiącach. Skaner podaje stęchłe sekcje PO NAZWIE → jedna karta + jedno multiSelect "co się zmieniło od [data]?" → follow-up tylko dla zaznaczonych → koniec. Nigdy pełny wywiad.

## Edge cases

- AskUserQuestion niedostępne → numerowane opcje.
- Skaner padł → tryb FRESH, ale reguły 2-5 obowiązują: wykryj locale/TZ ręcznie (`date`, `defaults read -g AppleLocale`), nie pytaj o wykrywalne.
- Crash/limit → .setup-progress.md (format w regule 8) niesie stan.
- Setup ukończony częściowo (user pominął pytania) → tryb liczony po CORE, więc kolejne /setup wejdzie w PARTIAL/REVIEW i dopyta tylko resztki — nigdy od zera.
