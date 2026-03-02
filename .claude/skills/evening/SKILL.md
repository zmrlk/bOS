---
name: Evening Shutdown
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

Then use `AskUserQuestion`:
- header: "Energia"
- options:
  - "🔋 Niska (1-3) — spokojny dzień"
  - "⚡ Średnia (4-6) — normalny dzień"
  - "🔥 Wysoka (7-10) — produktywny dzień"

Then use `AskUserQuestion`:
- header: "Sen ostatniej nocy"
- options:
  - "😴 Dobrze się wyspałem"
  - "😐 Mogło być lepiej"
  - "😫 Źle spałem"

After energy + sleep, use `AskUserQuestion`:
- header: "Co poszło dobrze?"
- options (generate 2-3 from today's completed tasks or context, plus):
  - "[Completed task 1 from state/tasks.md]"
  - "[Completed task 2 from state/tasks.md]"
  - "Coś innego — powiem" (for non-task wins)

If no completed tasks today → replace task options with:
  - "Przetrwałem — to się liczy"
  - "Odpoczywałem (i to OK)"
  - "Coś innego — powiem"

Never make a zero-task day feel like failure.

If "Coś innego" → ask open text.

**If Health pack active:** Check habits.md for today's habits:
- Did user work out? → if not tracked: "Był trening dziś? (tak/nie/odpoczynek)"
- Hydration/reading/other tracked habits → quick yes/no per habit

Then ask open text: "Jaki #1 priorytet na jutro?"

### Step 1B: Pattern Comparison (if 7+ entries in daily-log, runs after Step 1)

**After user reports today's energy, compare with their baseline.**

Check @boss agent memory for energy patterns. If 7-day average exists:

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
3. If energy pattern is notable (3+ days of low energy, or sudden drop) → post to context-bus: `@boss → @wellness` with `Priority: normal`.

**Pro mode:** INSERT into daily_logs (energia, sleep, mood).

### Context Bus Writes (after logging)

After writing today's log, post relevant signals to state/context-bus.md:

| Condition | Write to context-bus.md |
|-----------|------------------------|
| Workout done today | `## [date] @boss → @trainer` / `Type: data` / `Priority: info` / `TTL: 3 days` / `Content: Workout logged [date]. Update streak.` / `Status: pending` |
| Bad sleep 3+ consecutive days | `## [date] @boss → @wellness` / `Type: insight` / `Priority: normal` / `TTL: 7 days` / `Content: Poor sleep pattern: [X] days. Sleep hygiene check needed.` / `Status: pending` |
| Energy pattern notable (3+ days low) | `## [date] @boss → @wellness` / `Type: insight` / `Priority: normal` / `TTL: 7 days` / `Content: Energy trend: [X] days below average.` / `Status: pending` |
| Habit streak milestone (7, 14, 21, 30 days) | `## [date] @boss → @coach` / `Type: data` / `Priority: info` / `TTL: 3 days` / `Content: [habit] streak: [X] days!` / `Status: pending` |

Use the canonical context-bus format from CLAUDE.md.

**Rules:**
- Check context-bus.md for existing signals before writing duplicates
- Max 2 signals per /evening session

### Step 3: Close
```
"Logged. Tomorrow starts with [#1 priority].

Get some rest. See you in the morning. ☀️"
```

## Session Ending (Peak-End Rule)
Always close /evening with a win highlight — the single best thing from the day:
"Today's highlight: you [specific achievement]. That's real progress. Tomorrow starts with [X]. Sleep well, [name]."

Never end with guilt or "should have done more." Always find the win.

## Optional Agent Feedback (~1 in 3 evenings)

If the user interacted with a specific agent today (check context-bus or session context), and @boss memory `feedback_asked_today` is false, approximately 1 in 3 sessions ask:

"How was @[agent]'s advice today?" via `AskUserQuestion`:
- "Trafne — exactly what I needed"
- "OK — decent"
- "Nietrafione — missed the mark"
- "Skip"

If asked → set `feedback_asked_today: true` in @boss memory. Save response to relevant agent memory.
If not asked or "Skip" → proceed to close. Never make this feel required.

## Work Style Adaptation

Read `profile.md` → `work_style` before starting the evening ritual.

- **Sprinter** → After energy check, ask: "Sprint day czy rest day?" via `AskUserQuestion` (header: "Typ dnia", options: "🏃 Sprint day" / "🛋️ Rest day"). Sprint day → celebrate intensity. Rest day → validate: "Rest days fuel sprints. Dobra strategia."
- **Scattered** → Compress to 1 question max (energy only). Skip "what went well" multi-select — instead: "Jedna rzecz, która dziś poszła dobrze?" (open text or skip). Goal: get in and out fast before attention drifts.
- **Procrastinator** → Show tomorrow's deadlines prominently in close: "Jutro: [task] — deadline za [X]h. Zaczynam z samego rana."
- **Steady** → Standard flow (no changes needed).

## Rules
- Keep it to 3 questions MAX (including optional feedback — if asked, it counts)
- Don't lecture about what wasn't done
- Celebrate what WAS done ("Nice work on [X]")
- If user reports low energy → "Rest is productive too. No guilt."
- Save patterns to agent memory (energy trends, productive days)
