---
name: evening
description: "On-request evening shutdown — log energy if missing, one win, tomorrow's #1. Use when the user says /evening, end of day, or zamykam dzień. Never auto-nudge."
user_invocable: true
command: /evening
tier: core
---

# /evening — on request

**Read `references/protocol.md` before questions.** Max 3 questions, fewer is better.

Read Summaries of `state/tasks.md`, `state/daily-log.md`, `state/habits.md` first. If the answer is already in state or this chat, skip the question.

1. Energy PM — skip if today's row has it. Else AskUserQuestion: 1–3 / 4–6 / 7–10.
2. Win — options from today's completed tasks + "that counts" / "I rested". Never shame a zero-task day.
3. Tomorrow #1 — options from pending tasks (overdue first).

Then write today's daily-log row (create the row if `/morning` never ran). Close with the win and tomorrow's #1. No guilt.

Night-cycle / `.pre-morning.md` is optional, after the goodnight line; see `references/protocol.md`. If interrupted, morning still works.
