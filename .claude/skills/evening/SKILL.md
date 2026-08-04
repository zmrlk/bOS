---
name: Evening
description: "Daily evening shutdown ritual — reflect on the day, log energy, plan tomorrow. Run at the end of each day."
user_invocable: true
command: /evening
---

# Evening Shutdown

Read `profile.md`. Check `user_type`, `tech_comfort`, `communication_style`. Quick end-of-day ritual (~3 min).

**Context loading:** Use Summary reads (first 25 lines) for tasks.md and daily-log.md. Read today's Active section only for specific entries.

**Adapt to tech_comfort:** "not technical" → plain language, no jargon. "I use apps" → name tools. "I code" → technical details OK.

**Adapt to user_type:** Employee → work accomplishments, tomorrow's meetings. Freelancer → client work, invoicing. Student → study progress. Between things → progress on goals.
**Adapt to communication_style:** direct → shorter prompts, skip elaboration. casual → friendly tone. detailed → explain the value of logging. motivational → celebrate wins enthusiastically.

## Protocol

### Step 1: Check-in

Show:
```
🌙 Hey [name], time for a quick shutdown.
```

**Hard cap: 3 questions, ever.** Read `state/tasks.md`, `state/daily-log.md` and `state/habits.md` FIRST — anything already logged today is not asked again. If the conversation already told you the answer, use it and skip the question. A shutdown with 1 question is a good shutdown; a shutdown with 5 is an interrogation.

