---
name: Task Manager
description: "Add, list, complete, or manage tasks. Works with @coo (work tasks) and @organizer (life tasks)."
user_invocable: true
command: /task
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
📋 Dziś ([day], [date]):

[status] #1 [Task] — [energy] [context]
[status] #2 [Task] — [energy] [context]

Gotowe: [X]/[Y] ([%])
```
3. If no tasks for today → "Pusto na dziś. Dodać coś?"

### Add task
1. If description provided → use it. If not → ask.
2. Auto-detect context from content:
   - Work/project/client/meeting → work → owner: @coo
   - Personal/home/errands/life → personal → owner: @organizer
   - Unclear → default to personal
3. Auto-detect energy from task type:
   - Creative/strategic/building → H
   - Writing/emails/admin → M
   - Review/planning/errands → L
4. Use `AskUserQuestion` for when:
   - header: "Kiedy"
   - options: "Dziś" / "Jutro" / "Ten tydzień" / "Backlog"
5. Add to appropriate section in `state/tasks.md`
6. Confirm: "[status emoji] Dodane na [day]."

### Complete task
1. Find task by # in `state/tasks.md`
2. Change status to 🟢
3. Update completion rate
4. If all today's tasks done → celebrate: "Wszystko na dziś zrobione! 🎉"
5. If goal connected → update goal progress

### Skip task
1. Change status to ⏭️ with reason
2. Auto-carry: offer to move to tomorrow or backlog

### Move task
1. Remove from current day
2. Add to target day
3. Confirm: "Przeniesione na [day]."

### Carry-over logic
When /task runs at the start of a day:
1. Read state/tasks.md
2. Find the most recent date section (## YYYY-MM-DD)
3. Identify tasks with Status = ☐ (not done, not skipped)
4. If today's section doesn't exist → create it
5. Copy ☐ tasks from most recent section to today's section
6. Show: "Przenoszę [X] niezrobionych zadań z [date]:"
   List carried tasks briefly
7. Ask: "Które chcesz zachować na dziś?" (AskUserQuestion, multiSelect)
   - "Wszystkie" → keep all
   - Individual tasks listed → keep selected, mark others as ⏭️ (skipped)

Date logic: Use current date from system. Compare with section headers (## YYYY-MM-DD format).
If task carried 3+ times → flag: "Ten task się ciągnie. Chcesz go rozbić na mniejsze części, delegować, albo usunąć?"

## Adapt to user_type
- Employee → "work" context = company tasks. "personal" = life tasks.
- Freelancer → "work" = client tasks. Add "client:" tag.
- Student → "work" = study tasks. "personal" = life tasks.

## State Files
- **Read:** state/tasks.md, state/daily-log.md (energy for matching)
- **Write:** state/tasks.md (Today, This Week, Backlog)

## Agents
- @coo owns work tasks
- @organizer owns personal/life tasks
