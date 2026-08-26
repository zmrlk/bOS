---
name: task
description: "Add, list, complete, or manage tasks. Works with @boss (work tasks) and @coach (life tasks). Use to view today's tasks, add new ones, or mark tasks complete. Daily task management."
user_invocable: true
command: /task
tier: core
---

# /task — Task Manager

**Read `references/flows.md` before the first user-facing reply.** Display flows, carry-over, adaptations, and bus signals live there.

## Usage

- `/task` → today's tasks (new day → run carry-over first)
- `/task add [description]` → add; a bare description with no subcommand also means add
- `/task done [#]` · `skip [#] [reason]` · `move [#] [day]` · `backlog`

## Hard rules (ADHD support is the product)

- **Max 3 visible tasks**, even if more exist — say how many are hidden.
- **Tasks ≤2h**: anything bigger gets broken into chunks before it enters the list.
- **Energy > time**: every task carries H/M/L; match tasks to logged energy, not the clock.
- work_style = scattered → show exactly one task ("One task. Just this."); reveal the next only after completion.
- Output intent: short, concrete, one next step. No fixed layouts, no canned celebration strings — completing everything earns one genuine sentence, written fresh.

## Protocol (summary — detail in references/flows.md)

1. Parallel read: `state/tasks.md`, `profile.md` (work_style, adhd_indicators, user_type), `state/daily-log.md` first 25 lines for energy.
2. Route the subcommand through the matching flow in flows.md.
3. Add: auto-detect context (work → @boss, life → @coach, unclear → personal) and energy from content; ask "When" via AskUserQuestion (Today / Tomorrow / This week / Backlog).
4. New day → carry-over: copy unfinished tasks, user picks keepers (AskUserQuestion, multiSelect); tasks that keep dragging get broken down, not re-listed.
5. Apply user_type, ADHD, and work-style adaptations from flows.md before displaying or adding.
6. Write only `state/tasks.md`; context-bus via `bash scripts/context-bus-append.sh` (signals in flows.md), never edit jsonl directly.

## Agents

- @boss owns work tasks; @coach owns personal/life tasks.
