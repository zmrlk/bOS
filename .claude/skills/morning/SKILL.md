---
name: Morning Briefing
description: "Daily morning briefing — priorities, energy check, quick win. Run at the start of each day."
user_invocable: true
command: /morning
---

# Morning Briefing

Read `profile.md`. Check `active_packs`, `user_type`, `tech_comfort`, `communication_style`. Tailor the briefing.

**Adapt to user_type:** Employee → show work tasks, meetings, career tips (skip pipeline/pricing). Freelancer/Business → full business (pipeline, invoices, follow-ups). Student → study tasks, learning goals. Between things → motivation, exploration.
**Adapt to tech_comfort:** "not technical" → plain language, no jargon. "I use apps" → name tools. "I code" → technical details OK.
**Adapt to ADHD:** If `adhd_indicators` = yes/suspected in profile.md → shorter briefing (max 3 items), dopamine hooks ("Quick win first!"), chunk tasks to 15-25 min, add novelty element. Skip overwhelming lists.

## Step 0: Energy check (FIRST — before anything else)

The first thing the user sees is the energy question. This shapes the entire briefing.

```
☀️ Dzień dobry, [name].
```

Then immediately `AskUserQuestion`:
- header: "Energia"
- options:
  - "🔋 Niska (1-3) — spokojny dzień"
  - "⚡ Średnia (4-6) — normalny dzień"
  - "🔥 Wysoka (7-10) — jedziemy"

## Step 1: Batch data loading (1 turn, all parallel)

While processing energy answer, load data in one batch of tool calls. Use **Summary reads (first 25 lines)** for growing files, full reads for small files:

**Lite mode (batch Read calls — all in 1 turn):**
- `state/tasks.md` (first 25 lines — Summary) — today's task counts from Summary, then Active section for today's tasks
- `state/daily-log.md` (first 25 lines — Summary) — energy trend from Summary
- `state/habits.md` (full) — streaks (if Health/Life)
- `state/goals.md` (full) — active goals
- `state/pipeline.md` (full, if Business) — follow-ups
- Google Calendar MCP — today's events AND tomorrow's events (if available)
- Gmail MCP — 3 parallel queries (all in same turn, if available):
  - Newsletters last 24h: `from:([known newsletter senders from agent memory]) newer_than:1d`
  - Important non-newsletter emails: `newer_than:1d -label:newsletters -category:promotions -category:social is:inbox`
  - Overdue follow-ups: flagged/starred or `follow up` label

