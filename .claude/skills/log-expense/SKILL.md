---
name: Log Expense
description: "Log a personal or business expense. Quick entry for tracking spending."
user_invocable: true
command: /expense
---

# Log Expense

**Adapt to user_type:** Freelancer/Business → ask "personal or business?" for tax tracking. Employee/Student → default to personal.

## Usage
User provides: amount, category, description.
Examples:
- `/expense 150 food lunch with client`
- `/expense 49 tools cursor subscription`
- `I spent 200 on groceries`

## Protocol

### Parse input
Extract: amount, category, description, date (default: today).

Categories: food, transport, tools, entertainment, health, education, housing, business, other.

### Log

**Lite mode:** Append to `state/finances.md`:
```markdown
| [date] | [amount] [currency] | [category] | [description] |
```

**Pro mode:** INSERT into expenses table.

### Respond
```
"💰 Logged: [amount] [currency] — [category] ([description])
[If impulse flag detected]: ⚠️ Was this planned or impulse? No judgment, just tracking."
```

### Budget threshold check (after logging)

If @finance memory has `monthly_budget_thresholds` for this category:
1. Calculate: this month's total for category (from finances.md Active section)
2. Compare against budget:
   - **>80%**: "⚠️ [Category]: [X]% budżetu ([spent]/[budget] [currency]). Uważaj."
   - **>100%**: "🚨 [Category]: przekroczony budżet! [spent]/[budget] [currency] (+[overage])."
   - Post context-bus signal: @finance → @boss + @coach (constraint)
3. If no budget set for category → skip silently

### Impulse detection
Flag as potential impulse if:
- Category is entertainment, tools, or other
- Amount > 1 week of typical expenses
- Description includes: "just", "random", "why not", "treat"
If flagged → gentle note, don't lecture.

### Before logging
Read `profile.md` for: money_style, monthly_expenses, adhd_indicators, currency.
Read `state/finances.md` for: buffer current, this month's total.
- If buffer < target AND expense is non-essential → subtle note: "Buffer at [X]%. Just tracking."
- If adhd_indicators = yes → keep response very short, no lecture.

### Context-Bus Signals
After logging, post to `state/context-bus.md`:
- **Large expense (>10% monthly):** `@finance → @boss, Type: data, Priority: normal, TTL: 7 days, Content: "Large expense: [amount] [currency] — [category]. Monthly total now: [X]", Status: pending`
- **Impulse flagged:** `@finance → @coach, Type: insight, Priority: info, TTL: 7 days, Content: "Impulse expense flagged: [amount] [currency] — [description]", Status: pending`
- **Monthly spending exceeds budget:** `@finance → @boss + @cfo, Type: constraint, Priority: critical, TTL: 14 days, Content: "Monthly spending [amount] exceeds budget [budget]. Buffer impact.", Status: pending`

## State Files
- **Read:** state/finances.md, profile.md (money_style, monthly_expenses, adhd_indicators, currency)
- **Write:** state/finances.md, state/context-bus.md
