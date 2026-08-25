---
name: network
description: "Personal relationship manager — log contacts, track follow-ups, get reminded who to reach out to. Your network is your net worth. Use to log meetings, track follow-ups, or see who needs outreach. Trigger on: contact, networking, follow-up."
user_invocable: true
command: /network
tier: optional
---

# /network — Relationship CRM

Relationships need maintenance. This helps you track who matters and when to reach out.

---

## Usage

- `/network` — summary: overdue follow-ups + stats
- `/network log "Name" "context"` — log a contact
- `/network who` — who should I reach out to?
- `/network add` — add new person to network

Natural language: "I met with Ania" → parse + log automatically.

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
3. If no match → "I don't have [Name] in the network. Add them? /network add"
4. Recalculate Follow-up date based on tier
5. Confirm: "✅ Logged contact with [Name]. Next follow-up: [date]."

**Natural language parsing:**
- "I met with Ania" → log Ania, context: meeting
- "I called Marek" → log Marek, context: phone call
- "Email from Jan" → log Jan, context: email

### Subcommand: `/network who`

Sort contacts by staleness (most overdue first). Show top 3 with conversation starters:

```
  📞  WHO HAVEN'T YOU SEEN IN A WHILE?

  1. [Name] — [tier] — [X] days ago
     💬 "[conversation starter based on Notes]"

  2. [Name] — [tier] — [Y] days ago
     💬 "[conversation starter]"

  3. [Name] — [tier] — [Z] days ago
     💬 "[conversation starter]"
```

### Subcommand: `/network add`

1. Ask for typed input: "Who are you adding? (name)"
2. Use `AskUserQuestion`:
   - header: "Tier"
   - options:
     - "🔵 Inner circle (5)" (description: "Closest people — contact every 2 weeks")
     - "🟢 Active (50)" (description: "Active network — contact every 1-2 months")
     - "⚪ Extended (500)" (description: "Wide network — contact every 3-6 months")
3. Ask for context (typed): "How do you know them? (briefly)"
4. Add to network.md with today's date and calculated follow-up
5. Confirm: "✅ Added [Name] to [tier]. Follow-up: [date]."

## Context-Bus Signals

| Condition | Signal |
|-----------|--------|
| Inner circle overdue (7+ days past follow-up) | @coach proactive nudge in /morning: "Haven't talked to [Name] in a while. Message them today?" |

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
