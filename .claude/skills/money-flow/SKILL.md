---
name: Money Flow
description: "Cash flow visualization — see where your money goes with an ASCII waterfall chart. Income → expenses → savings → buffer."
user_invocable: true
command: /money-flow
---

# /money-flow — Cash Flow Visualization

See your money flow in one picture. Income in, expenses out, what's left.

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → income, currency
- `state/finances.md` (Summary + Active section) → expenses by category, budget, buffer

### Step 2: Data check

If no expenses logged or no income set:
"Potrzebuję danych. Zaloguj kilka wydatków (/expense) i ustaw dochód w profilu."
→ End skill.

### Step 3: Waterfall chart

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  💸  MONEY FLOW — [Month YYYY]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Income        ████████████████████  [amount]
                ↓
  Housing       ████████░░░░░░░░░░░░  -[amount]
  Food          ████░░░░░░░░░░░░░░░░  -[amount]
  Transport     ██░░░░░░░░░░░░░░░░░░  -[amount]
  Entertainment █░░░░░░░░░░░░░░░░░░░  -[amount]
  Other         █░░░░░░░░░░░░░░░░░░░  -[amount]
                ↓
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Remaining     ██████░░░░░░░░░░░░░░  [amount]
                ↓
  → Buffer      ████░░░░░░░░░░░░░░░░  +[amount]
  → Savings     ██░░░░░░░░░░░░░░░░░░  +[amount]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4: Monthly comparison (if 2+ months data)

If previous month's data exists:
```
  📊  PORÓWNANIE

  [Prev month]: [total spent] → [savings]
  [This month]: [total spent] → [savings]
  Trend: [↑/↓/→] [amount] [currency]
```

### Step 5: Insight

One actionable observation:
- Biggest category relative to income
- Category with biggest month-over-month change
- Buffer trajectory

## State Files
- **Read:** profile.md (income, currency), finances.md (S+Active)
- **Write:** none (read-only visualization)

## Rules
1. All reads in 1 turn (parallel I/O)
2. Summary-only reads for growing files where possible
3. Currency from profile.md
4. No new state files — reads existing finances.md
5. At least some expense data required — don't show empty chart
6. Bars proportional to income (income = full bar = 20 chars)
7. Language matches user's profile language
