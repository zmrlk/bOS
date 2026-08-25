<!-- Loaded by morning/SKILL.md — reference detail, not a skill. Newsletter/noise senders come from profile.md if set. -->

# Morning Briefing

Read `profile.md`. Check `active_packs`, `user_type`, `tech_comfort`, `communication_style`. Tailor the briefing.

**Adapt to user_type:** Employee → show work tasks, meetings, career tips (skip pipeline/pricing). Freelancer/Business → full business (pipeline, invoices, follow-ups). Student → study tasks, learning goals. Between things → motivation, exploration.
**Adapt to tech_comfort:** "not technical" → plain language, no jargon. "I use apps" → name tools. "I code" → technical details OK.
**Adapt to ADHD:** If `adhd_indicators` = yes/suspected in profile.md → shorter briefing (max 3 items), dopamine hooks ("Quick win first!"), chunk tasks to 15-25 min, add novelty element. Skip overwhelming lists.

## Step 0: Read state BEFORE asking anything

**Never open with a question.** Read the files first (Step 1), then decide whether a question is even needed.

Energy level comes from state, not from an interrogation:
1. If today's row in `state/daily-log.md` already has an energy value → use it, say nothing.
2. If the user already mentioned how they feel in this conversation → use that.
3. Only if neither exists AND the briefing would materially change → one `AskUserQuestion`:
   - header: "Energy"
   - options: "🔋 Low (1-3)" / "⚡ Medium (4-6)" / "🔥 High (7-10)"
4. Otherwise assume medium and move on. A briefing with an assumed energy level beats a briefing gated behind a question.

Greeting is one line: `☀️ Good morning, [name].`

## Step 1: Parallel data fetch (ALL in 1 turn — this is the key improvement)

**CRITICAL: Launch ALL data fetches in parallel. Do NOT wait for one before starting another.**

Execute ALL of the following tool calls in a SINGLE turn:

### State files (Read tool — parallel batch):
- `state/projects.md` (Dashboard table — CRITICAL for multi-project awareness)
- `state/tasks.md` (first 25 lines — Summary)
- `state/daily-log.md` (first 25 lines — Summary)
- `state/habits.md` (full)
- `state/goals.md` (full)
- `state/pipeline.md` (full, if Business pack)
- `state/context-bus.jsonl` (last 20 lines; missing/empty is fine)

### MCP tools (parallel with state reads):

**Weather — bos-compound `weather_brief`:**
```
ToolSearch("select:mcp__bos-compound__weather_brief")
→ call with: { cities: [<city from profile.md → location; skip section if unset>] }
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
1. **Gmail newsletters:** `from:(<your newsletter senders from profile.md>) newer_than:1d` — skip if none set
2. **Gmail important:** `is:unread newer_than:1d -category:promotions -category:social -label:9-newsletter -label:10-marketing`
3. **Outlook important:** `afterDateTime: yesterday, limit: 15`

**Post-processing — filter noise:**
Automated senders (monitoring, POS, warehouse, shipping trackers) collapse into ONE counted summary line instead of individual entries. The user's own noise senders are learned over time and stored in `profile.md → email_noise_senders`; if that field is empty, treat any `noreply@` / `notifications@` / `alerts@` sender as noise on first pass and confirm with the user before persisting the rule.

**Morning email section format:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📧 EMAIL — last 24h
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📧 [Gmail sender] — [subject] → [1 line]
📨 [Outlook sender] — [subject] → [1 line]
🤖 automated: [X] alerts ([types])
```
Use 📧 for Gmail, 📨 for Outlook. Max 5 important emails + 1 automated summary line.
Failed payments (any billing provider) → always show with ⚠️ prefix.

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

**Rule: NEVER show "no data to display". Either show real data or skip the section entirely.**

## Step 1A: Proactive Checks (after data loading, before pattern insight)

**Decision review check** (from `state/decisions.md` if it exists → pending reviews):
If any decision has `review_date` ≤ today → nudge:
```
📋 Decision review due: "[title]" — decided [date]. Still the right call?
```
Offer: AskUserQuestion "Review now" / "Remind me tomorrow" / "Decision still stands"

**Goal Alarm:**
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
**Rules:** Max 1 goal alarm per morning. Rotate if multiple. Don't repeat same alarm 2 days in a row (track in native auto-memory).

**Network nudge** (from @coach — inner circle overdue):
If network.md has inner circle contacts with follow-up date 7+ days past → nudge (max 1):
```
👥 You haven't talked to [Name] in a while. Reach out today?
```

**Reminders** (from `state/reminders.md`, written by /remind):
If any reminder is due today or tomorrow:
```
📌 Reminder: [content] (due: [date])
```
Max 2. If more → "...and [N] more. Say /remind list."

## Step 1B: Pattern Insight (optional)

If `state/daily-log.md` holds enough history (14+ entries), you may surface ONE insight computed directly from the data — e.g. "Heads up: [day_of_week] is usually your low-energy day (avg [X]/10)", "Yesterday you trained → your data shows +[X] energy the next day", or "Low energy for [X] days straight — minimum viable day: 1 task + water + rest."

