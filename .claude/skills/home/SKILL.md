---
name: Home
description: "Dashboard — one screen with everything that matters right now. Tasks, energy, streaks, buffer, calendar, next action."
user_invocable: true
command: /home
---

# /home — Dashboard

One screen. Everything that matters. No scrolling required.

**Adapt to user_type:** Employee → career/work focus (skip pipeline/pricing widgets). Freelancer/Business → full dashboard. Student → learning focus. Between things → goals + motivation.
**Adapt to tech_comfort:** Label sections with user-friendly names for non-technical users.

---

## Data Sources (batch loading — Summary only, instant dashboard)

**Issue ALL reads in one batch of tool calls** — host runs them concurrently. Use **Summary reads (first 25 lines)** for growing files. /home renders entirely from Summaries — ZERO Tier 2 reads.

**Always (Lite mode) — batch Read calls, 1 turn:**
- `profile.md` (full) → name, user_type, active_packs, primary_goal
- `state/tasks.md` (first 25 lines — Summary) → today's task counts, overdue count
- `state/daily-log.md` (first 25 lines — Summary) → today's energy, 7d trend
- `state/habits.md` (full) → streaks (if Health or Life pack active)
- `state/finances.md` (first 25 lines — Summary) → buffer %, spending today/week (if Finance active)

**Pro mode (Supabase) — batch queries in one tool-use turn:**
- `tasks` table → WHERE plan_date = CURRENT_DATE
- `daily_logs` → today's energy, last 7 days for streak
- `expenses` → today's + this week's spending
- `habits` or derived from `daily_logs`
- `leads` → pipeline count (if Business pack)

**MCP (if available) — batch calls:**
- Google Calendar → today's events count + next event
- Gmail → unread count or pending follow-ups

**Rule:** Never load one source → process → load next. Issue ALL in one turn → render from loaded data.

---

## Layout

Show progress indicators for loading:
```
⏳ Loading dashboard...
```

Then render:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🖥️  bOS — [preferred_name], [day_of_week]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then show BLOCKS based on active packs. Each block is independent.

---

## Block: TODAY (always shown)

```
  📊  TODAY
  ┌─────────────────────────────────┐
  │  [task_icon] [done]/[total] tasks done          │
  │  ⚡ Energy: [value or "not logged"]             │
  │  📅 [N] meetings ([next_time]: [next_title])    │
  └─────────────────────────────────┘
```

- `task_icon`: ✅ if all done, 🔲 if some remaining, ⬜ if none started
- Calendar line only if Google Calendar MCP available
- If no tasks exist for today → "No tasks planned. Say 'plan my day' to start."
- Energy from `daily_logs` (Pro) or `state/daily-log.md` (Lite) — logged via /morning and /evening

---

## Block: NEXT ACTION (always shown)

```
  ⏭️  NEXT UP
  ┌─────────────────────────────────┐
  │  "[task title]"                              │
  │  ⚡ [energy level] · [estimated time]        │
  └─────────────────────────────────┘
```

Pick the highest-priority undone task for today. If no tasks → show primary_goal from profile.md with a suggestion.

---

## Block: STREAKS (Health or Life pack)

```
  🔥  STREAKS
  ┌─────────────────────────────────┐
  │  🏋️ Workout   ▰▰▰▰▱  4 days  🏆 12  │
  │  📖 Reading   ▰▰▱▱▱  2 days  🏆  5  │
  │  💤 Sleep 7h+ ▰▰▰▱▱  3 days  🏆  8  │
  │  🧘 Mindful   ▰▱▱▱▱  1 day   🏆  3  │
  │  🎯 Focus     ▰▰▰▱▱  3 sess  🏆  7  │
  └─────────────────────────────────┘
```

