---
name: Budget Builder
description: "Interactive budget builder — create or review your 50/30/20 budget with spending categories from your history."
user_invocable: true
command: /budget
model: sonnet
---

# /budget — Interactive Budget Builder

Build a real budget from your real numbers. Or review the one you already have.

**Adapt to money_style:** Saver → optimize, show growth potential. Spender → gentle guardrails, visual impact. Anxious → reassure with exact numbers. Avoider → tiny steps, celebrate looking.

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → income, currency, money_style
- `state/finances.md` (Summary + Active section) → existing budget, expense categories, spending history

### Step 2: Budget exists?

**If Budget section exists in finances.md:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  💰  BUDGET STATUS — [Month YYYY]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [Category]  ▰▰▰▰▰▰▱▱▱▱  60% used
  [Category]  ▰▰▰▰▰▰▰▰▱▱  80% used  ⚠️
  [Category]  ▰▰▰▱▱▱▱▱▱▱  30% used
  ...

  Total: [spent] / [budget] ([%]%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then `AskUserQuestion`:
- header: "Co dalej?"
- options:
  - "📊 Szczegółowy widok" (description: "Pokaż wszystkie kategorie z kwotami")
  - "✏️ Zmień budżet" (description: "Dostosuj limity na ten miesiąc")
  - "✅ OK, wygląda dobrze" (description: "Zamknij")

**If no Budget section:** → go to Step 3 (build).

### Step 3: Income confirmation

Use `AskUserQuestion`:
- header: "Dochód miesięczny"
- options:
  - If income in profile.md → "[income] [currency] (z profilu)" (description: "Użyj tej kwoty")
  - "Podaj inną kwotę" (description: "Wpisz aktualny dochód")

If "Podaj inną kwotę" → ask for typed input.

### Step 4: Build 50/30/20 budget

Calculate:
- 50% Needs: housing, food, transport, bills, subscriptions
- 30% Wants: entertainment, dining out, hobbies, discretionary
- 20% Savings/Debt: buffer, savings, debt repayment

Auto-suggest categories from expense history (if any expenses logged):
- Parse finances.md expense log for categories used
- Pre-fill amounts based on average spending per category

Show proposed budget:
```
  📊  BUDGET — [Month YYYY]

  NEEDS (50% = [amount] [currency]):
  │ Housing      [amount]
  │ Food         [amount]
  │ Transport    [amount]
  │ Bills        [amount]

  WANTS (30% = [amount] [currency]):
  │ Entertainment [amount]
  │ Dining out    [amount]
  │ Discretionary [amount]

  SAVE (20% = [amount] [currency]):
  │ Buffer        [amount]
  │ Savings       [amount]

  ━━━━━━━━━━━━━━━━━━━━━━━━
  Total: [income] [currency]
```

Use `AskUserQuestion`:
- header: "Wygląda dobrze?"
- options:
  - "✅ Zapisz" (description: "Zapisuję budżet")
  - "✏️ Zmień kategorie" (description: "Dopasuj kwoty")

### Step 5: Save and configure alerts

Write budget to `state/finances.md` → Budget section.
Update Summary immediately (financial safety — per CLAUDE.md rules).

Store in @finance memory:
```
budget_thresholds:
  - category: [name]
    budgeted: [amount]
    warn_at: 80%
    alert_at: 100%
```

### Step 6: Confirmation

```
✅ Budżet zapisany na [month].

@finance będzie sprawdzać wydatki przy każdym /expense:
→ 80%+ → ostrzeżenie
→ 100%+ → alert

⏭️ Zaloguj pierwszy wydatek: /expense [kwota] [kategoria]
```

## Context-Bus Signals

| Condition | Signal |
|-----------|--------|
| Budget created | `@finance → @boss, Type: data, Priority: info, TTL: 30 days, Content: Budget created for [month]. Total: [amount].` |
| Category exceeded 100% | `@finance → @boss + @coach, Type: constraint, Priority: normal, TTL: 7 days, Content: Budget exceeded in [category]: [spent]/[budget].` |

## State Files
- **Read:** profile.md (income, currency), finances.md (S+Active, budget, expenses)
- **Write:** finances.md (Budget section, Summary)

## Rules
1. Use AskUserQuestion for all choices
2. Max 2 context-bus signals per execution
3. All reads in 1 turn (parallel I/O)
4. Summary-only reads for growing files
5. Always update finances.md Summary immediately after budget write (financial safety)
6. Adapt money_style framing throughout
7. Currency from profile.md
