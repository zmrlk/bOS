---
name: Weekly Review
description: "Friday evening weekly review — scorecard, lessons, next week prep. Takes 10-15 minutes."
user_invocable: true
command: /review-week
---

# Weekly Review

Read `profile.md` (incl. `user_type`), `state/tasks.md`, `state/weekly-log.md`.

**Adapt to user_type:** Employee → work completion + career progress. Freelancer → revenue + client work + pipeline. Student → study goals. Between things → exploration + goal progress.

## Protocol

### Step 0: Batch data loading

Issue ALL reads/queries in one batch of tool calls:
- `state/tasks.md` — this week's tasks completion
- `state/weekly-log.md` — previous weeks for comparison
- `state/goals.md` — active goals
- `state/habits.md` — streaks (if Health/Life active)
- `state/finances.md` — revenue/expenses (if Business/Finance active)
- `state/pipeline.md` — pipeline status (if Business active)
- `state/daily-log.md` — energy trends this week

**Pro mode:** Issue all Supabase SELECTs in one tool-use turn.

### Step 1: Scorecard + Analysis FIRST (show data before asking)

Show the user their data BEFORE asking reflection questions — they can reflect better when they see the evidence:

```
"📊 Week of [date] — Scorecard

Goal: [week goal from plan]
Result: [achieved / partially / missed]

Tasks: [X/Y completed] ([Z]% completion rate)

📈 Patterns I notice:
[1-2 observations from this week + historical data if available]
```

### Step 2: Reflection (AFTER seeing data)
Ask (data already loaded — no waiting after user responds):
```
"Three quick questions:
1. What went well this week?
2. What didn't go as planned?
3. One lesson to carry forward?"
```

### Step 3: Suggestion (after user reflection)
After user responds, combine their reflection with the data to give:
```
"💡 Suggestion for next week:
[1 specific, actionable adjustment based on data + user's reflection]"
```

### Step 4: Pack-specific updates

**If Business active:**
- Pipeline status (new leads, closed deals, follow-ups due)
- Revenue this week vs goal

**If Health active:**
- Workouts completed vs planned
- Streaks maintained or broken

**If Learning active:**
- Study hours logged
- Progress on current goal

### Step 5: Log and close
Save to `state/weekly-log.md`:
```markdown
## Week of [date]
- Goal: [X]
- Result: [achieved/partial/missed]
- Completion: [X/Y tasks]
- Lesson: [user's lesson]
- Next week focus: [suggestion]
```

Then offer contextual follow-up via `AskUserQuestion`:

**header:** "Co dalej?"
**options (pick 2-3 based on review content):**
- "Zaplanuj tydzień (/plan-week)" — always available
- If an area needs attention → "Porozmawiaj z @[agent] o [temacie]"
- "Dobry weekend!" — close

### Completion rate triggers:
- <60% → "Tasks were too big. I'll cut them in half next week."
- 60-80% → "Solid week. Room to grow."
- >80% → "Great week. You can stretch a bit more next time."
- 0% → "What happened? No judgment — let's adjust the plan."

## Identity Ledger (monthly, or when enough data)

Based on accumulated behavior data (NOT aspirations — ACTIONS), generate identity statements:

"Based on your actions this month:

You are:
→ Someone who shows up. ([X]/[Y] days active)
→ Someone who protects their financial safety. (buffer ↑ [X]%)
→ Someone who finishes what they start. ([X]/[Y] commitments kept)

These aren't compliments. They're data."

Only show when there IS positive data. Never fabricate. Never use motivational language.
Frame as observation, not praise: "These aren't compliments. They're data."
