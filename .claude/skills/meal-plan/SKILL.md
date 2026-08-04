---
name: Meal Plan
description: "Weekly meal plan with shopping list. Adapts to health goals, preferences, and budget. Use when the user needs a meal plan for the week or wants to plan their diet."
user_invocable: true
command: /meal-plan
---

# /meal-plan — Weekly Meal Planner

Jeden input → gotowy plan na cały tydzień + lista zakupów + szacunek kosztów.

**Agent:** @diet (plan) + @finance (koszty)

---

## Data Sources (batch loading — 1 turn)

**Issue ALL reads in one batch:**
- `profile.md` (sekcje: Health — dietary_restrictions, weight, height, body_type; Life — routines, sacred_rituals, available_slots)
- `state/finances.md` (Summary only) → sprawdź budżet na jedzenie

---

## Protocol

### Krok 1: Cel tygodnia

AskUserQuestion:
- header: "Cel"
- question: "Na co kładziesz nacisk w tym tygodniu?"
- options:
  - "Utrzymanie wagi i energii" (description: "Zbilansowany plan, dużo białka, stabilny poziom cukru")
  - "Maksymalna energia do pracy" (description: "Skupiamy się na peak hours 11-15 — co jeść żeby nie mieć zjazdu")
  - "Prosty i tani" (description: "Minimum gotowania, batch cooking, powtarzalne posiłki — liczy się czas i koszt")
  - "Dopasuj do moich danych" (description: "Sprawdzam profil i suggest na podstawie Twoich celów zdrowotnych")

---

### Krok 2: Preferencje (jeśli nie ma w profilu)

Sprawdź profile.md → dietary_restrictions, food_preferences.

Jeśli brak danych → AskUserQuestion (max 1):
- header: "Jedzenie"
- question: "Czego unikasz?"
- options:
  - "Nic, jem wszystko"
  - "Bez glutenu"
  - "Bez laktozy"
  - "Inne (powiem sam)"

---

### Krok 3: Generuj plan

**Format planu tygodniowego:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🍽️  Plan na tydzień — [daty]
  Cel: [wybrany cel] | Koszt est.: ~[X] PLN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PON-ŚR (dni biurowe — [location], mało czasu)
  Śniadanie: [szybkie, do ~5 min]
  Obiad: [można zabrać lub kupić na miejscu]
  Kolacja: [prosty, po powrocie]

CZW-PT (zdalne — więcej czasu)
  Śniadanie: [opcja na dłuższe przygotowanie]
  Obiad: [główny posiłek dnia — peak hours 11-15]
  Kolacja: [lekka, przed sauną]

SOB-ND (weekend)
  Batch cooking: [co przygotować na tydzień]
  [2-3 posiłki weekendowe]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🛒  Lista zakupów
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Białko: [lista]
Warzywa: [lista]
Węglowodany: [lista]
Inne: [lista]

Szacunek: ~[X] PLN / tydzień
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Zasady adaptacji do [user]a

**Rutyna biurowa (pon-śr):**
- Wyjazd 07:00, powrót 14-15:00
- Brak gotowania w południe → posiłek który można zabrać lub kupić
- Po powrocie: lekkie gotowanie max 20 min przed sauną 16:00

**Sauna 16:00-17:00:**
- Przed sauną: lekki posiłek lub nic ciężkiego (2h wcześniej)
- Po saunie: okno na normalne jedzenie

**Peak hours 11-15:**
- To jest czas największej produktywności — jedzenie nie może powodować sjesty
- Unikaj: ciężki obiad z makaronem, dużo cukru prostego, alkohol w południe
- Preferuj: białko + warzywa + małe porcje węglowodanów złożonych

**Transformacja 150kg → 72kg:**
- [user] ma doświadczenie z restrykcyjną dietą — nie traktuj go jak nowicjusza
- Nie moralizuj, nie pouczaj o podstawach
- Skup się na optymalizacji, nie edukacji

---

## Tryb szybki

`/meal-plan quick` — bez pytań, generuj od razu na podstawie profilu:
- 3 posiłki dziennie
- Max 20 min prep na posiłek
- Groceries list na jeden zakup tygodniowy
- Szacunek kosztów

---

## Integracja z finansami

Sprawdź `state/finances.md` → kategoria "Jedzenie" (budżet).
- Jeśli budżet ustawiony → trzymaj się go w planie
- Jeśli przekroczy 30% budżetu jedzenia → flag do @finance
- Jeśli brak budżetu → podaj szacunek, zaproponuj `/budget` żeby ustawić

⏭️ Next step: Wyślij listę zakupów na weekend.