**Question 1 — energy (skip if today's row already has an evening energy value):**
`AskUserQuestion`, header "Energy", options: "🔋 Low (1-3)" / "⚡ Medium (4-6)" / "🔥 High (7-10)".

**Question 2 — the win (skip if the user already named one):**
`AskUserQuestion`, header "What went well?", options generated from today's completed tasks (max 3) + "Something else".
If no completed tasks today → options: "I got through it — that counts" / "I rested (and that's fine)" / "Something else".
Never make a zero-task day feel like failure.

**Question 3 — tomorrow's #1 (selection, not typing):**
Read `state/tasks.md` → pending tasks. Sort: overdue first → high priority → matched to the user's morning peak. `AskUserQuestion`, header "Tomorrow", options: top 4 tasks + "Something else". Save the selection as tomorrow's #1.

Sleep quality, habits, and mood are **inferred or left blank** — they are not worth a question. If the user volunteers them, log them.

### Step 1B: Pattern Comparison (if 7+ entries in daily-log, runs after Step 1)

**After user reports today's energy, compare with their baseline.**

Check native auto-memory for energy patterns. If 7-day average exists:

- Today's energy vs 7-day average → show brief comparison:
  - Above average: "Energy [X] today vs your usual [Y]. [If exercise done: 'Training + good sleep = your winning combo.'] [If no trigger found: 'Good day. Note what you did differently.']"
  - Below average: "Energy [X] today vs your usual [Y]. [If bad sleep: 'Sleep was rough — that tracks with your data.'] [If no trigger: 'Low days happen. Tomorrow's a reset.']"
  - At average: skip comparison, don't state the obvious

**Rules:**
- Max 2 sentences. This is a quick reflection, not an analysis.
- Only show when 7+ data points exist.
- Skip on first 7 days.
- Never guilt. Frame as data, not judgment.

### Step 2: Log (after user responds)

**CRITICAL: Don't assume /morning ran today.**
Before updating daily-log:
1. Check if today's date has an entry in daily-log.md
2. If YES → UPDATE the row (add Energy PM, Sleep, Mood, Win)
3. If NO → CREATE a full new row (Energy AM = ask user now, then continue with PM fields)
4. If daily-log.md doesn't exist → create with schema headers, then add entry

Never crash because /morning didn't run. Always create what's missing.

**Lite mode:**
1. Update `state/tasks.md` — mark completed tasks, add tomorrow's priority.
2. Append today's entry to `state/daily-log.md`:
   - Date, energy level (from Step 1), sleep quality (from explicit sleep question), mood (infer from conversation tone or ask: "Jak ogólnie nastrój? 😊/😐/😔"), exercise (from habit check or state/habits.md), win of the day (from "What went well?"), tomorrow #1 priority.
   - Format: `| YYYY-MM-DD | [energy] | [sleep] | [mood] | [exercise] | [win] | [tomorrow] |`
3. If energy pattern is notable (3+ days of low energy, or sudden drop) → post to context-bus: `@boss → @coach` with `Priority: normal`.

**Pro mode:** INSERT into daily_logs (energia, sleep, mood).

### Context Bus Writes (after logging)

After writing today's log, post relevant signals to state/context-bus.jsonl:

| Condition | Write to context-bus.jsonl |
|-----------|------------------------|
| Workout done today | `## [date] @boss → @trainer` / `Type: data` / `Priority: info` / `TTL: 3 days` / `Content: Workout logged [date]. Update streak.` / `Status: pending` |
| Bad sleep 3+ consecutive days | `## [date] @boss → @coach` / `Type: insight` / `Priority: normal` / `TTL: 7 days` / `Content: Poor sleep pattern: [X] days. Sleep hygiene check needed.` / `Status: pending` |
| Energy pattern notable (3+ days low) | `## [date] @boss → @coach` / `Type: insight` / `Priority: normal` / `TTL: 7 days` / `Content: Energy trend: [X] days below average.` / `Status: pending` |
| Habit streak milestone (7, 14, 21, 30 days) | `## [date] @boss → @coach` / `Type: data` / `Priority: info` / `TTL: 3 days` / `Content: [habit] streak: [X] days!` / `Status: pending` |

Use the canonical context-bus format from CLAUDE.md.

**Rules:**
- Check context-bus.jsonl for existing signals before writing duplicates
- Max 2 signals per /evening session

### Step 3: Close
```
"Logged. Tomorrow starts with [#1 priority].

Get some rest. See you in the morning. ☀️"
```

### Step 4: Night Cycle (runs silently after user close)

**Purpose:** Between sessions, @boss consolidates learnings and pre-generates context for the next morning. This happens AFTER the user gets their "goodnight" message — it is background work.

#### 4A. Memory Consolidation

- Read today's daily-log entry + completed tasks + context-bus signals
- Identify patterns: energy vs. sleep correlation, task completion vs. time-of-day, recurring blockers
- If 7+ daily-log entries exist: compute/update 7-day rolling averages (energy, sleep, mood)
- Update native auto-memory with consolidated patterns (NOT raw data — only insights)
- Pattern format: `{date_range} | {pattern_type} | {insight} | {confidence}`

#### 4B. Pre-Generate Morning Context

- Read tomorrow's calendar (if Google Calendar MCP connected) — silently, no output to user
- Check pending tasks for tomorrow from tasks.md
- Check context-bus for pending signals that need action tomorrow
- Check state/reminders.md for reminders due tomorrow → include in brief
- Write a pre-cached morning brief to `state/.pre-morning.md` (overwrite, always fresh):
  ```
  <!-- Auto-generated by /evening Sleep-Time Consolidation -->
  <!-- Used by /morning for faster startup -->
  Date: YYYY-MM-DD
  Priority: [tomorrow's #1 from user selection]
  Calendar: [N events, first at HH:MM]
  Pending signals: [count]
  Energy trend: [up/down/stable based on 3-day]
  Suggested focus: [based on energy pattern + task urgency]
  ```

#### 4C. Pattern Detection

- If 14+ daily-log entries exist: detect weekly patterns
  - Best day of week (highest avg energy)
  - Worst day of week (lowest avg energy)
  - Sleep-to-energy correlation strength
  - Exercise-to-energy correlation strength
- Store detected patterns in native auto-memory (update, don't append)
- Patterns used by /morning to give better recommendations and by /habit for visualization

#### Rules for Sleep-Time Consolidation

- NEVER show this work to the user — it is invisible background intelligence
- The "goodnight" message (Step 3: Close) comes FIRST, consolidation runs after
- If MCP connections fail — skip that part silently
- If daily-log has <7 entries — skip pattern analysis, just pre-cache morning
- Max execution: kept lightweight, no WebSearch, no heavy ops
- Write `.pre-morning.md` as overwrite (not append) — it is always fresh for tomorrow
- If evening is interrupted before Step 4 — no harm, morning works fine without it

## Session Ending (Peak-End Rule)
Always close /evening with a win highlight — the single best thing from the day:
"Today's highlight: you [specific achievement]. That's real progress. Tomorrow starts with [X]. Sleep well, [name]."

Never end with guilt or "should have done more." Always find the win.

## Work Style Adaptation

Read `profile.md` → `work_style` before starting the evening ritual.

- **Sprinter** → Infer sprint vs rest day from what actually got logged; do NOT spend a question on it. Sprint day → celebrate intensity. Rest day → "Rest days fuel sprints."
- **Scattered** → Compress to 1 question (energy only). Get in and out fast before attention drifts.
- **Procrastinator** → Show tomorrow's deadlines prominently in the close: "Tomorrow: [task] — due in [X]h. Start with it."
- **Steady** → Standard flow (no changes needed).

## Rules
- 3 questions MAX, and fewer is better — every answer already in state or in the conversation replaces a question
- Don't lecture about what wasn't done
- Celebrate what WAS done ("Nice work on [X]")
- If user reports low energy → "Rest is productive too. No guilt."
- Save patterns to native auto-memory (energy trends, productive days)
