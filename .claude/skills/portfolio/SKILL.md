---
name: Portfolio
description: "Track your investment portfolio — holdings, allocation, performance, DCA log. Use when user says 'moj portfel', 'portfolio', 'dodaj transakcje', 'ile mam', or wants to manage investment holdings."
user_invocable: true
command: /portfolio
---

# /portfolio — Investment Portfolio Tracker

Track what you own, how it performs, and whether you're on plan.

---

## Usage

- `/portfolio` — show current portfolio
- `/portfolio add` — log a new transaction (buy/sell)
- `/portfolio plan` — show target allocation vs actual
- `/portfolio history` — transaction history

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `state/portfolio.md` (full) → holdings, transactions, targets
- `state/finances.md` (Summary) → buffer status, monthly investment amount
- @investor memory → investment_layer, DCA schedule

### Subcommand: `/portfolio` (show current)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  💼  PORTFOLIO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Wartość: ~[total] PLN
  Zainwestowano: [total invested] PLN
  Zysk/Strata: [+/-X] PLN ([%])

  | Holding | Ilość | Kurs | Wartość | Waga | Zysk |
  |---------|-------|------|---------|------|------|
  | [X]     | [n]   | [p]  | [v]     | [%]  | [%]  |

  DCA: [amount] PLN/msc → [target]
  Następny przelew: ~[date]
  Buffer: [X months] ✅/⚠️
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If portfolio empty → "Portfel pusty. /portfolio add żeby dodać pierwszą transakcję."

### Subcommand: `/portfolio add`

Use `AskUserQuestion`:

**Selection 1** (header: "Typ"):
- Kupno
- Sprzedaż
- Dywidenda

**Selection 2** (header: "Instrument"):
- Generate options from existing holdings + "Nowy instrument"

If "Nowy instrument" → ask for ticker/name.

**Open fields (typed):**
- "Ilość jednostek: ___"
- "Cena za jednostkę: ___ [waluta]"
- "Data transakcji: ___ (domyślnie: dziś)"

After input:
1. Write transaction to `state/portfolio.md` → Transaction Log
2. Update Holdings section (recalculate quantity, avg price, allocation %)
3. Update Summary
4. Confirm: "✅ Zapisane: [action] [qty] x [instrument] @ [price]"

### Subcommand: `/portfolio plan`

Show target vs actual allocation:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🎯  ALLOCATION PLAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  | Klasa       | Cel  | Teraz | Drift |
  |-------------|------|-------|-------|
  | Akcje (ETF) | 80%  | 75%   | -5%   |
  | Obligacje   | 15%  | 20%   | +5%   |
  | Gotówka     | 5%   | 5%    | 0%    |

  📋 Rebalancing:
  → Następne DCA 940 PLN → 100% w akcje ETF
    (wyrównuje drift)

  Następny pełny rebalancing: [date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If no target allocation set → use `AskUserQuestion`:
- header: "Profil"
- options from @investor risk_profile:
  - Conservative (20/70/10 equity/bonds/cash)
  - Moderate (60/30/10)
  - Aggressive (90/5/5)

### Subcommand: `/portfolio history`

Show transaction log from portfolio.md:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📜  TRANSACTION HISTORY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  | Data | Typ | Instrument | Ilość | Cena | Wartość |
  |------|-----|------------|-------|------|---------|
  | [d]  | BUY | [x]        | [n]   | [p]  | [v]    |
  ...

  Razem zainwestowane: [total] PLN
  Liczba transakcji: [N]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## State Files
- **Read:** state/portfolio.md (full), state/finances.md (S)
- **Write:** state/portfolio.md

## Rules
1. Use AskUserQuestion for all choices
2. All reads in 1 turn (parallel I/O)
3. ALWAYS check buffer before showing "invest more" suggestions
4. Prices from last /stock-check or WebSearch — never fabricate
5. PLN as primary currency, show original currency in parentheses
6. Update Summary section after every write
7. Language = Polish
8. "To nie jest porada inwestycyjna" on first use
