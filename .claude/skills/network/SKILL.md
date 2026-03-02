---
name: Relationship CRM
description: "Personal relationship manager — log contacts, track follow-ups, get reminded who to reach out to. Your network is your net worth."
user_invocable: true
command: /network
---

# /network — Relationship CRM

Relationships need maintenance. This helps you track who matters and when to reach out.

---

## Usage

- `/network` — summary: overdue follow-ups + stats
- `/network log "Name" "context"` — log a contact
- `/network who` — who should I reach out to?
- `/network add` — add new person to network

Natural language: "Spotkałem się z Anią" → parse + log automatically.

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → language, communication_style
- `state/network.md` (full, small file) → all contacts, tiers, follow-ups

If network.md doesn't exist → create with schema headers from SCHEMAS.md.

### Subcommand: `/network` (summary)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  👥  NETWORK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Inner circle: [X] people
  Active network: [Y] people
  Extended: [Z] people

  ⚠️ Overdue follow-ups:
  → [Name] — [tier] — last contact [X] days ago
  → [Name] — [tier] — last contact [Y] days ago

  Next 7 days:
  → [Name] — follow up by [date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Subcommand: `/network log "Name" "context"`

1. Fuzzy match name against network.md
2. If match found → update Last contact = today, add context to Notes
3. If no match → "Nie mam [Name] w sieci. Dodać? /network add"
4. Recalculate Follow-up date based on tier
5. Confirm: "✅ Zalogowano kontakt z [Name]. Następny follow-up: [date]."

**Natural language parsing:**
- "Spotkałem się z Anią" → log Ania, context: spotkanie
- "Dzwoniłem do Marka" → log Marek, context: telefon
- "Mail od Jana" → log Jan, context: email

### Subcommand: `/network who`

Sort contacts by staleness (most overdue first). Show top 3 with conversation starters:

```
  📞  KOGO DAWNO NIE WIDZIAŁEŚ?

  1. [Name] — [tier] — [X] dni temu
     💬 "[conversation starter based on Notes]"

  2. [Name] — [tier] — [Y] dni temu
     💬 "[conversation starter]"

  3. [Name] — [tier] — [Z] dni temu
     💬 "[conversation starter]"
```

### Subcommand: `/network add`

1. Ask for typed input: "Kogo dodajesz? (imię)"
2. Use `AskUserQuestion`:
   - header: "Tier"
   - options:
     - "🔵 Inner circle (5)" (description: "Najbliżsi — kontakt co 2 tygodnie")
     - "🟢 Active (50)" (description: "Aktywna sieć — kontakt co 1-2 miesiące")
     - "⚪ Extended (500)" (description: "Szeroka sieć — kontakt co 3-6 miesięcy")
3. Ask for context (typed): "Skąd go/ją znasz? (krótko)"
4. Add to network.md with today's date and calculated follow-up
5. Confirm: "✅ Dodano [Name] do [tier]. Follow-up: [date]."

## Context-Bus Signals

| Condition | Signal |
|-----------|--------|
| Inner circle overdue (7+ days past follow-up) | @mentor proactive nudge in /morning: "Dawno nie rozmawiałeś z [Name]. Napisz dziś?" |

## State Files
- **Read:** profile.md, network.md (full)
- **Write:** network.md

## Rules
1. Use AskUserQuestion for all choices
2. Max 2 context-bus signals per execution
3. All reads in 1 turn (parallel I/O)
4. Natural language input supported — parse names and context
5. Fuzzy match for names (partial, case-insensitive)
6. Never share contact details outside bOS — this is private data
7. Follow-up dates auto-calculated from tier
8. Language matches user's profile language
