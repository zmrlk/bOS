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

### Impulse detection
Flag as potential impulse if:
- Category is entertainment, tools, or other
- Amount > 1 week of typical expenses
- Description includes: "just", "random", "why not", "treat"
If flagged → gentle note, don't lecture.
