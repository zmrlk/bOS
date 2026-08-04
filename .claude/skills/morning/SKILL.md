---
name: Morning
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

## Step 1: Parallel data fetch (ALL in 1 turn — this is the key improvement)

**CRITICAL: Launch ALL data fetches in parallel. Do NOT wait for one before starting another.**

While processing energy answer, execute ALL of the following tool calls in a SINGLE turn:

### State files (Read tool — parallel batch):
- `state/projects.md` (Dashboard table — CRITICAL for multi-project awareness)
- `state/tasks.md` (first 25 lines — Summary)
- `state/daily-log.md` (first 25 lines — Summary)
- `state/habits.md` (full)
- `state/goals.md` (full)
- `state/notes.md` (full)
- `state/pipeline.md` (full, if Business pack)
- `state/context-bus.md` (first 25 lines — Summary)

### MCP tools (parallel with state reads):

**Weather — bos-compound `weather_brief`:**
```
ToolSearch("select:mcp__bos-compound__weather_brief")
→ call with: { cities: ["Kraków"] }
```
If user has travel planned (from calendar or tasks) → add destination city.
Fallback: skip silently if tool unavailable.

**Calendar — Google Calendar MCP:**
```
ToolSearch("select:mcp__claude_ai_Google_Calendar__gcal_list_events")
→ call with: today's date range AND tomorrow's date range
```
Alternative (token-efficient): use bos-compound `calendar_brief` if available.
Fallback: skip silently if MCP unavailable.

**Email — Gmail + Outlook (dual inbox):**
```
ToolSearch("select:mcp__claude_ai_Gmail__gmail_search_messages,mcp__claude_ai_Microsoft_365__outlook_email_search")
```
Run 3 parallel email searches:
1. **Gmail newsletters:** `from:(rundown OR bensbites OR dharmesh OR mrugalski OR taaft) newer_than:1d`
2. **Gmail important:** `is:unread newer_than:1d -category:promotions -category:social -label:9-newsletter -label:10-marketing`
3. **Outlook important:** `afterDateTime: yesterday, limit: 15`

**Outlook post-processing — filter noise:**
- IGNORE `powiadomienia@[system-alerts@company.com]` → count by type for 1-line summary:
  - "Zamknięte punkty sprzedaży" → `pos_closed` count
  - "POS - sprzedaż awaryjna" → `pos_emergency` count
  - "Roznice magazynowe" → `inventory_diff` count
  - "Wykryto niedobory/nadwyżki" → `inventory_alert` count
- IGNORE `noreply@[noreply@client-company.com]` UNLESS subject contains "zamówienie" or "B2B"
- IGNORE any sender containing `inpost`
- Keep everything else

**Morning email section format:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📧 MAILE — ostatnie 24h
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📧 [Gmail sender] — [subject] → [1 line]
📨 [Outlook sender] — [subject] → [1 line]
🏭 [system-alerts]: [X] POS alertów, [Y] awaryj, [Z] magazyn
```
Use 📧 for Gmail, 📨 for Outlook. Max 5 important emails + 1 [system-alerts@company.com] summary line.
Failed payments (Stripe, Anthropic) → always show with ⚠️ prefix.

For each result, call `gmail_read_message` to get content (batch the reads).
Alternative (token-efficient): use bos-compound `email_digest` if available.
Fallback: skip silently if MCP unavailable.

**RSS — bos-compound `rss_digest`:**
```
ToolSearch("select:mcp__bos-compound__rss_digest")
→ call with: { hours_back: 24, max_items_per_feed: 3, fetch_full_content: false }
```
Default feeds are configured in the tool. Supplements Gmail newsletters.
Fallback: skip silently if tool unavailable.

**Web News — fallback when newsletters/RSS thin:**
If Gmail newsletters + RSS yield fewer than 3 news items, use WebSearch to fill the gap:
```
WebSearch("AI agents tools news today")
WebSearch("Claude Code Anthropic news today")
```
Pick top 2-3 relevant results. This ensures NEWSY section always has 3-5 items.
Topics to search: AI/agents, Claude/Anthropic, SaaS/startup, Polish tech.
**Rule:** Web search is FALLBACK only — prefer newsletters and RSS first (they're curated).

### Tool availability check:
Before calling any MCP tool, use `ToolSearch` to verify the tool schema is available.
If ToolSearch returns no match → skip that data source. Never error on unavailable tools.

**Rule: NEVER show "brak danych do pokazania". Either show real data or skip the section entirely.**

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

**Goal Alarm** (PROP-001 — evolution 2026-03-21):
Read `state/goals.md` Active Goals + Milestones. If any milestone has target_date < today AND status != done:
```
🚨 OVERDUE MILESTONE: "[milestone]" (goal: [goal name])
   Target: [date] — [X] days overdue
   → What's blocking this?
