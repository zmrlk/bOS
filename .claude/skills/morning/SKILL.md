---
name: Morning
description: "Daily morning briefing from state files. Use when the user asks /morning, good morning, or start of day. Never auto-run on a greeting."
user_invocable: true
command: /morning
tier: core
---

# /morning — on request only

**Before the briefing, Read `references/briefing.md`.** Then work from files, not vibes.

Never open with a question. Never run because the user said "cześć" / "hi".

## Do this

1. Parallel Read: `profile.md`, `state/tasks.md` (first 25 lines), `state/daily-log.md` (first 25), `state/handoff.md` if it exists, `state/habits.md` if Health/Life pack.
2. Energy: today's daily-log, else this conversation, else assume medium. Do not interrogate.
3. Greeting: one line with their name.
4. Brief, skip empty sections:
   - max 3 priorities from tasks (overdue first)
   - one quick win ≤15 min
   - calendar/mail only if ToolSearch finds a connector; omit if not. Never write "brak danych".
5. Energy 1–3 → one micro-task + water + log tonight. That is a complete day. No pep talk.
6. End with one Next step, not a question.

Do not invent completion rates, weather, or mail you did not fetch. Pack-specific blocks and MCP fallbacks are in `references/briefing.md` — use them; newsletter/noise senders live in profile.md if set.
