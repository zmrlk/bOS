---
name: Home
description: "One-screen snapshot from state Summaries. Use when the user says /home, dashboard, or status."
user_invocable: true
command: /home
tier: core
---

# /home

**Read `references/blocks.md` for extra blocks.** Core is below even if you skip it.

One screen. Numbers only from files (cite mtime on buffer). Skip empty blocks. Never estimate or fabricate.

Parallel, one turn: `profile.md`; first 25 lines of `state/tasks.md`, `state/daily-log.md`, `state/finances.md`; full `state/habits.md` if a health/life pack is on.

Always show:
- TODAY: done/total tasks, energy or "not logged"
- NEXT: highest-priority open task, or primary_goal if none

Streaks / buffer / projects: only if data exists — layouts in `references/blocks.md`. Calendar/mail only if already connected.

Empty install → progress bars from filled profile fields, not fake KPIs. Language = profile.