- Show only habits that have at least 1 entry
- Progress bar: ▰ = active day, ▱ = missed, show last 5 days
- 🏆 = personal best streak (from habits.md Best column)
- Focus sessions: show this week's count from @coo memory → focus_sessions_this_week
- Max 5 habits shown
- If no habits tracked yet → skip this block entirely (don't show empty)

---

## Block: SPRINT BURNDOWN (if sprint_mode active)

Show only if `profile.md → sprint_mode = active` AND @coo memory has `current_sprint`:

```
  🏃  SPRINT — Week of [date]
  ┌─────────────────────────────────┐
  │  Committed: [X] SP              │
  │  Completed: [Y] SP              │
  │  Remaining: [Z] SP              │
  │                                 │
  │  Day 1  ████████████  12 SP     │
  │  Day 2  ██████████░░  10 SP     │
  │  Day 3  ████████░░░░   8 SP ←   │
  │  Day 4  ······░░░░░░  (ideal)   │
  │  Day 5  ··········░░  (ideal)   │
  └─────────────────────────────────┘
```

- SP data from @coo memory → current_sprint
- ← marks current day
- Dots (·) for future ideal line
- If no active sprint → skip this block entirely

---

## Block: BUFFER (Finance pack or Life pack with finance)

```
  💰  BUFFER
  ┌─────────────────────────────────┐
  │  ▰▰▰▰▰▰▱▱▱▱  62%              │
  │  12 400 [currency] / 20 000 [currency] target  │
  │  📉 Spent today: [amount]                      │
  │  📉 Spent this week: [amount]                  │
  └─────────────────────────────────┘
```

- Progress bar: 10 segments, proportional to buffer_current / buffer_target
- Currency from profile.md
- If buffer data not available → skip block
- If buffer_target not set → show only current + "Set a target: '@finance set my buffer target'"

---

## Block: PIPELINE (Business pack only)

```
  📈  PIPELINE
  ┌─────────────────────────────────┐
  │  🟢 Active leads: [N]          │
  │  🔥 Hot: [names, max 3]        │
  │  💰 Total value: [amount]      │
  │  📞 Follow-ups due: [N]        │
  └─────────────────────────────────┘
```

- Only show if Business pack active AND pipeline has entries
- Hot = leads with status 'negotiation' or 'proposal'
- Follow-ups = leads where next_step_deadline <= today + 3 days

---

## Block: CODE (if @devlead active / Business pack with coding projects)

Show only if user has used /code or has coding projects in projects.md:

```
  </> CODE
  ┌─────────────────────────────────┐
  │  Last review: [score]/10        │
  │  Quality trend: [↑/↓/→]        │
  │  Active project: [name]         │
  └─────────────────────────────────┘
```

- Pull from @devlead memory (last review score, quality trend)
- If no code data yet → skip this block entirely

---

## Block: INVOICES (Business pack with invoices)

Show only if `state/invoices.md` has entries:

```
  🧾  INVOICES
  ┌─────────────────────────────────┐
  │  📬 Outstanding: [N] ([amount]) │
  │  🔴 Overdue: [N] ([amount])     │
  │  💰 Paid this month: [amount]   │
  └─────────────────────────────────┘
```

- Pull from state/invoices.md
- If no invoices → skip block entirely
- Overdue = status != paid AND due date < today

---

## Block: TIME (if /timetrack used)

Show only if `state/time-log.md` has entries:

```
  ⏱️  TIME
  ┌─────────────────────────────────┐
  │  This week: [X]h               │
  │  Active timer: [project] [Xh]  │
  │  Top project: [name] ([X]h)    │
  └─────────────────────────────────┘
```

- Pull from state/time-log.md Summary
- If active timer running → show with elapsed time
- If no time data → skip block entirely

---

## Block: LEARNING (Learning pack only)

```
  📚  LEARNING
  ┌─────────────────────────────────┐
  │  📖 Currently: [book/course]    │
  │  🎯 Focus: [learning_goal]     │
  │  📊 This week: [hours]h studied │
  └─────────────────────────────────┘
```

- Pull from agent memory (@teacher, @reader)
- If no learning data yet → "Start with '@teacher what should I learn?'"

---

## Closing

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then use `AskUserQuestion` for quick actions:

**header:** "Quick actions"
**options (pick based on context, show max 3):**
- If tasks remain → "Show my tasks"
- If energy not logged → "Log energy"
- If morning not done → "Morning briefing"
- If it's evening → "Evening shutdown"
- Always available → "I'm good"

---

## Rules

1. Dashboard must fit on ONE screen — no scrolling. If too many blocks, prioritize: TODAY → NEXT ACTION → BUFFER → STREAKS → PIPELINE → LEARNING
2. Skip empty blocks entirely — don't show "No data" boxes
3. Numbers are real — pull from state files or database. Never estimate or fabricate.
4. If everything is empty (fresh install, no data) → show a **progress tracker dashboard** instead of empty blocks:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🖥️  bOS — [name], [day]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  📊  YOUR PROGRESS
  ┌─────────────────────────────────┐
  │  👤 Profile    ▰▰▰▰▰▰▱▱▱▱  60%│
  │  ✅ Tasks      ▱▱▱▱▱▱▱▱▱▱   0%│
  │  🔥 Habits     ▱▱▱▱▱▱▱▱▱▱   0%│
  │  🎯 Goals      ▰▱▱▱▱▱▱▱▱▱  10%│
  └─────────────────────────────────┘

  ⏭️  Try these to fill your dashboard:
  → /morning — start your day
  → /task add [task] — add your first task
  → /evening — log your day tonight
```
Calculate profile % from filled vs total fields in profile.md for active packs. Goals % from goals.md milestones. Tasks % = 0 if none exist.
5. Currency and date format from profile.md locale
6. Language matches user's language from profile.md
