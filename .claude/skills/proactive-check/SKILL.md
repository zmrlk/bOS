---
name: Proactive Check
description: "Runs silently at session start. Checks all agents' proactive triggers against current state. Surfaces the most important 1-2 nudges."
user_invocable: false
command: /proactive-check
---

# Proactive Check

Runs silently at session start — BEFORE responding to the user's first message. Never announce that you're running this check.

### Trigger Mechanism
/proactive-check is triggered by @boss at session start:
1. @boss loads profile.md + state files (per CLAUDE.md session start protocol)
2. As part of that load, @boss runs proactive-check logic INLINE (not as separate skill invocation)
3. This means: @boss reads state, checks triggers, surfaces top 2 nudges — all in one turn
4. No separate hook mechanism needed — it's part of @boss's session start behavior

**Priority order for nudges (when multiple triggers fire):**
1. CRITICAL: Crisis signals in context-bus (always surface)
2. HIGH: Overdue tasks (>2 days), buffer below target
3. MEDIUM: Habit streak at risk (>2 days gap), follow-up due
4. LOW: Profile incomplete, weekly review due
Surface TOP 2 only. Never more than 2 nudges at session start.

## Protocol

### Step 1: Load state (Summary-only — zero full-file reads)
All data comes from Summary sections (first 25 lines) already loaded by @boss at session start. No additional reads needed.

**Data from Summaries:**
- `tasks.md` Summary → "Overdue: X tasks", "Today: X/Y done"
- `finances.md` Summary → "Buffer: X%", "Impulse ratio: X%"
- `habits.md` (full, small file) → streak data, missed days
- `pipeline.md` (full, small file) → stale leads (if business pack active)
- `daily-log.md` Summary → "Energy 7d avg: X", "Energy trend: ↓"

### Step 2: Check triggers from Summary metrics

For each domain, evaluate:

**Tasks:**
- Any task overdue by 2+ days? → flag
- Any task that's been "in progress" for 5+ days without completion? → flag

**Finance:**
- Buffer below target? → flag
- Spending spike this week vs usual? → flag
- Impulse purchase in last 24h? → flag (gentle, not guilt)

