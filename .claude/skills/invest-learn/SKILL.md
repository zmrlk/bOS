---
name: Invest Learn
description: "Interactive investment education — concepts, quizzes, market mechanics explained at your level. Use when user asks 'co to ETF?', 'jak dziala gielda?', 'explain DCA', or wants to learn about investing."
user_invocable: true
command: /invest-learn
---

# /invest-learn — Investment Education

Learn investing from zero. Concepts explained with YOUR numbers, not textbook examples.

---

## Usage

- `/invest-learn` — show current learning progress
- `/invest-learn "topic"` — learn about a specific concept
- `/invest-learn quiz` — test your knowledge, advance layers
- `/invest-learn glossary` — quick reference of key terms

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → language, user_type
- `state/portfolio.md` (Summary) → current holdings for real examples
- `state/finances.md` (Summary) → buffer status, monthly investment amount
- @investor memory → current investment_layer

### Subcommand: `/invest-learn` (show progress)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📚  INVESTMENT LEARNING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Layer: [1-4] — [name]
  ██████░░░░  [X]% do nastepnego

  Learned:
  ✅ [concept 1]
  ✅ [concept 2]
  🔄 [concept 3] — in progress

  Next up:
  ☐ [concept 4]
  ☐ [concept 5]

  /invest-learn quiz → sprawdź się
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Subcommand: `/invest-learn "topic"` (learn concept)

#### Step 2: Topic identification

Map topic to curriculum:

**Layer 1 — Novice Curriculum:**
1. Co to giełda i jak działa
2. Akcje vs obligacje vs ETF
3. Co to ETF i dlaczego to dobry start
4. DCA — regularne inwestowanie
5. IKE vs IKZE — ulga podatkowa
6. Ryzyko — co to znaczy i jak je mierzyć
7. Broker — jak wybrać i otworzyć konto
8. Pierwsza transakcja — krok po kroku
9. Koszty inwestowania (TER, prowizje, spread)
10. Inflacja — dlaczego gotówka traci wartość

**Layer 2 — Informed Curriculum:**
1. Dywersyfikacja geograficzna (US, EU, EM)
2. Sektory (tech, healthcare, energy)
3. P/E, P/B — podstawowe wskaźniki
4. Dywidendy — co, jak, kiedy
5. Rebalancing portfela
6. Obligacje skarbowe (EDO, ROD, TOS)
7. Korelacja aktywów
8. Benchmark — jak mierzyć swoje wyniki

**Layer 3 — Active Curriculum:**
1. Analiza fundamentalna firmy
2. Sentiment rynkowy
3. Cykle rynkowe (bull/bear)
4. Opcje — co to (awareness, nie trading)
5. REITs i nieruchomości
6. Tax-loss harvesting
7. Portfolio construction theory

#### Step 3: Explain with personalization

Structure every concept explanation:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📖  [CONCEPT NAME]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  W JEDNYM ZDANIU:
  [Simple, jargon-free definition]

  JAK TO DZIAŁA:
  [Explanation with user's real numbers]
  "Przy twoich 940 PLN/msc, to oznacza..."

  PRZYKŁAD Z ŻYCIA:
  [Everyday analogy]

  DLA CIEBIE KONKRETNIE:
  [How this applies to user's situation]

  ⚠️ PUŁAPKI:
  [1-2 common mistakes beginners make]

  ✅ ZAPAMIĘTAJ:
  [1-2 key takeaways]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Rules for explanation:**
- Use user's actual numbers (940 PLN, IKE, Polish context)
- Analogies from user's world (tech, business, ADHD-friendly)
- Max 20 lines per section
- Always end with "co dalej?" connecting to next concept

#### Step 4: Mark learned

After explanation, mark concept as learned in @investor memory.
If concept is from a higher layer than user's current → teach but note: "To jest z warstwy [X]. Basics first."

### Subcommand: `/invest-learn quiz`

Interactive quiz to test knowledge and potentially advance layers.

1. Pull 5 questions from current layer's curriculum (concepts marked as learned)
2. Use `AskUserQuestion` for each:

**Format per question:**
- header: "Q[N]"
- question: "[scenario-based question using user's real context]"
- options: 4 choices (1 correct, 3 plausible wrong)

3. Score: 4/5+ → "Świetnie! Solidna wiedza." | 3/5 → "Dobrze, ale wróć do [weak topics]" | <3/5 → "Powtórka z [topics]"
4. If all Layer N concepts learned + quiz 4/5+ → advance to Layer N+1. Signal @investor.

### Subcommand: `/invest-learn glossary`

Quick reference table of key terms at user's current layer.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📘  GLOSSARY — Layer [N]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  | Term | Meaning | Example |
  |------|---------|---------|
  | ETF  | Koszyk akcji w 1 instrumencie | VWCE = 3700 firm |
  | DCA  | Regularne kupowanie za stałą kwotę | 940 PLN/msc |
  ...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Context-Bus Signals

| Condition | Signal |
|-----------|--------|
| Layer advanced | `@investor → @boss + @coach, Type: data, Priority: info, TTL: 30d, Content: Investment knowledge: Layer [N] → [N+1]` |
| Quiz failed badly (<2/5) | `@investor → @teacher, Type: insight, Priority: low, TTL: 14d, Content: Investment quiz struggle. May need different teaching approach.` |

## State Files
- **Read:** profile.md, state/portfolio.md (S), state/finances.md (S)
- **Write:** none (updates @investor memory only)

## Rules
1. Use AskUserQuestion for all choices and quizzes
2. All reads in 1 turn (parallel I/O)
3. NEVER use financial jargon without immediate explanation
4. Always use user's real numbers in examples
5. Quiz questions are scenario-based, not definitional
6. Layer advancement requires BOTH: all concepts learned + quiz passed
7. Language = Polish (user's language)
8. Max 5 quiz questions per session
9. Celebrate progress — investing is hard, learning it is an achievement
