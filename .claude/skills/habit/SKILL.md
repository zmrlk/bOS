---
name: habit
description: "Unified habit and quit tracker — view streaks, add/remove habits, log completions, track cessation (days free, money saved, health milestones). Gamified with milestones and personal bests. Use when the user says 'habit', 'streak', 'done', 'quit', 'how many days', 'how much saved', or logs a completed habit."
user_invocable: true
command: /habit
tier: core
---

# /habit — Habit & Quit Tracker

**Read `references/tracker.md` before the first user-facing reply** — dashboard specs, quit-tracking schema, milestone tables, and the relapse protocol live there.

Track habits, celebrate streaks, beat personal bests. Also owns cessation tracking (quit smoking, alcohol, any substance or behavior).

## Data (one parallel turn)

`profile.md` (adhd_indicators, active_packs, language) + `state/habits.md` (full — habits, streaks, bests, Quit Tracking section). `state/finances.md` only when deriving a daily cost.

## Subcommands

- `/habit` — streak overview: per habit, last 7 days, current streak, personal best, next milestone if within 3 days; one line per active quit. Layout intent in references.
- `/habit add "X"` — AskUserQuestion for frequency (Daily / 3× / 2× / 1× a week), auto-assign owner agent (mapping in references), append row to habits.md, confirm in one line.
- `/habit done "X"` — fuzzy match (partial, case-insensitive; no match → list the habits, ask which). Already logged today → say so, stop. Else streak +1, last-done = today; new best or milestone (3/7/14/21/30/60/90) → celebrate; otherwise one-line log.
- `/habit remove "X"` — fuzzy match, AskUserQuestion to confirm, remove.
- `/habit quit` — cessation dashboard: days free, money saved, last + next health milestone, streak vs best. First run sets up the Quit Tracking section (schema in references). Ends with an AskUserQuestion check-in.

## Hard rules

1. Relapse = DECAY, not reset: a slip costs −1 day, never zeroes the streak (ADHD-friendly). Zero judgment; full protocol in references.
2. Personal best is ALL-TIME — never resets.
3. Never guilt on broken streaks — "Streaks reset. You don't." Quit framing is always what they GAINED: "slipped", never "failed".
4. Celebrations: short, warm, one concrete number (days, amount saved, record beaten). If `adhd_indicators` = yes/suspected → bigger celebrations, visual streaks, dopamine-friendly milestones.
5. Never invent health claims or costs — read from state, use the references milestone tables, or ask. Nicotine milestones in references are the only pre-approved health claims.
6. Ambient mode: inside other skills, quit status is max ONE line; full dashboard only on explicit `/habit quit`.
7. AskUserQuestion for all choices. Max 2 context-bus signals per run (formats in references). Language = profile.

State: read profile.md, habits.md (full), finances.md (cost only); write habits.md only.
