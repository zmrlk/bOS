# /task — flows and adaptations

Detail for `/task`. SKILL.md holds the hard rules; this file holds the how.

## Display (default `/task`, no args)

1. Read `state/tasks.md`, find today's section (`## YYYY-MM-DD`).
2. List each task on one line: status, number, description, energy tag (H/M/L), context (work/personal). End with the done count (X/Y).
3. Respect the visibility cap from SKILL.md: max 3 tasks shown, "+N more hidden" if applicable; scattered work style shows exactly one.
4. No tasks today → "Nothing for today. Add something?" — nothing else.

Output intent everywhere: short, concrete, one next step. No fixed layouts, no decorative separators, no canned celebration strings.

## Add flow

1. Description from args; if missing, ask once.
2. Auto-detect context from content:
   - work / project / client / meeting → work → owner @boss
   - personal / home / errands / life → personal → owner @coach
   - unclear → default personal
3. Auto-detect energy from task type:
   - creative / strategic / building → H
   - writing / emails / admin → M
   - review / planning / errands → L
4. Estimated effort > 2h → split into ≤2h chunks before writing (SKILL.md hard rule).
5. AskUserQuestion, header "When": Today / Tomorrow / This week / Backlog.
6. Append to the right section of `state/tasks.md`. Confirm in one line.

## Complete flow

1. Find the task by # in `state/tasks.md`, set status to done, update the completion count.
2. All of today done → one genuine sentence of acknowledgment (write it fresh, don't reuse a stock phrase).
3. Task linked to a goal → update goal progress.

## Skip / move

- Skip: mark skipped with the reason; offer to move it to tomorrow or backlog.
- Move: remove from current day, add to target day, confirm in one line.

## Carry-over (run when /task starts on a new day)

1. Find the most recent date section in `state/tasks.md`.
2. Collect tasks that are neither done nor skipped.
3. Create today's section if missing; copy the unfinished tasks in.
4. Tell the user how many carried over, list them briefly.
5. AskUserQuestion (multiSelect): "Which ones do you want to keep for today?" — "All" plus individual tasks. Unselected → mark skipped.
6. Dragging tasks: carried 3+ times → flag it and offer break down / delegate / delete. With adhd_indicators = yes/suspected, act at 2+ carries and break it down immediately instead of just flagging.

Date logic: current system date vs `## YYYY-MM-DD` headers.

## user_type adaptation

- Employee → "work" = company tasks, "personal" = life.
- Freelancer → "work" = client tasks; add a `client:` tag.
- Student → "work" = study tasks, "personal" = life.

## ADHD adaptation (adhd_indicators = yes/suspected)

- Show: cap at 3 visible even if more exist; name the hidden count.
- Add: frame the new task as a small challenge with a 15-25 min time estimate.
- Complete: acknowledge immediately and point at the next task; show a streak if one exists.
- Carry-over: break down at 2+ carries (see above).

## Work-style adaptation (profile.md → work_style)

- **Sprinter** → group today's tasks into a named sprint block (~60 min, 2-3 tasks). After the block: rest or next sprint.
- **Scattered** → exactly one task visible: "One task. Just this." Reveal the next only after completion.
- **Procrastinator** → surface deadlines on the task line; add a countdown for anything due today.
- **Steady** → standard display.

## Context-bus signals

After state changes, helper only — never edit jsonl:
`bash scripts/context-bus-append.sh <from> <to> <type> <priority> "<content>" [ttl_days]`

- Task completed: `@boss` `ALL` `data` `info` `"Task #X completed: [description]"` `7` (all of today done → priority `normal`)
- Skipped 3+ times: `@boss` `@coach` `insight` `normal` `"Task '[description]' skipped 3x"` `14`
- Goal-connected task done: `@boss` `@coach` `data` `info` `"Goal progress: [task] for goal #[X]"` `7`

## State files

- Read: `state/tasks.md`, `state/daily-log.md` (energy, first 25 lines), `profile.md` (work_style, adhd_indicators, user_type)
- Write: `state/tasks.md` (Today, This Week, Backlog). Bus = helper → `state/context-bus.jsonl`
