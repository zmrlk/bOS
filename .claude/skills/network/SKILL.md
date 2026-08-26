---
name: network
description: "Personal relationship manager — log contacts, track follow-ups, get reminded who to reach out to. Your network is your net worth. Use to log meetings, track follow-ups, or see who needs outreach. Trigger on: contact, networking, follow-up."
user_invocable: true
command: /network
tier: optional
---

# /network — relationship CRM

**Read `references/tiers.md` before the first user-facing reply.** Tier definitions, display layouts, the add flow, and bus signals live there.

Subcommands: `/network` (summary, default) · `log "Name" "context"` · `who` · `add`. Natural language works too: "I met with Ania" → parse the name and context, log automatically.

## Do this

1. Parallel Read, one turn: `profile.md` (language, communication_style), `state/network.md` (full — small file). Missing network.md → create silently with schema headers from `state/SCHEMAS.md`.
2. Tiers set the follow-up cadence — Inner circle (~5): every 2 weeks · Active (~50): every 1–2 months · Extended (~500): every 3–6 months. Follow-up dates are always auto-calculated from tier, never asked.
3. `log`: fuzzy-match the name against network.md (partial, case-insensitive). Match → Last contact = today, context appended to Notes, follow-up recalculated. No match → offer `/network add`, never guess a person.
4. `who`: sort contacts by staleness (most overdue first), show top 3 with a conversation starter drawn from their Notes.
5. Every choice is an AskUserQuestion; typed input only for name and context.

## Rules

- Never share contact details outside bOS — this is private data.
- Max 2 context-bus signals per execution. Inner-circle contact 7+ days past follow-up → the /morning nudge signal (see tiers.md).
- Language matches the profile language.
