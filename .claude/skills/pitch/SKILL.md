---
name: Pitch
description: "[your-company] pitch practice and scripts. Quick mode gives a ready script, practice mode runs roleplay with objection handling. Use when the user needs to pitch [your-company] to a potential client."
user_invocable: true
command: /pitch
---

# /pitch — [your-company] Pitch Coach

Selling comfort 2/10 = #1 blocker. Ten skill likwiduje blokadę — gotowe skrypty, odpowiedzi na obiekcje, roleplay.

**Agent:** @sales (prowadzi) + @coach (motywacja + mindset)

---

## Data Sources (batch loading — 1 turn)

**Issue ALL reads in one batch:**
- `profile.md` (sekcje: Business, service, offer, target_audience, past_projects, selling_comfort)
- `state/pipeline.md` (full) → kontekst aktualnych leadów (jeśli istnieje)

---

## Protocol

### Krok 1: Tryb

AskUserQuestion:
- header: "Pitch mode"
- question: "Co chcesz zrobić?"
- options:
  - "Gotowy skrypt" (description: "Dostajesz gotową wiadomość/rozmowę do wysłania lub powiedzenia — bez ćwiczeń")
  - "Roleplay — zimny kontakt" (description: "Ćwiczymy pierwszy kontakt z [client]-type. Ja jestem potencjalnym klientem.")
  - "Roleplay — obiekcje" (description: "Ćwiczymy trudne pytania: cena, czas, 'mamy już kogoś', 'nie teraz'")
  - "Ocena mojego pitcha" (description: "Wklejasz swój draft, dostaję feedback + ulepszoną wersję")

---

### Tryb A: Gotowy skrypt

**Sub-tryby:**

AskUserQuestion:
- header: "Format kontaktu"
- question: "Jak chcesz nawiązać kontakt?"
- options:
  - "Wiadomość LinkedIn" (description: "Cold outreach, 150-200 znaków, bez sprzedaży na początku")
  - "SMS/WhatsApp" (description: "Bezpośredni, krótki, działa gdy masz numer z polecenia")
  - "Email cold" (description: "Dłuższy format, subject line + body + CTA")
  - "Pitch na żywo — otwieracz" (description: "Pierwsze 3 zdania do powiedzenia face-to-face lub na calu")

**Generuj skrypt na podstawie:**
- Offer [your-company] z profilu (diagnoza → naprawa → narzędzie)
- ICP: właściciel firmy 8-50 osób, chaos operacyjny, [client]-type
- Past projects jako social proof: VRS (37→120 sklepów), [company-B] ERP (produkcja kontenerów)
- Jeśli podano kontekst leada (z pipeline lub rozmowy) → personalizuj
- Brand voice: profesjonalny, bezpośredni, architekt w tle

**Format skryptu:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🎯  Skrypt — [format]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[GOTOWY TEKST DO SKOPIOWANIA]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  💡  Dlaczego to działa:
  - [3 zdania uzasadnienia]

  ⚡ Wariant B (bardziej bezpośredni):
  [alternatywna wersja]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Tryb B: Roleplay — zimny kontakt

Wejdź w postać [client]-type. Persony:
- **[client] (sceptyczny właściciel)** — "Mam już kogoś od IT, po co mi to?"
- **Marek (właściciel produkcji)** — "Co Ty mi tu będziesz mówił o mojej firmie?"
- **Ewa (właścicielka usług)** — "Ciekawe, ale ile to kosztuje?"

AskUserQuestion:
- header: "Wybierz persona"
- question: "Z kim ćwiczysz?"
- options:
  - "[client] — sceptyczny właściciel handlowy"
  - "Marek — właściciel firmy produkcyjnej"
  - "Ewa — właścicielka firmy usługowej"
  - "Losuj"

**Prowadź roleplay:**
1. Ja zaczynam jako klient — krótka sytuacja ("Hej, czym się zajmujesz?")
2. [user] odpowiada
3. Ja reaguję jako klient (naturalnie, nie ułatwiaj)
4. Po 3-4 wymianach: STOP → feedback (co zadziałało, co zmienić, lepsze sformułowanie)
5. AskUserQuestion: "Kontynuuj" / "Spróbuj jeszcze raz od początku" / "Przejdź do obiekcji" / "Skończ"

**Zasady roleplay:**
- Bądź autentycznym sceptykiem, nie pomagaj za bardzo
- Zadawaj trudne pytania które naprawdę padają: "Ale co konkretnie?", "Ile to kosztuje?", "A po co mi to?"
- Nie nagradzaj słabych odpowiedzi — reaguj jak prawdziwy klient

---

### Tryb C: Roleplay — obiekcje

Seria szybkich obiekcji. Format Q&A z feedbackiem.

**Top 6 obiekcji [your-company]:**
1. "Za drogo" / "Nie mam budżetu"
2. "Mamy już kogoś od IT/programistę"
3. "Nie teraz, mamy dużo na głowie"
4. "Co Ty wiesz o mojej branży?"
5. "Jak długo to trwa?"
6. "A co jeśli to nie zadziała?"

Dla każdej obiekcji:
- [user] odpowiada
- Ocena 1-10 + co było dobre + lepsza wersja odpowiedzi
- Gotowa odpowiedź do zapamiętania (max 3 zdania)

AskUserQuestion po każdej: "Następna obiekcja" / "Ćwicz tę jeszcze raz" / "Koniec"

---

### Tryb D: Ocena pitcha

[user] wkleja swój draft (wiadomość, email, co chce).

**Analiza:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📊  Ocena pitcha
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Wynik: [X]/10

✅ Co działa:
- [punkt 1]
- [punkt 2]

⚠️ Co zmienić:
- [punkt 1 z uzasadnieniem]
- [punkt 2 z uzasadnieniem]

📝 Poprawiona wersja:
[GOTOWY TEKST]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Pitch [your-company] — core message (zawsze aktualne)

**Problem który rozwiązujesz:**
Firma rośnie, ale zarządzanie zostało w Excelu i głowie właściciela. Chaos → błędy → stres → hamuje skalowanie.

**Co robisz:**
Wchodzisz, widzisz co nie działa, naprawiasz proces i budujesz narzędzie które to utrzymuje.

**Proof:** VRS dla [company-A] (37→120 sklepów bez nowego pracownika), [company-B] ERP (produkcja kontenerów — system zamówień i dokumentacji).

**Cena entry:** od 5 000 PLN (diagnoza) / 150 PLN/h

**Nie mówisz:** "jestem programistą", "robię aplikacje", "IT"
**Mówisz:** "porządkuję operacje i buduję narzędzia które to utrzymują"

---

## Zasady skilla

- Zawsze konkretne zdania do użycia — zero teorii
- Max 3 zdania w skrypcie otwierającym (uwaga klienta trwa 8 sekund)
- Nigdy nie zaczynaj od "My" lub "Ja" — zacznij od problemu klienta
- Social proof zawsze: VRS lub [company-B]
- Cena tylko gdy klient pyta — nie wcześniej

⏭️ Next step: Wyślij pierwszy zimny kontakt dziś.