```
Show max 2 overdue milestones. If goal progress = 0% for >30d → add:
```
⚠️ [goal name] — 0% progress since [date]. Still a priority?
```
AskUserQuestion: "Work on this today" / "Update status" / "Deprioritize goal"
**Rules:** Max 1 goal alarm per morning. Rotate if multiple. Don't repeat same alarm 2 days in a row (track in @boss memory).

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

**Notes reminders** (from notes.md):
If notes.md has Active entries with type `reminder` and Due ≤ today or tomorrow:
```
📌 Przypomnienie: [note content] (termin: [date])
```
Max 2 reminders. If more → "...i jeszcze [N] przypomnień. Powiedz /note list."

## Step 1B: Pattern Insight OR Serendipity Insight (pick ONE — never both)

**After Step 1 data loading, check @boss agent memory for patterns AND cross-domain correlations.**

**Priority:** Serendipity Insight > Pattern Insight (cross-domain is rarer and more valuable). Show exactly 1, never both.

### Option A: Serendipity Insight (cross-domain correlation)

Check @boss agent memory for `serendipity.correlations` (computed during /review-week). If a correlation exists with strength moderate+ AND is relevant to today's context → show it:

**Cross-domain correlations to surface:**

| Domain A | Domain B | Insight template |
|----------|----------|-----------------|
| Exercise | Energy | "Kiedy trenujesz, następny dzień masz średnio +[X] energii. [Wczoraj trenowałeś → dziś powinno być dobrze / Dawno nie trenowałeś → rozważ]" |
| Sleep | Task completion | "Dni po dobrym śnie: [X]% tasków done. Po złym: [Y]%. Sen = Twój mnożnik produktywności." |
| Spending | Energy | "Twoje dane sugerują: w dni niskiej energii wydajesz więcej. Nie oceniam — flaguję pattern." |
| Workout streak | Other habits | "Kiedy regularnie trenujesz, inne nawyki trzymają się lepiej. Trening kotwiczny." |
| Planning | Completion | "Tygodnie z /plan-week mają [X]% wyższy completion. Planowanie jest boostem." |

**Rules:**
- Minimum 14 data points across BOTH domains
- Hedging language: "Twoje dane sugerują...", "Wygląda na pattern..."
- Max 1 serendipity insight per session
- Only actionable insights — skip if no clear "try this"
- Never moralize — state correlation, user decides
- Track in @boss memory: `last_serendipity_surfaced: [date]`, don't repeat same correlation within 7 days

### Option B: Pattern Insight (single-domain, fallback if no serendipity)

If no serendipity insight is relevant today → fall back to pattern insight:

**Energy-based insights (pick the most relevant ONE):**
- Low-energy day pattern: "Heads up: [day_of_week] is usually your low-energy day (avg [X]/10). I've scheduled lighter tasks."
- Post-rest day: "Yesterday was a rest day. Your data shows energy drops after rest days — consider a short walk to kickstart."
- Bad sleep detected: "Bad sleep recently → your energy averages [X] lower after poor sleep. Lighter plan today."
- Exercise boost: "Yesterday you trained → your data shows +[X] energy boost the next day. Let's use that!"
- Energy crash (2+ days low): "Low energy for [X] days straight. This is a pattern, not a failure. Minimum viable day: 1 task + water + rest."

### Rules (both options):
- Max 1 insight per /morning (serendipity OR pattern, never both)
- Only show when confidence is medium+ (14+ data points)
- Never show on first 7 days (not enough data)
- Hedging language for medium confidence, confident for high
- If no pattern or serendipity matches today → skip this step silently
- Serendipity and Variable Rewards are mutually exclusive per session (boss.md rule)

## Step 2: Briefing (personalized to energy level)

### Work Style Shaping (before pack-specific content)

Read `profile.md` → `work_style`. This shapes how tasks are presented in the briefing:

- **Sprinter** → Ask first: "Sprint day czy rest day?" via `AskUserQuestion` (header: "Tryb dnia", options: "🏃 Sprint — pełna moc" / "🛋️ Rest — minimum viable"). Sprint → show 3-5 tasks in sprint blocks. Rest → show 1 micro-task only + "Reszta poczeka."
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

### If Health pack active:
- Was there a workout yesterday? Is one planned today?
- Sleep quality reminder
- Hydration nudge

### If Learning pack active:
- Current learning streak
- Today's study goal (if any)

### Always:
- 1 quick win (task < 15 min, high impact)
- "What do you want to focus on today?"

## Format

Assemble the briefing from the data collected. **Only include sections that have actual data. Skip any section with no data — never show placeholder text.**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[mode_icon] [MODE] | [HH:MM] | ⚡ [energy] | 🌤️ [temp]°C [weather_emoji]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

☀️ Dzień dobry, [name]!

[Pattern insight — jeśli jest, 1 linia]

[🧠 bOS INSIGHTS — jeśli Pro mode i insights istnieją]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🗓️ DZIŚ — [dzień tygodnia, data]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[czas] [event name] [ew. lokalizacja lub link]
[czas] [event name]
...
🌅 Jutro: [1-2 najważniejsze eventy z jutra lub "brak eventów"]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📧 MAILE — ostatnie 24h
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✉️ [Nadawca] — [temat] → [1 zdanie co to jest + czy wymaga odpowiedzi]
✉️ [Nadawca] — [temat] → [...]
[lub: 📧 Skrzynka czysta.]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📰 NEWSY — AI / Tech / Biznes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 [Źródło]: [1-2 zdania kluczowego insightu]
📧 [Źródło]: [1-2 zdania]
[max 5 pozycji — z newsletterów + RSS łącznie]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ PLAN DNIA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[pack-specific briefing items]

⏭️ Quick win: [1 małe działanie do zrobienia TERAZ]
```

