---
name: Micro-Journal
description: "Micro-journal — one question, one answer. Daily reflection practice that builds self-awareness over time."
user_invocable: true
command: /reflect
---

# /reflect — Micro-Journal

One question. One honest answer. That's all.

**Adapt to communication_style:** direct → quick and clean. casual → warm tone. motivational → frame as growth practice.

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → communication_style, active_packs, language
- `state/journal.md` (full, small file) → past entries, last 7 Q#s used

If journal.md doesn't exist → create with schema headers from SCHEMAS.md.

### Step 2: Pick question

Select a random question from the pool (~50 questions). Exclude any Q# used in the last 7 entries.

Weight toward the user's active packs:
- Life active → more self-awareness, gratitude, energy questions
- Business active → more growth, future, decision questions
- Health active → more energy, body, recovery questions
- Learning active → more growth, curiosity questions

### Step 3: Show question

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🪞  REFLECT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [Question text]

  (Napisz cokolwiek. Bez oceniania.)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Wait for user's free-form text response. This is intentionally open — no selections, no structure.

### Step 4: Save

Append to `state/journal.md`:
```
| [today's date] | [Q#] | [question] | [user's answer] |
```

### Step 5: Acknowledge

Brief, warm acknowledgment:
"Zapisane. Dzięki za moment z sobą."

No analysis, no follow-up questions, no advice. Just acknowledgment.

### Step 6: 30-day analysis trigger

If journal.md has 30+ entries AND this runs during /review-week → @coach generates "Journal Patterns" section:
- Most common themes across answers
- Emotional trends (if detectable)
- Growth indicators (comparing early vs recent entries)

## Question Pool (~50, organized by category)

### Self-awareness (Q1-Q10)
1. Co dziś poszło lepiej niż się spodziewałeś?
2. Co Cię dziś zaskoczyło?
3. Gdybyś mógł cofnąć jedną decyzję z dziś — którą?
4. Co Cię dziś najbardziej denerwowało? Dlaczego?
5. W czym byłeś dziś najlepszą wersją siebie?
6. Co dziś zrobiłeś z przyzwyczajenia, a nie z wyboru?
7. Jaka myśl wracała do Ciebie cały dzień?
8. Co odkładasz, a wiesz że jest ważne?
9. Kiedy dziś czułeś się najbardziej sobą?
10. Co byś powiedział sobie z rana, gdybyś wiedział jak potoczy się dzień?

### Gratitude (Q11-Q20)
11. Za co jesteś dziś wdzięczny?
12. Kto dziś sprawił, że Twój dzień był lepszy?
13. Jaki mały moment dziś doceniasz?
14. Co masz, o czym rok temu marzyłeś?
15. Za jaką porażkę z przeszłości jesteś teraz wdzięczny?
16. Co w Twoim życiu działa dobrze i nie wymaga naprawy?
17. Kogo dawno nie doceniłeś?
18. Jaki zwykły element dnia sprawiłby Ci brak, gdyby zniknął?
19. Co dobrego wynika z Twojej obecnej sytuacji?
20. Za co w sobie jesteś wdzięczny?

### Growth (Q21-Q30)
21. Czego się dziś nauczyłeś?
22. W czym jesteś lepszy niż miesiąc temu?
23. Jaki nawyk chciałbyś mieć za rok?
24. Co Cię ostatnio przerosło? Czego to uczy?
25. Gdybyś miał mentora — co by Ci powiedział?
26. Jaka umiejętność otworzyłaby Ci największe drzwi?
27. Co robisz dobrze, ale mógłbyś robić świetnie?
28. Jaki błąd powtarzasz? Co go uruchamia?
29. Co by się zmieniło, gdybyś poważnie potraktował swój potencjał?
30. Jakie 1% improvement mógłbyś zrobić jutro?

### Energy (Q31-Q40)
31. Kiedy dziś miałeś najwięcej energii? Co ją dało?
32. Co Cię dziś najbardziej zmęczyło?
33. Czy odpoczywałeś dziś naprawdę, czy udawałeś?
34. Co zabiera Ci energię, a mogłoby nie?
35. Jak wyglądał Twój idealny dzień pod kątem energii?
36. Co możesz usunąć ze swojego jutra?
37. Kiedy ostatnio czułeś flow?
38. Co robisz dla zdrowia, a co dla nawyku?
39. Ile z dzisiejszej energii poszło na rzeczy, które mają znaczenie?
40. Co mogłoby Ci dać +1 do energii jutro?

### Future (Q41-Q45)
41. Gdzie chcesz być za 90 dni?
42. Co się stanie, jeśli nic nie zmienisz?
43. Czego boisz się chcieć?
44. Jaka decyzja Cię czeka, a Ty ją odkładasz?
45. Gdyby pieniądze nie grały roli — co byś robił?

### Relationships (Q46-Q50)
46. Z kim dawno nie rozmawiałeś, a chciałbyś?
47. Kto Ci pomógł dojść tam, gdzie jesteś?
48. Jaką relację chciałbyś wzmocnić?
49. Komu możesz pomóc w tym tygodniu?
50. Kto jest w Twoim życiu dlatego, że wybrał tam być?

## Context-Bus Signals

| Condition | Signal |
|-----------|--------|
| 3+ days without /reflect | @coach proactive nudge: "Masz chwilę na /reflect?" (during /morning or session-start) |

## State Files
- **Read:** profile.md, journal.md (full)
- **Write:** journal.md

## Rules
1. ONE question per session — never batch questions
2. Free-form text response — no selections for the answer
3. No analysis during the reflection — just save and acknowledge
4. 30-day analysis happens in /review-week, not here
5. Max 2 context-bus signals per execution
6. All reads in 1 turn (parallel I/O)
7. Language matches user's profile language
