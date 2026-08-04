---
name: Follow Up
description: "Automated follow-up scripts for [your-company] leads. When to follow up, what to say, how not to be pushy. Use when the user needs to follow up with a potential client or cold contact."
user_invocable: true
command: /follow-up
---

# /follow-up — Lead Follow-up Generator

Sprzedaż ginie w follow-upie. 80% deali zamykane jest po 5+ kontaktach — większość odpuszcza po 1.
Ten skill mówi: kiedy napisać, co napisać, jak nie być nachalnym.

**Agent:** @cmo (scripts) + @boss (timing + reminder)

---

## Data Sources (batch loading — 1 turn)

**Issue ALL reads in one batch:**
- `profile.md` (sekcje: Business, offer, brand_voice)
- `state/pipeline.md` (full) → lista aktualnych leadów i statusy

---

## Protocol

### Krok 1: Kontekst

AskUserQuestion:
- header: "Sytuacja"
- question: "Co się wydarzyło?"
- options:
  - "Wysłałem zimny kontakt, brak odpowiedzi" (description: "Follow-up po 3-5 dniach ciszy")
  - "Był meeting / rozmowa, czekam na decyzję" (description: "Follow-up po demo lub pierwszej rozmowie")
  - "Wysłałem ofertę/follow-up, brak odpowiedzi" (description: "Follow-up po wysłaniu wyceny")
  - "Klient powiedział 'nie teraz'" (description: "Zamknięty lead — kiedy i jak wrócić")

---

### Scenariusz A: Po zimnym kontakcie (brak odpowiedzi)

**Timing:**
- Follow-up 1: +4-5 dni od pierwszego kontaktu
- Follow-up 2: +7 dni od F1 (inna forma — np. zamiast LinkedIn → email)
- Follow-up 3: +14 dni od F2 (break-up message — ostatni)

**Generuj 3 gotowe wiadomości:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📨  Follow-up 1 — +5 dni
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[GOTOWY TEKST — max 3 zdania]
Kanał: [LinkedIn / email]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📨  Follow-up 2 — +7 dni
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[GOTOWY TEKST — nowa wartość lub pytanie]
Kanał: [inny niż F1]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📨  Follow-up 3 — Break-up message
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[GOTOWY TEKST — dajesz mu wyjście, ale zostawiasz furtkę]
Kanał: dowolny

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⏰  Przypomnienia:
  Jutro: wyślij F1
  [data]: wyślij F2
  [data]: wyślij F3
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Scenariusz B: Po meetingu (czekam na decyzję)

**Timing:**
- Follow-up: 24-48h po meetingu (póki jest świeży)
- Drugi: +5-7 dni jeśli brak odpowiedzi
- Trzeci: +10-14 dni (decision urgency — soft deadline)

**Struktura wiadomości po meetingu:**
1. Podziękowanie (1 zdanie) — konkretne, co było wartościowe
2. Podsumowanie key points (2-3 punkty max)
3. Jasne next step + pytanie (1 zdanie)

Jeśli [user] poda kontekst co było na meetingu → personalizuj.

---

### Scenariusz C: Po wysłaniu oferty

**Timing:**
- Follow-up: +3 dni ("Chciałem się upewnić że dotarło")
- Drugi: +7 dni ("Masz pytania do oferty?")
- Trzeci: +14 dni ("Pracujemy nad terminami — chcę wiedzieć czy to ma sens")

**Zasada:** Follow-up po ofercie NIE pyta o decyzję — pyta o pytania i wątpliwości.

---

### Scenariusz D: "Nie teraz" — kiedy wrócić

**Mapa powrotów:**

| Co powiedział | Kiedy wrócić | Jak wrócić |
|--------------|-------------|-----------|
| "Teraz mamy remont/wdrożenie" | +6-8 tygodni | "Pamiętam że miałeś [X] — jak minęło?" |
| "Nie ma budżetu w tym kwartale" | Po początku nowego kwartału | Triggerem: Q2 (kwiecień), Q3 (lipiec) |
| "Muszę to przemyśleć" | +2 tygodnie | Nowa informacja / case study |
| "Nie, dziękuję" | +3-6 miesięcy jeśli warto | Tylko jeśli coś istotnie się zmieniło |

Generuj: konkretną datę przypomnienia + gotową wiadomość na powrót.

---

## Zasady follow-upów [your-company]

**DO:**
- Zawsze nowa wartość w każdym follow-upie (nie tylko "czy się zastanowiłeś?")
- Krótko — max 5 zdań. Dłuższe = spam.
- Osobiste — jedno szczegółowe zdanie odnoszące się do ich firmy/sytuacji
- Pytanie zamknięte na końcu (tak/nie/kiedy) — nie otwarte
- Break-up message zawsze zostawia furtkę ("Jeśli się coś zmieni...")

**DON'T:**
- "Chciałem się przypomnieć" — najgorsze zdanie w follow-upie
- "Czy podjął Pan decyzję?" — presja, odstraszy
- Follow-up tego samego dnia — desperation signal
- Więcej niż 3 follow-upy bez odpowiedzi — koniec serii

---

## Integracja z pipeline

Jeśli `state/pipeline.md` istnieje i ma leady ze statusem "contacted" lub "proposal-sent":
- Automatycznie identyfikuj które leady potrzebują follow-upu (na podstawie daty ostatniego kontaktu)
- Proponuj: "Lead [X] nie miał kontaktu od [N] dni. Generuję follow-up?"

---

## Format odpowiedzi

Zawsze:
1. Gotowy tekst do skopiowania (w bloku)
2. Timing (kiedy wysłać)
3. Kanał (gdzie wysłać)
4. Jeden tip dlaczego ta struktura działa

⏭️ Next step: Skopiuj i wyślij F1 dziś.