**Tier 2 (after Summary):** Read tasks.md Active section (today's date section) for specific task details.

**Pro mode:** Issue all Supabase SELECTs in one tool-use turn (tasks, daily_logs, leads, habits).

## Step 1.5: World Insights (Pro mode only — if Supabase connected)

Query world_insights table for unsurfaced insights from the last 24h:
```sql
SELECT type, content, confidence, domains FROM world_insights
WHERE acted_on = FALSE AND surfaced_at IS NULL
AND created_at > NOW() - INTERVAL '24 hours'
AND confidence >= 0.6
ORDER BY confidence DESC LIMIT 3;
```

If insights found → show max 2 in the briefing:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧠 bOS INSIGHTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 [insight content — 1-2 sentences]
💡 [second insight if exists]
```

After surfacing, mark as shown:
```sql
UPDATE world_insights SET surfaced_at = NOW() WHERE id IN (...);
```

**Rules:**
- Max 2 insights per morning (dopamine, not overwhelm)
- Skip if confidence < 0.6
- Skip if type = 'recommendation' and buffer = 0 (don't suggest spending)
- Lite mode: skip this section (no daemon running without Supabase)

## Step 1A: Proactive Checks (after data loading, before pattern insight)

**Decision review check** (from @ceo memory → pending_reviews):
If any decision has `review_date` ≤ today → nudge:
```
📋 Decision review due: "[title]" — decided [date]. Still the right call?
```
Offer: AskUserQuestion "Review now" / "Remind me tomorrow" / "Decision still stands"

**Network nudge** (from @mentor — inner circle overdue):
If network.md has inner circle contacts with follow-up date 7+ days past → nudge (max 1):
```
👥 Dawno nie rozmawiałeś z [Name]. Napisz dziś?
```

**Crash prediction** (requires 60+ days daily-log data, from @boss Predictive Nudges):
If @boss detects crash probability based on sprint length vs avg crash pattern:
```
⚡ Heads up: your pattern suggests lower energy today. Lighter plan.
```
→ Auto-reduce task suggestions to match predicted energy.

## Step 1B: Pattern Insight (if 7+ entries in daily-log, runs after Step 1 data loading)

**After Step 1 data loading, check @boss agent memory for patterns (from Pattern Analysis Protocol).**

If patterns exist with medium+ confidence AND today matches a pattern trigger → show exactly 1 insight:

**Energy-based insights (pick the most relevant ONE):**
- Low-energy day pattern: "Heads up: [day_of_week] is usually your low-energy day (avg [X]/10). I've scheduled lighter tasks."
- Post-rest day: "Yesterday was a rest day. Your data shows energy drops after rest days — consider a short walk to kickstart."
- Bad sleep detected: "Bad sleep recently → your energy averages [X] lower after poor sleep. Lighter plan today."
- Exercise boost: "Yesterday you trained → your data shows +[X] energy boost the next day. Let's use that!"
- Energy crash (2+ days low): "Low energy for [X] days straight. This is a pattern, not a failure. Minimum viable day: 1 task + water + rest."

**Rules:**
- Max 1 insight per /morning
- Only show when confidence is medium+ (14+ data points)
- Never show on first 7 days (not enough data)
- Hedging language for medium confidence, confident for high
- If no pattern matches today → skip this step silently

## Step 2: Briefing (personalized to energy level)

### Work Style Shaping (before pack-specific content)

Read `profile.md` → `work_style`. This shapes how tasks are presented in the briefing:

- **Sprinter** → Ask first: "🏃 Sprint day czy rest day?" via `AskUserQuestion` (header: "Tryb dnia", options: "🏃 Sprint — pełna moc" / "🛋️ Rest — minimum viable"). Sprint → show 3-5 tasks in sprint blocks. Rest → show 1 micro-task only + "Reszta poczeka."
- **Scattered** → Show exactly 1 priority: "Dziś jedno: [top task]." Hide everything else. After completing → reveal next. Never show a full task list.
- **Procrastinator** → Show deadlines with countdowns: "⏰ [task] — deadline za [X]h" for each task. Add: "Pierwszy krok: [smallest sub-task]. Zrób to w najbliższe 15 min."
- **Steady** → Standard plan, consistent structure. Match what's been working.

If `work_style` is empty → skip this step (standard plan).

### If Business pack active:
- Open business tasks
- Any follow-ups due? (check pipeline.md → follow-up dates per @sales Day 0/3/7/14 framework)
- Any deadlines within 3 days?
- **Invoices:** Check state/invoices.md for overdue or due-today invoices → "⚠️ Faktura [#] [klient] — płatna dziś/zaległa [X dni]"
- **Active timer:** Check state/time-log.md Summary for active timer → if running → "⏱️ Timer dla [projekt] działa od [czas]. Kontynuujesz czy zatrzymać?"

### If Life pack active:
- Today's #1 priority (matched to energy level)
  - header: "Energy level"
  (Energy already collected in Step 0 — use that value here)

### If Health pack active:
- Was there a workout yesterday? Is one planned today?
- Sleep quality reminder
- Hydration nudge

### If Learning pack active:
- Current learning streak
- Today's study goal (if any)

### 📰 Newslettery (last 24h) — run if Gmail MCP available AND user has known newsletter senders

Search Gmail for newsletters from the last 24 hours. Newsletter senders are discovered progressively:
- **Agent memory:** @boss stores newsletter senders as they're identified (from /scan-context, user mentions, or email patterns)
- **Profile interests:** Match newsletters to `profile.md → interests` field
- **First run:** If no senders known yet → skip. After first /scan-context or when user mentions newsletters → start tracking.

For each newsletter found, extract **1-2 key takeaways** (not full summaries, just the insight). Format:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📰 NEWSLETTERS — last 24h
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📧 [Newsletter name]: [1-2 sentence key insight]
📧 [Newsletter name]: [1-2 sentence key insight]
```

**Rules:**
- Max 2 sentences per newsletter. No fluff, just the actionable insight or key fact.
- If no newsletters in last 24h → skip section silently
- If 5+ newsletters found → pick top 3 most relevant to user's context (from profile interests + primary_goal)
- Language: match newsletter language (EN newsletter → EN summary, PL → PL)

### 📧 Emails — last 24h

Search Gmail for important non-newsletter emails from last 24 hours (exclude: promotions, social, newsletters, automated notifications).

Prioritize:
1. Emails requiring action/reply (known contacts from state/network.md inner circle)
2. Invoices / payments received or due
3. Emails from domains related to user's business (from profile.md → business section)
4. Anything the user hasn't read

Format:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📧 EMAILS — last 24h
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✉️ [Sender] — [subject] → [1 sentence what it is + if reply needed]
✉️ [Sender] — [subject] → [...]
```

**Rules:**
- Max 5 emails. If more → show top 5 by priority (action required > unread > FYI)
- If email requires reply → add `⚡ reply needed`
- If 0 important emails → show: "📧 No important emails. Inbox clear."
- Skip: automated system emails, newsletters, GitHub notifications, payment receipts with no action needed

### 🗓️ Calendar

Pull today's events AND tomorrow's preview from Google Calendar MCP. Format:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🗓️ TODAY — [day of week, date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[time] [event name] [location or link if available]
[time] [event name]
...
🌅 Tomorrow: [1-2 most important events or "no events"]
```

**Rules:**
- Show all today's events with time. If 0 events → "No meetings — open day."
- Flag back-to-back meetings: "⚠️ [N] meetings in a row — plan breaks"
- Check profile.md → sacred_rituals: if any event conflicts with sacred ritual → flag: "⚠️ Conflict with [ritual] at [time]"
- Tomorrow preview: max 2 events (the most important ones)
- If Calendar MCP unavailable → skip section silently

### If user has tracked interests (from profile.md → interests field, then agent memory):
- Run WebSearch for 2-3 topics user cares about (politics, markets, industry, weather)
- Show as brief bullets with source: "📰 [headline] — [source]"
- Max 3 items. If WebSearch fails → skip silently.
- If no interests tracked yet → skip this section entirely

### Always:
- 1 quick win (task < 15 min, high impact)
- "What do you want to focus on today?"

## Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[mode_icon] [MODE] | [HH:MM] | ⚡ [energy] | 📅 [N events]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

☀️ Good morning, [name]!

[Pattern insight — if available, 1 line]

[🧠 bOS INSIGHTS — if Pro mode and insights exist]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📰 NEWSLETTERS — last 24h
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📧 [Newsletter]: [insight]
📧 [Newsletter]: [insight]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📧 EMAILS — last 24h
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✉️ [Sender] — [subject] → [summary + ⚡ if reply needed]
[or: 📧 No important emails. Inbox clear.]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🗓️ TODAY — [day, date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[time] [event]
[time] [event]
🌅 Tomorrow: [1-2 key events]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ TODAY'S PLAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[pack-specific briefing items]

⏭️ Quick win: [1 small action to do RIGHT NOW]
```

## Low Battery Day (energy 1-3)

When user reports energy 1-3, or pattern suggests crash day:

```
Low energy day. That's fine.

LOW BATTERY DAY:
□ Drink water
□ [Pick 1 micro-task from state/tasks.md — smallest open task, or if none: "Reply to one message" / "Clear 3 items from inbox" / "Write down 1 thing on your mind"]
□ Log energy tonight (/evening)

That's it. Everything else can wait.
If you do more — great. If you don't —
you still had a complete day.

A Low Battery Day is not a failure. It's a strategy.
```

Frame Low Battery Day as SUCCESS, not fallback. Track Low Battery Days separately.
On next day: "Yesterday was a Low Battery Day. That's by design. Today: [normal plan]."

## First Morning (day after setup)

If this is the user's first /morning (check: no entries in state/weekly-log.md or `first_morning_shown` = false/missing in @boss agent memory):

**Reference seeded data from /setup.** Read state/tasks.md, state/goals.md, state/habits.md to show what's already there.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ☀️  FIRST MORNING, [name]!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  You already have:
  ✅ [X] tasks ready to go
  ✅ 1 goal set: [primary_goal short]
  ✅ [Y] habits to track
  [✅ Budget framework — if finances seeded]

  Today's focus:
  → [First seeded task by name]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🗓️  YOUR FIRST WEEK WITH bOS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Day 1 (today): Do your first task:
                  "[seeded task #1 title]"
  Day 2-3: Try /evening before bed
  Day 4: Talk to @[relevant agent]
         about [primary_goal]
  Day 5: Run /plan-week
  Day 7: Run /review-week

  Each step takes 5 min. After a week,
  your agents know you well enough to
  be genuinely useful.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then continue with the normal morning briefing using seeded data. Set `first_morning_shown: true` in @boss agent memory so this only shows once.

**First Morning motivational hook:**
"You're not starting from zero — your system is already working for you. [X] tasks, 1 goal, [Y] profile fields filled. Let's make Day 1 count."

## Session Ending (Peak-End Rule)
Always close /morning with a confidence statement based on DATA:
"You have [X] clear tasks, matched to your energy. Your completion rate on days like this is [X]%. You've got this."

If insufficient data for completion rate (first 2 weeks) → skip the percentage, just: "You have [X] clear tasks. One at a time. You've got this."

Never end with a question or open-ended prompt. End with confidence.

## Context Bus Writes (after briefing)

After completing the morning briefing, write relevant signals to state/context-bus.md:

| Condition | Write to context-bus.md |
|-----------|------------------------|
| Energy ≤ 3 (low battery day) | `## [date] @boss → @coo, @organizer` / `Type: data` / `Priority: normal` / `TTL: 3 days` / `Content: Low energy today ([X]/10). Lighten workload.` / `Status: pending` |
| Energy ≤ 3 for 3+ consecutive days | `## [date] @boss → @wellness` / `Type: insight` / `Priority: critical` / `TTL: 7 days` / `Content: Energy crash: [X] days of low energy. Check-in needed.` / `Status: pending` |
| Overdue tasks found (2+ days overdue) | `## [date] @boss → @coo` / `Type: data` / `Priority: normal` / `TTL: 3 days` / `Content: [X] overdue tasks. Reprioritize or reschedule.` / `Status: pending` |
| Pattern insight about exercise/sleep | `## [date] @boss → @trainer or @wellness` / `Type: insight` / `Priority: info` / `TTL: 7 days` / `Content: [insight summary]` / `Status: pending` |

Use the canonical context-bus format from CLAUDE.md (## date header, Type, Priority, TTL, Content, Status — each on its own line).

**Rules:**
- Only write NEW signals — check context-bus.md for existing recent signals on the same topic before writing duplicates
- Don't write info-priority signals more than once per week on same topic

## State Writes (after briefing)

**CRITICAL: Handle missing daily-log entry gracefully.**
Before writing today's energy:
1. Read state/daily-log.md (or query daily_logs table in Pro mode)
2. Check if today's date already has a row
3. If NO row exists → CREATE new row with today's date + energy
4. If row EXISTS (e.g., user ran /morning twice) → UPDATE energy, don't duplicate

**If daily-log.md doesn't exist** → create it with schema headers from state/SCHEMAS.md, then add entry.

**Lite mode:**
1. Write today's energy level to `state/daily-log.md` — append row with date, energy (from AskUserQuestion), leave other fields for /evening
2. If goals.md has active goals → reference the current goal in briefing
3. If `setup_extras_pending: yes` in profile.md AND this is the 2nd+ morning → briefly suggest ONE deferred setup item (mobile access OR connector), then set flag to `no`. Don't make this the focus — just a brief aside.

**Pro mode:** INSERT into daily_logs (data, energia) for the morning entry.

## Empty State (Graceful — never show "no data")
If state files are empty or missing:
- Create the file with template headers silently
- **Generate a starter plan from primary_goal** (read profile.md → primary_goal, active_packs):
  - Generate 1-2 tasks relevant to the user's primary_goal and active packs
  - Show as today's plan: "Based on your goal ([primary_goal]), here's your plan for today:"
  - Include 1 quick win (< 15 min) and 1 meaningful task
- If primary_goal is also empty → "Let's start simple: what's the ONE thing you want to get done today?"
- Never show empty tables, "N/A" blocks, or "no data" messages
- Never show raw error messages — always offer a constructive path forward

## Rules
- Keep it SHORT (5-8 lines max)
- Be specific, not generic
- If you have agent memory data about the user's patterns, use it
- If user has low energy pattern at this time → lighter suggestions
- End with an invitation, not a command
