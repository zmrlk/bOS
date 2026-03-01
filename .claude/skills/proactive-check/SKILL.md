---
name: Proactive Check
description: "Runs silently at session start. Checks all agents' proactive triggers against current state. Surfaces the most important 1-2 nudges."
user_invocable: false
command: /proactive-check
---

# Proactive Check

Runs silently at session start — BEFORE responding to the user's first message. Never announce that you're running this check.

### Trigger Mechanism
/proactive-check is triggered by @boss at session start:
1. @boss loads profile.md + state files (per CLAUDE.md session start protocol)
2. As part of that load, @boss runs proactive-check logic INLINE (not as separate skill invocation)
3. This means: @boss reads state, checks triggers, surfaces top 2 nudges — all in one turn
4. No separate hook mechanism needed — it's part of @boss's session start behavior

**Priority order for nudges (when multiple triggers fire):**
1. CRITICAL: Crisis signals in context-bus (always surface)
2. HIGH: Overdue tasks (>2 days), buffer below target
3. MEDIUM: Habit streak at risk (>2 days gap), follow-up due
4. LOW: Profile incomplete, weekly review due
Surface TOP 2 only. Never more than 2 nudges at session start.

## Protocol

### Step 1: Load state
Read the following in order:
- `state/tasks.md` — overdue tasks, tasks with no progress
- `state/finances.md` — buffer level, recent spending, streak data
- `state/habits.md` — missed workouts, broken streaks
- `state/pipeline.md` — stale follow-ups (if business pack active)
- Agent memory — energy trends from the last 7 days

### Step 2: Check triggers

For each domain, evaluate:

**Tasks:**
- Any task overdue by 2+ days? → flag
- Any task that's been "in progress" for 5+ days without completion? → flag

**Finance:**
- Buffer below target? → flag
- Spending spike this week vs usual? → flag
- Impulse purchase in last 24h? → flag (gentle, not guilt)

**Habits:**
- Workout missed 3+ days in a row? → flag (if health pack active)
- Streak at risk today (hasn't logged yet)? → flag

**Pipeline / Follow-ups:**
- Any lead with no activity for 5+ days? → flag (if business pack active)
- Proposal sent but no response in 7+ days? → flag

**Energy patterns:**
- Last 3 days all low energy (≤4)? → flag for crash awareness

### Step 3: Prioritize

From all flagged items, select MAX 2 — prioritize by:
1. Financial safety (buffer, debt)
2. Time-sensitive (deadline, stale lead)
3. Streak/habit (losing momentum)
4. Everything else

### Step 4: Surface

Prepend to normal response as a brief @boss note. Format:

```
💡 Quick heads up:
→ [Nudge 1 — specific, one line]
→ [Nudge 2 — specific, one line, only if truly important]
```

Then continue with the normal response to the user's message.

## Rules
- MAX 2 nudges. Never more.
- Each nudge is ONE line. No explanation needed — just the fact.
- Never guilt. State the fact, let user decide.
- If nothing triggered → show nothing. Silence is the default.
- Never tell the user you ran a check. Just surface the insight naturally.
- Don't repeat the same nudge two sessions in a row if user didn't act.
