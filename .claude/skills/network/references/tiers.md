<!-- Loaded by network/SKILL.md — reference detail, not a skill. -->

# /network — tiers, layouts, flows

## Tier system

| Tier | Size | Follow-up cadence |
|------|------|-------------------|
| 🔵 Inner circle | ~5 people | every 2 weeks |
| 🟢 Active | ~50 people | every 1–2 months |
| ⚪ Extended | ~500 people | every 3–6 months |

The tier drives everything: logging a contact recalculates the next follow-up date from the tier; `/network who` ranks by how far past that date each person is.

## Summary layout (`/network`, no args)

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

## `who` layout

```
  📞  WHO HAVEN'T YOU SEEN IN A WHILE?

  1. [Name] — [tier] — [X] days ago
     💬 "[conversation starter based on Notes]"

  2. [Name] — [tier] — [Y] days ago
     💬 "[conversation starter]"

  3. [Name] — [tier] — [Z] days ago
     💬 "[conversation starter]"
```

## `log` flow

1. Fuzzy match the name against network.md.
2. Match found → update Last contact = today, add context to Notes.
3. No match → "I don't have [Name] in the network. Add them? /network add"
4. Recalculate the follow-up date from the tier.
5. Confirm: "✅ Logged contact with [Name]. Next follow-up: [date]."

**Natural language parsing:**
- "I met with Ania" → log Ania, context: meeting
- "I called Marek" → log Marek, context: phone call
- "Email from Jan" → log Jan, context: email

## `add` flow

1. Typed input: "Who are you adding? (name)"
2. AskUserQuestion — header: "Tier", options:
   - "🔵 Inner circle (5)" — description: "Closest people — contact every 2 weeks"
   - "🟢 Active (50)" — description: "Active network — contact every 1-2 months"
   - "⚪ Extended (500)" — description: "Wide network — contact every 3-6 months"
3. Typed input for context: "How do you know them? (briefly)"
4. Add to network.md with today's date and the calculated follow-up.
5. Confirm: "✅ Added [Name] to [tier]. Follow-up: [date]."

## Context-bus signals

| Condition | Signal |
|-----------|--------|
| Inner circle overdue (7+ days past follow-up) | @coach proactive nudge in /morning: "Haven't talked to [Name] in a while. Message them today?" |

Write via `bash scripts/context-bus-append.sh` only; max 2 signals per execution.
