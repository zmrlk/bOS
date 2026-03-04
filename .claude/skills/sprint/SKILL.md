---
name: Sprint Planning
description: "Weekly sprint system — capacity planning, story points, burndown tracking. For users who want structured productivity."
user_invocable: true
command: /sprint
model: sonnet
---

# /sprint — Weekly Sprint System

Sprint-based productivity. Plan capacity, assign points, track velocity.

**Prerequisite:** Works best with /plan-week. Sprint mode adds SP (story points) layer on top.

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → work_style, peak_hours, available hours, sprint_mode
- `state/tasks.md` (Summary + Active section) → current tasks
- `state/weekly-log.md` (Summary) → last week's velocity

### Subcommand: `/sprint` (no args — show current sprint)

If sprint_mode = active in profile.md and @coo memory has `current_sprint`:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🏃  SPRINT — Week of [date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Committed: [X] SP
  Completed: [Y] SP
  Remaining: [Z] SP

  BURNDOWN:
  Day 1  ████████████  12 SP
  Day 2  ██████████░░  10 SP
  Day 3  ████████░░░░   8 SP  ← today
  Day 4  ······░░░░░░   (ideal: 6)
  Day 5  ··········░░   (ideal: 2)

  Velocity (4-week avg): [V] SP/week
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If sprint_mode = off or no current sprint:
→ Offer to start: "Chcesz rozpocząć sprint? Planuję tydzień z punktami."

### Sprint Planning (new sprint)

1. **Capacity calculation:**
   - Available hours from profile.md (or ask)
   - Apply multiplier: available × 0.7 (buffer for surprises)
   - Convert to SP: 1 SP ≈ 2h, 2 SP ≈ 4h, 3 SP ≈ 8h

2. **Task assignment:**
   Show tasks from /plan-week or tasks.md. For each:
   Use `AskUserQuestion`:
   - header: "[task name]"
   - options:
     - "1 SP — mały (do 2h)"
     - "2 SP — średni (2-4h)"
     - "3 SP — duży (4-8h)"
     - "Pomiń ten task"

3. **Commitment:**
   ```
   Capacity: [X] SP (z buforem na niespodzianki)
   Planned: [Y] SP

   [If Y > X]: "⚠️ Za dużo! Usuń [Y-X] SP lub zmniejsz zadania."
   [If Y ≤ X]: "✅ Sprint zaplanowany. Powodzenia!"
   ```

4. **Save:**
   - Set profile.md → sprint_mode = active
   - Store in @coo memory:
     ```
     current_sprint:
       week: [date]
       planned_sp: [X]
       completed_sp: 0
       tasks: [{name, sp, status}]
     velocity_history:
       - {week, planned_sp, completed_sp}
       - ... (keep last 8 weeks)
     ```
   - Update tasks.md with SP annotations

### Sprint Completion

When /review-week runs → calculate sprint metrics:
- Completed SP / Planned SP = Sprint completion %
- Update velocity_history in @coo memory
- 4-week rolling average = velocity

## Context-Bus Signals

| Condition | Signal |
|-----------|--------|
| Sprint completed | `@coo → @boss, Type: data, Priority: info, TTL: 7 days, Content: Sprint completed: [X]/[Y] SP ([Z]%). Velocity: [V].` |

## State Files
- **Read:** profile.md, tasks.md (S+Active), weekly-log.md (S)
- **Write:** tasks.md (SP annotations), profile.md (sprint_mode)

## Rules
1. Use AskUserQuestion for all choices
2. Max 2 context-bus signals per execution
3. All reads in 1 turn (parallel I/O)
4. 1 SP = small (2h), 2 SP = medium (4h), 3 SP = large (8h)
5. Always include buffer (0.7 multiplier on capacity)
6. Velocity = 4-week rolling average of completed SP
7. Burndown shown in /home when sprint_mode = active
8. Language matches user's profile language