Rules: max 1 insight per /morning; only from numbers actually present in the files (never fabricate averages); hedging language ("your data suggests…"); skip silently in the first 2 weeks or when nothing fits today.

## Step 2: Briefing (personalized to energy level)

### Work Style Shaping (before pack-specific content)

Read `profile.md` → `work_style`. This shapes how tasks are presented in the briefing:

- **Sprinter** → Ask first: "Sprint day or rest day?" via `AskUserQuestion` (header: "Day mode", options: "🏃 Sprint — full power" / "🛋️ Rest — minimum viable"). Sprint → show 3-5 tasks in sprint blocks. Rest → show 1 micro-task only + "The rest can wait."
- **Scattered** → Show exactly 1 priority: "Today, one thing: [top task]." Hide everything else. After completing → reveal next. Never show a full task list.
- **Procrastinator** → Show deadlines with countdowns: "⏰ [task] — deadline in [X]h" for each task. Add: "First step: [smallest sub-task]. Do it in the next 15 min."
- **Steady** → Standard plan, consistent structure. Match what's been working.

If `work_style` is empty → skip this step (standard plan).

### If Business pack active:
- Open business tasks
- Any follow-ups due? (check pipeline.md → follow-up dates per @cmo Day 0/3/7/14 framework)
- Any deadlines within 3 days?
- **Invoices:** Check state/invoices.md for overdue or due-today invoices → "⚠️ Invoice [#] [client] — due today/overdue [X days]"
- **Active timer:** Check state/time-log.md Summary for active timer → if running → "⏱️ Timer for [project] running since [time]. Keep going or stop?"

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

☀️ Good morning, [name]!

[Pattern insight — if present, 1 line]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🗓️ TODAY — [day of week, date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[time] [event name] [location or link, if any]
[time] [event name]
...
🌅 Tomorrow: [1-2 most important events tomorrow, or "no events"]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📧 EMAIL — last 24h
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✉️ [Sender] — [subject] → [1 sentence: what it is + does it need a reply]
✉️ [Sender] — [subject] → [...]
[or: 📧 Inbox clear.]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📰 NEWS — AI / Tech / Business
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 [Source]: [1-2 sentences of the key insight]
📧 [Source]: [1-2 sentences]
[max 5 items — newsletters + RSS combined]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ TODAY'S PLAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[pack-specific briefing items]

⏭️ Quick win: [1 small action to do NOW]
```

### Section rules:
- **Weather** → in header bar (temperature + emoji). If unavailable → omit from header.
- **Calendar** → show if events exist. Flag back-to-back meetings: "⚠️ 3 meetings back-to-back". Tomorrow preview: max 2 events.
- **Emails** → max 5, prioritized: action-required > unread > FYI. If email requires reply → `⚡ reply required`. If 0 → "Inbox clear."
- **News** → merge newsletters (Gmail) + RSS into one "NEWS" section. Deduplicate by topic. Max 2 sentences per item. Max 5 items total. If both sources have same story → pick the better summary. If 0 → skip section.
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

If this is the user's first /morning (no entries in `state/daily-log.md` yet): open warmer — show what /setup already seeded (tasks, goal, habits, from the files), pick the first seeded task as today's focus, and mention that /evening exists for closing the day. No multi-day curriculum, no lecture. Then run the normal briefing.

## Session Ending (Peak-End Rule)
Always close /morning with a confidence statement based on DATA:
"You have [X] clear tasks, matched to your energy. Your completion rate on days like this is [X]%. You've got this."

If insufficient data for completion rate (first 2 weeks) → skip the percentage, just: "You have [X] clear tasks. One at a time. You've got this."

Never end with a question or open-ended prompt. End with confidence.

## Context Bus Writes (after briefing)

Helper only: `bash scripts/context-bus-append.sh <from> <to> <type> <priority> "<content>" [ttl_days]`

| Condition | from / to / type / priority / ttl |
|-----------|-----------------------------------|
| Energy ≤ 3 | `@boss` `@coach` `data` `normal` `3` — "Low energy today ([X]/10)" |
| Energy ≤ 3 for 3+ days | `@boss` `@coach` `insight` `critical` `7` — "Energy crash: [X] days" |
| 2+ overdue tasks | `@boss` `ALL` `data` `normal` `3` — "[X] overdue tasks" |
| Exercise/sleep insight | `@boss` `@coach` `insight` `info` `7` — "[insight]" |

**Rules:**
- Only write NEW signals — grep jsonl for the same topic today before duplicating
- Don't write info-priority signals more than once per week on same topic
- Never `echo >>` jsonl

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

Never display: "no data", "MCP unavailable", "not connected". If you can't get data → the section doesn't exist.

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
- If you have native auto-memory data about the user's patterns, use it
- If user has low energy pattern at this time → lighter suggestions
- End with confidence, not a question