### Section rules:
- **Weather** → in header bar (temperature + emoji). If unavailable → omit from header.
- **Calendar** → show if events exist. Flag back-to-back meetings: "⚠️ 3 spotkania pod rząd". Sauna 16:00-17:00 is SACRED — flag conflicts. Tomorrow preview: max 2 events.
- **Emails** → max 5, prioritized: action-required > unread > FYI. If email requires reply → `⚡ odpowiedź wymagana`. If 0 → "Skrzynka czysta."
- **News** → merge newsletters (Gmail) + RSS into one "NEWSY" section. Deduplicate by topic. Max 2 sentences per item. Max 5 items total. If both sources have same story → pick the better summary. If 0 → skip section.
- **Plan** → energy-matched tasks. Quick win always last.

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

## MCP Fallback Chain

For EVERY external data source, follow this chain:
1. **bos-compound tool** (most token-efficient) → try first
2. **Native MCP** (Gmail, Google Calendar) → fallback if bos-compound unavailable
3. **Skip silently** → if no tool available, omit the section entirely

Never display: "brak danych", "MCP unavailable", "nie połączono". If you can't get data → the section doesn't exist.

## MCP Usage Across bOS (Global Pattern)

This pattern applies to ALL skills, not just /morning:

**When a skill needs external data:**
1. Check if a bos-compound tool exists for that data type (token-efficient)
2. Check if a native MCP exists (Gmail, Calendar, Supabase, etc.)
3. Check if web search can provide it
4. Skip gracefully if none available

**Tool discovery:** Use `ToolSearch` to verify tool availability before calling. Cache results mentally within the session — don't re-check tools you already verified.

**Parallel execution:** Always batch independent tool calls in a single turn. Weather + Calendar + Email + RSS = 1 turn, not 4.

## Rules
- Keep it SHORT (5-8 lines max per section)
- Be specific, not generic
- If you have agent memory data about the user's patterns, use it
- If user has low energy pattern at this time → lighter suggestions
- End with confidence, not a question
- **Model: sonnet** — morning needs tool orchestration + synthesis, haiku can't handle parallel MCP coordination well
