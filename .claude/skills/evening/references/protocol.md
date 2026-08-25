---
name: Evening
description: "On-request evening shutdown — log energy if missing, one win, tomorrow's #1. Use when the user says /evening, end of day, or zamykam dzień. Never auto-nudge."
user_invocable: true
command: /evening
---

# /evening — on request, max 3 questions

Read Summaries of `tasks.md`, `daily-log.md`, `habits.md` first. Skip any question already answered in state or this chat.

1. Energy PM — skip if logged.
2. Win — options from completed tasks.
3. Tomorrow #1 — options from pending tasks.

Then update today's daily-log row (create if `/morning` never ran). Close with the win, not guilt.

Night-cycle / pre-morning file: `references/protocol.md`. Optional; skip if interrupted.
