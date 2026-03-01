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

## Data Sources (batch loading)

**Issue ALL reads/queries in one batch of tool calls** — host runs them concurrently. Then render dashboard from loaded data.

**Always (Lite mode) — batch Read calls:**
- `profile.md` → name, user_type, active_packs, primary_goal
- `state/tasks.md` → today's tasks (count done/total)
- `state/daily-log.md` → today's energy level
- `state/habits.md` → streaks (if Health or Life pack active)
- `state/finances.md` → buffer status (if Finance active)

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
  │  🏋️ Workout   ▰▰▰▰▱  4 days   │
  │  📖 Reading   ▰▰▱▱▱  2 days   │
  │  💤 Sleep 7h+ ▰▰▰▱▱  3 days   │
  │  🧘 Mindful   ▰▱▱▱▱  1 day    │
  └─────────────────────────────────┘
```

- Show only habits that have at least 1 entry
- Progress bar: ▰ = active day, ▱ = missed, show last 5 days
- Max 5 habits shown
- If no habits tracked yet → skip this block entirely (don't show empty)

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
4. If everything is empty (fresh install, no data) → show only TODAY block with a welcome message: "Your dashboard will fill up as you use bOS. Start with '/morning' or just tell me about your day."
5. Currency and date format from profile.md locale
6. Language matches user's language from profile.md
