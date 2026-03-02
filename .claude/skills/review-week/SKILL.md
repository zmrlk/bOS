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

### Step 0: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch of tool calls. Use Summary (first 25 lines) + Active sections for growing files:
- `state/tasks.md` (Summary + Active section) — this week's tasks completion
- `state/weekly-log.md` (Summary + Active section) — previous weeks for comparison
- `state/goals.md` (full) — active goals
- `state/habits.md` (full) — streaks (if Health/Life active)
- `state/finances.md` (Summary + Active section) — revenue/expenses (if Business/Finance active)
- `state/pipeline.md` (full) — pipeline status (if Business active)
- `state/daily-log.md` (Summary + Active section) — energy trends this week (14d window)

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

### Step 4B: Stale Profile Detection (after pack-specific updates)

Compare mutable profile.md fields against the last 14 days of behavioral data. Only check fields that have 14+ days of data available.

**Fields to check:**

| Profile field | Compare against | Contradiction example |
|---------------|----------------|----------------------|
| `work_style` | daily-log.md task completion patterns | Profile says "steady" but data shows sprint→crash cycles |
| `energy_pattern` | daily-log.md energy averages per day of week | Profile says "morning person" but highest energy logged in evenings |
| `fitness_level` | habits.md workout frequency (last 14 days) | Profile says "active" but 2 workouts in 14 days |
| `money_style` | finances.md impulse ratio (unplanned/total expenses) | Profile says "disciplined" but 40%+ impulse purchases |

**Protocol:**
1. Read profile.md → extract `work_style`, `energy_pattern`, `fitness_level`, `money_style`
2. Read state/daily-log.md (last 14 days), state/habits.md, state/finances.md
3. For each field with sufficient data (14+ days), compare profile claim vs actual behavior
4. If contradiction found → suggest update:
   ```
   "📊 Profil mówi: [field] = [current value]
    Dane z 2 tygodni: [observed pattern]
    Zaktualizować?"
   ```
5. Use `AskUserQuestion`: "Tak, zaktualizuj" / "Nie, zostaw" / per suggestion

**Rules:**
- Max 2 suggestions per review (pick the most contradictory)
- Only flag when data CLEARLY contradicts — borderline cases → skip
- Skip fields that are empty in profile.md (nothing to contradict)
- Skip fields with < 14 days of data
- If user approves → update profile.md (backup first per State Write Protocol)

### Step 4C: Calibration Review (after stale profile detection)

Check @boss agent memory for agent feedback data from the last 14 days.

**Protocol:**
1. Search agent memory for "Nietrafione" feedback entries per agent
2. If any agent has 3+ "Nietrafione" in the last 14 days → flag:
   ```
   "⚠️ @[agent] otrzymał [X] negatywnych ocen w ostatnich 2 tygodniach.
    Rekalibracja?"
   ```
3. Use `AskUserQuestion`: "Tak, porozmawiajmy" / "Pomiń"
4. If "Tak" → ask: "Co @[agent] powinien robić inaczej?" (open text)
5. Save recalibration notes to the agent's memory
6. Post to context-bus:
   ```
   ## [date] @boss → @[agent]
   Type: calibration
   Priority: normal
   TTL: 7 days
   Content: Recalibration requested. User feedback: [summary]. Adjust approach.
   Status: pending
   ```

**Rules:**
- Max 2 agents flagged per review (prioritize by highest negative count)
- If no agents have 3+ negatives → skip this step silently
- Don't flag agents the user hasn't interacted with in 14 days

### Step 4D: Freshness Audit (after calibration review)

**1. Profile freshness scan:**
Parse `<!-- freshness: YYYY-MM-DD -->` headers from profile.md (already loaded in Step 0).
Check each active pack section against Memory Freshness Hierarchy thresholds (CLAUDE.md):
- Static fields: fresh if <365d
- Semi-static fields: fresh if <90d, stale if 91-180d, expired if >180d
- Dynamic fields: fresh if <30d, stale if 31-60d, expired if >60d

