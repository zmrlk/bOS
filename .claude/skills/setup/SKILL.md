---
name: Setup
description: "Onboard a bOS user, detection-first: silent scan → present what we know → confirm → max 5 gap questions → first value in under 3 minutes. Also handles profile refresh (review mode) when profile already exists."
user_invocable: true
command: /setup
---

# bOS — Setup v2 (detection-first)

## Filozofia (3 zdania)

Nikt dojrzały w tej kategorii nie wypytuje usera, kim jest — profil narasta z użycia. Setup WYKRYWA wszystko, co się da, prezentuje to do potwierdzenia i pyta wyłącznie o luki, których wykryć się nie da. Pierwsza wartość ma przyjść w ≤3 minuty, nie po ankiecie.

## Twarde reguły (obowiązują w każdym kroku)

1. **Najpierw skaner, potem usta.** Zanim napiszesz COKOLWIEK, uruchom `bash .claude/skills/setup/scripts/profile-scan.sh` (ścieżka względem katalogu bOS). Jego output decyduje o trybie i o tym, o co WOLNO zapytać.
2. **Nigdy nie pytaj o to, co wykryte albo zapisane.** Wartości z sekcji AUTO-DETECTED i wypełnione pola profilu = fakty do potwierdzenia jedną interakcją, nie pytania otwarte.
3. **Jedno pytanie naraz.** Nigdy nie wyrzucaj serii pytań. Każde pytanie = AskUserQuestion z klikalnymi opcjami (fallback: numerowane "1) 2) 3)"). Wyjątek: JEDNO otwarte pole tekstowe na cały setup (cel główny).
4. **Każdy krok pomijalne.** Opcja "Pomiń" w każdym AskUserQuestion. Pominięcie ≠ porażka — pole zostaje puste i wypełni się z użycia.
5. **Max 5 pytań o luki**, w kolejności `gaps_by_leverage` ze skanera. Wiek, gospodarstwo, zainteresowania NIE są w top 5 — wypełnią się same.
6. **Liczby w welcome = ze skanera** (skills/agents/hooks_wired). Zero obiecywania funkcji, których inwentarz nie potwierdza (Rule 18).
7. **Język = język usera** (language_guess ze skanera albo pierwsza wiadomość). Całość po wykrytym języku.
8. **Wznawialność.** Po każdym kroku dopisz stan do `state/.setup-progress.md`. Przerwana sesja → następna czyta ten plik i podejmuje od miejsca przerwania, bez powtarzania pytań. Po ukończeniu setupu SKASUJ ten plik.
9. **Sekrety tylko potwierdzaj faktem przechwycenia** — nigdy nie powtarzaj ich wartości.
10. **Staleness = informacja, nie zarzut.** "Sekcja Finance ma 154 dni — nadal aktualne?", nigdy "jesteś do tyłu".

## Krok 0 — SKANER (cicho, zero outputu do usera)

```bash
bash .claude/skills/setup/scripts/profile-scan.sh
```

Wynik `mode:` rozgałęzia flow:

| mode | Co robisz |
|------|-----------|
| FRESH_INSTALL | Kroki 1→6 poniżej |
| PARTIAL | Krok 1 (krótkie "widzę, że częściowo skonfigurowany"), potem od razu Krok 4 (tylko luki), Krok 5 |
| REVIEW | **Żadnych pytań od zera.** Pokaż kartę profilu (format z Kroku 6), zapytaj JEDNYM AskUserQuestion o stęchłe sekcje ("Finance 154d — aktualne?" / opcje: Aktualne / Zmieniło się / Pomiń) i zakończ. Całość ≤2 min |

## Krok 1 — WELCOME (krótki, uczciwy)

Jedna zwięzła ramka, liczby ze skanera, bez ściany tekstu:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🖥️ bOS — twój osobisty system
  [N_skills] skilli · [N_agents] agentów · pamięć, która rośnie z użycia
  Skonfiguruję się sam — potwierdzisz kilka rzeczy klikiem.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Jeśli skaner dał `name_guess` → AskUserQuestion: "Jesteś [name_guess]?" (Tak / Inne imię — wpiszę). Bez name_guess → jedno pytanie o imię (typed, jedyne obok celu).

## Krok 2 — JEDNA ZGODA NA ROZEJRZENIE SIĘ

AskUserQuestion (header "Zgoda"):
"Rozejrzę się po tym komputerze, żeby nie zadawać ci pytań: aplikacje, foldery Desktop/Documents (powierzchownie — nazwy, nie treść), kalendarz jeśli podpięty. Nic nie wysyłam na zewnątrz. OK?"
- "Jasne, rozejrzyj się" (Recommended)
- "Tylko to, co już wykryłeś (system/locale)"
- "Nic nie skanuj — sam opowiem"

Przy zgodzie: szybki skan (Desktop/Documents/Applications po nazwach, kalendarz przez MCP jeśli auth OK). Przy odmowie pełnej: jedno otwarte "Opowiedz w 2-3 zdaniach — czym się zajmujesz i w czym mam pomagać najbardziej?" i skacz do Kroku 4.

## Krok 3 — PREZENTACJA: "OTO CO WIEM"