**Habits:**
- Workout missed 3+ days in a row? → flag (if health pack active)
- Streak at risk today (hasn't logged yet)? → flag

**Pipeline / Follow-ups:**
- Any lead with no activity for 5+ days? → flag (if business pack active)
- Proposal sent but no response in 7+ days? → flag

**Energy patterns:**
- Last 3 days all low energy (≤4)? → flag for crash awareness

**Dormant Agent Activation (PROP-004 — evolution 2026-03-21):**
- If `pipeline.md` status = PUSTY for >14 days → surface @sales nudge:
  "Pipeline pusty od [X] dni. Może pora na /pitch practice albo /lead-research?"
  AskUserQuestion: "Zacznij od /lead-research" / "Zrób /pitch practice" / "Nie teraz"
- If `finances.md` Buffer = 0% for >30 days → surface @cfo nudge:
  "Buffer nadal 0 PLN. @cfo sugeruje: auto-przelew 4k/msc na osobne konto."
  AskUserQuestion: "Setup auto-savings" / "Sprawdź /budget" / "Odłóż"
- If ALL goals in `goals.md` have progress = 0% for >21 days → surface @coach nudge:
  "Wszystkie cele na 0%. Może trzeba je zmienić albo wybrać JEDEN na focus?"
  AskUserQuestion: "Przejrzyj cele /goal" / "Focus na 1 cel" / "Później"
- **Rules:** Max 1 dormant agent nudge per session. Rotate if multiple triggers fire. Don't re-nudge same agent within 7 days if user said "nie teraz".

### Step 3: Prioritize

From all flagged items, select MAX 2 — prioritize by:
1. Financial safety (buffer, debt)
2. Time-sensitive (deadline, stale lead)
3. Streak/habit (losing momentum)
4. Everything else

### Step 4: Surface

Prepend to normal response as a brief @boss note. Format:

```
💡 Quick heads up:
→ [Nudge 1 — specific, one line]
→ [Nudge 2 — specific, one line, only if truly important]
```

Then continue with the normal response to the user's message.

## Step 5: Anomaly Detection (behavioral deviation check)

Compare current state against user's established baselines. Anomalies = deviations from personal norms, NOT absolute thresholds.

### Anomaly types

| Domain | Baseline (from patterns) | Anomaly trigger | Nudge template |
|--------|--------------------------|-----------------|----------------|
| Sleep | avg sleep quality from daily-log | 3+ days below personal avg | "Sen poniżej Twojej normy od [X] dni — @wellness ma oko" |
| Energy | 7-day rolling avg from daily-log | 3+ consecutive days ≥2 below avg | "Energia spada — [current] vs Twoja średnia [avg]" |
| Spending | 4-week avg per category from finances | Category 50%+ above personal avg this week | "Wydatki na [kategoria] wyższe niż zwykle w tym tygodniu" |
| Task velocity | avg daily completions from tasks | 3+ days with 0 completions (when tasks exist) | "Żadne zadanie nie zamknięte od [X] dni" |
| Habits | personal streak patterns from habits | Active habit not logged for 2x usual gap | "[Nawyk] — dłuższa przerwa niż zwykle" |
| Workout | frequency from habits/daily-log | Missed 2x usual interval | "Trening — dłuższa przerwa niż Twój zwykły rytm" |

### How baselines work
- Baselines computed by @boss Pattern Analysis Protocol during /review-week
- Stored in @boss agent memory under `patterns:` structure
- If NO baseline exists (fresh user, <14 days data) → skip anomaly detection entirely
- Never compare to absolute norms ("you should sleep 8h") — only to user's OWN patterns

### Anomaly priority (within proactive-check priority system)
- Anomalies rank as MEDIUM priority (between overdue tasks and streak-at-risk)
- Exception: spending anomaly + budget-tight constraint = HIGH priority
- Exception: energy anomaly + crash prediction = HIGH priority (compound signal)

### Compound signals (anomaly + existing alert = escalation)
- Energy anomaly + poor sleep alert → escalate to @wellness with both signals
- Spending anomaly + low buffer → escalate to @finance immediately
- Task velocity drop + energy drop → suggest lighter day, not guilt

### Rules for anomaly nudges
- Always use personal comparison: "niż zwykle" / "niż Twoja norma" / "vs Twoja średnia"
- Never absolute judgment: NOT "za mało śpisz" but "śpisz mniej niż Twoja norma"
- Compound signals get 1 nudge combining both: "Energia i sen poniżej normy — lżejszy dzień?"
- Max 1 anomaly nudge per session (counts toward the 2-nudge limit)

## Step 6: Serendipity Check (cross-domain insight, optional)

If proactive-check finds fewer than 2 nudges AND @boss memory has serendipity correlations with moderate+ strength → consider surfacing 1 serendipity insight as a nudge.

**Serendipity as nudge format:**
```
💡 Quick heads up:
→ [standard nudge if any]
→ 🔗 Twoje dane: [cross-domain correlation, 1 line]
```

**Rules for serendipity in proactive-check:**
- Only if <2 nudges from Steps 2-5 (don't displace critical/high nudges)
- Max 1 serendipity insight per session
- Don't repeat same correlation within 7 days (check @boss memory `last_serendipity_surfaced`)
- Serendipity and Variable Rewards are mutually exclusive per session

## Rules
- MAX 2 nudges. Never more.
- Each nudge is ONE line. No explanation needed — just the fact.
- Never guilt. State the fact, let user decide.
- If nothing triggered → show nothing. Silence is the default.
- Never tell the user you ran a check. Just surface the insight naturally.
- Don't repeat the same nudge two sessions in a row if user didn't act.