If any section has EXPIRED dynamic fields (max 2 suggestions per review):
```
"📊 Freshness check:
→ [section] — [field] last updated [X] days ago.
  Current value: [value]. Still accurate?"
```
Use `AskUserQuestion`: "Tak, zaktualizuj" / "Nadal aktualne" / "Pomiń"
- If "Tak" → ask for new value, update profile.md + freshness header
- If "Nadal aktualne" → update freshness header only (re-stamp)
- If "Pomiń" → skip

**2. Agent memory consolidation:**
For agents the user interacted with this week:
- Merge duplicate observations (same insight saved multiple times)
- Add timestamps to undated entries: "As of [month YYYY]: ..."
- Archive entries older than 180 days to a summary note

**3. State file health check:**
Flag growing state files that need attention:
- Archive section >500 lines → "Archive ready to move to separate file"
- Summary metadata stale → refresh

**4. Context-bus cleanup:**
- Count expired entries. If >5 expired → archive to `state/archive/context-bus-[YYYY-MM].md`
- Count `acted-on` entries. If >5 → archive alongside expired.

**Rules:**
- Max 2 freshness suggestions per review (pick the most expired)
- Skip fields that are empty (nothing to verify)
- This entire step should take <2 minutes of user time
- Freshness audit uses already-loaded data — ZERO extra file reads

### Context Bus Writes (after review)

Post weekly summary signals to context-bus.md:

| Condition | Write to context-bus.md (use canonical format: ## date, Type, Priority, TTL, Content, Status) |
|-----------|------|
| Always (after review) | `@boss → all` / `Type: data` / `Priority: info` / `TTL: 7 days` / `Content: Week [date] summary: [X/Y] tasks ([Z]%), goal [achieved/partial/missed], lesson: [1-line]` |
| Completion rate < 60% | `@boss → @coo` / `Type: insight` / `Priority: normal` / `TTL: 7 days` / `Content: Weekly completion [X]%. Tasks may be too large or too many.` |
| Completion rate > 90% | `@boss → @coo` / `Type: insight` / `Priority: info` / `TTL: 7 days` / `Content: High completion [X]%. User can stretch.` |
| Spending spike this week | `@boss → @finance` / `Type: insight` / `Priority: normal` / `TTL: 7 days` / `Content: Weekly spending [X]% above average.` |
| Multiple broken streaks | `@boss → @wellness, @coach` / `Type: insight` / `Priority: normal` / `TTL: 7 days` / `Content: [X] streaks broken this week. Check if systemic.` |

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

## Identity Ledger (every 2 weeks, or weekly if completion > 80%)

**Frequency:**
- Default: show every 2 weeks (check @boss memory: `last_identity_ledger: [date]`)
- If last week's completion rate > 80% → show weekly (reward consistency)
- Never show if less than 7 days of data since last ledger

**Connected to @boss Week 2 Reveal:** The Identity Ledger IS the recurring version of the one-time Week 2 Reveal. After the Week 2 Reveal fires (at ~14 days), the Identity Ledger takes over on the bi-weekly/weekly schedule.

Based on accumulated behavior data (NOT aspirations — ACTIONS), generate identity statements:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🪞  IDENTITY LEDGER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Based on your data:

  → You are someone who [behavior + number].
    ([X]/[Y] days active this period)

  → You are someone who [behavior + number].
    (buffer ↑ [X]% / streak [Y] days / etc.)

  → You are someone who [behavior + number].
    ([specific metric from state files])

  This is not a compliment. This is a fact.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Statement generation rules:**
- ONLY use data from state files (tasks.md completion, habits.md streaks, finances.md buffer, daily-log.md attendance)
- Each statement = behavior + concrete number. No adjectives, no superlatives.
- Max 3 statements per ledger
- Only include statements where data is POSITIVE. Skip negative trends — the ledger builds identity, it doesn't tear it down.
- If no positive data → skip the ledger entirely this cycle
- Never fabricate. Never use motivational language. Frame as observation: "This is not a compliment. This is a fact."

**Save:** Update @boss memory `last_identity_ledger: [today's date]`
