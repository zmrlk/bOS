---
name: Task
description: "Add, list, complete, or manage tasks. Works with @boss (work tasks) and @coach (life tasks). Use to view today's tasks, add new ones, or mark tasks complete. Daily task management."
user_invocable: true
command: /task
tier: core
---

# /task — Task Manager

## Usage
- `/task` → show today's tasks
- `/task add [description]` → add a task
- `/task done [#]` → mark task as done
- `/task skip [#] [reason]` → skip with reason
- `/task move [#] [day]` → move to another day
- `/task backlog` → show unscheduled tasks

If user provides a task without subcommand → treat as `/task add`.

## Protocol

### Show tasks (default — no args)
1. Read `state/tasks.md`
2. Show today's section:
```
📋 Today ([day], [date]):

[status] #1 [Task] — [energy] [context]
[status] #2 [Task] — [energy] [context]

Done: [X]/[Y] ([%])
```
3. If no tasks for today → "Nothing for today. Add something?"

### Add task
1. If description provided → use it. If not → ask.
2. Auto-detect context from content:
   - Work/project/client/meeting → work → owner: @boss
   - Personal/home/errands/life → personal → owner: @coach
   - Unclear → default to personal
3. Auto-detect energy from task type:
   - Creative/strategic/building → H
   - Writing/emails/admin → M
   - Review/planning/errands → L
4. Use `AskUserQuestion` for when:
   - header: "When"
   - options: "Today" / "Tomorrow" / "This week" / "Backlog"
5. Add to appropriate section in `state/tasks.md`
6. Confirm: "[status emoji] Added for [day]."

### Complete task
1. Find task by # in `state/tasks.md`
2. Change status to 🟢
3. Update completion rate
4. If all today's tasks done → celebrate: "Everything done for today! 🎉"
5. If goal connected → update goal progress

### Skip task
1. Change status to ⏭️ with reason
2. Auto-carry: offer to move to tomorrow or backlog

### Move task
1. Remove from current day
2. Add to target day
3. Confirm: "Moved to [day]."

### Carry-over logic
When /task runs at the start of a day:
1. Read state/tasks.md
2. Find the most recent date section (## YYYY-MM-DD)
3. Identify tasks with Status = ☐ (not done, not skipped)
4. If today's section doesn't exist → create it
5. Copy ☐ tasks from most recent section to today's section
6. Show: "Carrying over [X] unfinished tasks from [date]:"
   List carried tasks briefly
7. Ask: "Which ones do you want to keep for today?" (AskUserQuestion, multiSelect)
   - "All" → keep all
   - Individual tasks listed → keep selected, mark others as ⏭️ (skipped)

Date logic: Use current date from system. Compare with section headers (## YYYY-MM-DD format).
If task carried 3+ times → flag: "This task keeps dragging. Want to break it into smaller pieces, delegate it, or delete it?"

## Adapt to user_type
- Employee → "work" context = company tasks. "personal" = life tasks.
- Freelancer → "work" = client tasks. Add "client:" tag.
- Student → "work" = study tasks. "personal" = life tasks.

## ADHD + Work Style Adaptation

Read `profile.md` → `adhd_indicators`, `work_style` before displaying or adding tasks.

### ADHD adaptation (adhd_indicators = yes/suspected)
- **Show tasks:** Max 3 visible tasks, even if more exist. Show: "You have [X] more tasks, but focus on these 3."
- **Add task:** Frame as dopamine hook: "⚡ New challenge added!" Add time estimate (15-25 min chunks).
- **Complete task:** Loud celebration: "🔥 Boom! [X/Y] done! Next challenge?" Show streak if applicable.
- **Carry-over:** If task carried 2+ times → break it down immediately, don't just flag at 3.

### Work style adaptation
- **Sprinter** → Group tasks into sprint blocks: "🏃 Sprint block (60 min): #1, #2, #3". After sprint: "Rest or next sprint?"
- **Scattered** → Show ONLY 1 task: "One task. Just this." Hide the rest completely. After completion, reveal next one.
- **Procrastinator** → Show deadlines prominently: "#1 [Task] — ⏰ 3h left". Add countdown for today's tasks.
- **Steady** → Standard display (no changes needed).

## Context-Bus Signals
After state changes, helper only — never edit jsonl:
`bash scripts/context-bus-append.sh <from> <to> <type> <priority> "<content>" [ttl_days]`
- Task completed: `@boss` `ALL` `data` `info` `"Task #X completed: [description]"` `7` (all today done → priority `normal`)
- Skipped 3+: `@boss` `@coach` `insight` `normal` `"Task '[description]' skipped 3x"` `14`
- Goal-connected done: `@boss` `@coach` `data` `info` `"Goal progress: [task] for goal #[X]"` `7`

## State Files
- **Read:** state/tasks.md, state/daily-log.md (energy for matching), profile.md (work_style, adhd_indicators)
- **Write:** state/tasks.md (Today, This Week, Backlog). Bus = helper → `state/context-bus.jsonl`

## Agents
- @boss owns work tasks
- @coach owns personal/life tasks