Pokaż wnioski Z DOWODAMI (skaner + skan), jedna ramka:

```
👤 Co widzę
• Strefa/język/waluta: [tz], [język], [waluta] → z systemu
• Praca: [wniosek] → widzę [dowód: np. "Docker + DBeaver + Xcode — budujesz oprogramowanie"]
• Narzędzia: [top 3-5 istotnych appek]
• Kalendarz dziś: [jeśli dostępny]
• Znalazłem istniejącą pamięć Claude ([N] projektów) [jeśli existing_claude_memory_dirs > 0]
```

AskUserQuestion: "Zgadza się?" → "Tak, to ja" / "Prawie — poprawię" (open text co zmienić) / "Nie — opowiem sam".
Jeśli istnieje pamięć/wiki z poprzednich instalacji → dołóż opcję importu zamiast wywiadu.

## Krok 4 — LUKI (max 5 pytań, kolejność wg leverage ze skanera)

Pytaj TYLKO o pola z `gaps_by_leverage`, po jednym, każde pomijalne. Standardowy zestaw dla świeżej instalacji (jeśli w lukach):

1. **Cel główny** — JEDYNE otwarte pole: "Co ma się zmienić dzięki temu systemowi w ciągu 3 miesięcy?" (odpowiedź → primary_goal + pre-selekcja packów).
2. **Packi** — AskUserQuestion multiSelect (Business / Życie i nawyki / Zdrowie / Nauka), pre-podświetlone wg celu i skanu.
3. **Drabinka proaktywności** (pole `Proactive mode`) — AskUserQuestion:
   - Observer — tylko alerty, gdy coś się pali
   - Advisor — proponuję drafty i następne kroki, ty klepiesz (Recommended)
   - Assistant — sam porządkuję rutynę, pytam przy rzeczach zewnętrznych
   - Partner — wykonuję rutynę autonomicznie, raportuję
   Zapisz wprost w profile.md; hooki czytają to pole. Zasada niezależna od poziomu: śmiało wewnątrz (pliki, notatki, porządki), ZAWSZE pytaj przed działaniem na zewnątrz (mail, wiadomość, pieniądze).
4. **Styl komunikacji** — direct / casual / detailed / motivational.
5. **Tech comfort** — TYLKO jeśli nie wynika ze skanu appek (IDE/terminal = "I code", nie pytaj).

Konwersacyjnie: reaguj na odpowiedzi ("Sprinter? To ustawiam krótkie bloki") — rozmowa, nie formularz. Wzmianki o ludziach/frustracjach/ambicjach zapisuj do pamięci bez dopytywania.

## Krok 5 — PIERWSZA WARTOŚĆ (natychmiast po lukach, ≤3 min od startu)

Dowieź jedną realną rzecz wg packa/celu — nie obietnicę, artefakt:
- Business → szkic planu dnia z kalendarza / lista 3 najstarszych spraw z Desktop
- Życie → pierwszy nawyk w habits.md + jak go odhaczać
- Zdrowie → szkielet baseline'u (bez pytań o wagę — pola wypełnią się z użycia)
- Nauka → pierwsza rekomendacja pod cel z Kroku 4.1
Format: `[emoji] @Agent — [co dostajesz]` + ⏭️ Next step ≤30 min.

## Krok 6 — BUDOWA + ZAMKNIĘCIE (cicho, potem 1 karta)

Za kulisami: `profile.md` z profile-template.md (wypełnione pola + freshness = dziś), seedy state/ (tylko nagłówki wg SCHEMAS.md — Summary + pusta tabela), wpis do session-log ("setup ukończony" = pierwszy ślad systemu), SKASUJ `state/.setup-progress.md`.

Karta zamknięcia (jedna, krótka):

```
✅ Gotowe. Profil: [X] pól wypełnionych, reszta urośnie z rozmów.
Tryb proaktywności: [wybrany]. Zmienisz jednym zdaniem.
Warto znać: /task · /expense · /habit · [1 skill wg packa]
```

Bez wykładów o architekturze. User ma zacząć UŻYWAĆ.

## Odświeżanie profilu (wywołanie /setup przy mode: REVIEW)

To jest ten sam skill po miesiącach: skaner zgłasza stęchłe sekcje → jedna karta "co się zmieniło od [data]?" z listą TYLKO stęchłych pól jako AskUserQuestion (multiSelect: co nieaktualne) → aktualizuj wskazane → koniec. Nigdy pełny wywiad ponownie.

## Edge cases

- AskUserQuestion niedostępne → numerowane opcje, user wpisuje numer.
- Skaner padł (brak basha/uprawnień) → działaj jak FRESH_INSTALL, ale reguły 2-5 obowiązują nadal: wykryj locale/TZ ręcznie (`date`, `defaults read -g AppleLocale`), nie pytaj o wykrywalne.
- User ucieka w konkretne zadanie w trakcie → PRZERWIJ setup, zrób zadanie (to jest pierwsza wartość), dopisz .setup-progress i wróć do luk kiedy indziej.
- Crash/limit tokenów → .setup-progress.md niesie stan; następna sesja kontynuuje bez powtórek.
