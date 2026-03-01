---
name: Evening Shutdown
description: "Daily evening shutdown ritual — reflect on the day, log energy, plan tomorrow. Run at the end of each day."
user_invocable: true
command: /evening
---

# Evening Shutdown

Read `profile.md`. Check `user_type`, `tech_comfort`, `communication_style`. Quick end-of-day ritual (~3 min).

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

### Step 3: Close
```
"Logged. Tomorrow starts with [#1 priority].

Get some rest. See you in the morning. ☀️"
```

## Session Ending (Peak-End Rule)
Always close /evening with a win highlight — the single best thing from the day:
"Today's highlight: you [specific achievement]. That's real progress. Tomorrow starts with [X]. Sleep well, [name]."

Never end with guilt or "should have done more." Always find the win.

## Rules
- Keep it to 3 questions MAX
- Don't lecture about what wasn't done
- Celebrate what WAS done ("Nice work on [X]")
- If user reports low energy → "Rest is productive too. No guilt."
- Save patterns to agent memory (energy trends, productive days)
