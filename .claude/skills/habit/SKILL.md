---
name: Habit
description: "Unified habit and quit tracker — view streaks, add/remove habits, log completions, track cessation (days free, money saved, health milestones). Gamified with milestones and personal bests. Use when the user says 'habit', 'streak', 'done', 'quit', 'how many days', 'how much saved', or logs a completed habit."
user_invocable: true
command: /habit
---

# /habit — Habit & Quit Tracker

Track habits, celebrate streaks, beat personal bests. Also owns cessation tracking (quit smoking, alcohol, any substance or behavior).

**Adapt to ADHD:** If `adhd_indicators` = yes/suspected → bigger celebrations, visual streaks, dopamine-friendly milestones.

---

## Usage

- `/habit` — show all habits with streaks
- `/habit add "X"` — add new habit
- `/habit done "X"` — mark habit done today
- `/habit remove "X"` — remove habit
- `/habit quit` — quit-tracking dashboard (days free, money saved, milestones)

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → adhd_indicators, active_packs, language
- `state/habits.md` (full, small file) → all habits, streaks, bests, Quit Tracking section

### Subcommand: `/habit` (show)

Render ASCII streak visualization:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔥  HABITS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  🏋️ Workout     ▰▰▰▰▰▱▱  5 days  🏆 14
  📖 Reading     ▰▰▰▰▰▰▰  7 days  🏆 12  🎯 14
  💰 Expenses    ▰▰▰▱▱▱▱  3 days  🏆 7
  🧘 Mindful     ▰▱▱▱▱▱▱  1 day   🏆 4

  ▰ = done  ▱ = missed  🏆 = best  🎯 = next milestone
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

- Show last 7 days as bars
- 🏆 = personal best (Best column)
- 🎯 = next milestone (3, 7, 14, 21, 30, 60, 90) — only show if streak is close (within 3 days)
- If a Quit Tracking section exists and is active → append one line per substance: `🚭 [substance]: day [X], saved [amount]`

### Subcommand: `/habit add "X"`

1. Parse habit name from args
2. Use `AskUserQuestion`:
   - header: "Frequency"
   - options: "Daily", "3× a week", "2× a week", "1× a week"

3. Auto-assign owner agent (only agents that exist in `.claude/agents/`):
   - Workout/exercise/training → @trainer
   - Reading/books → @reader
   - Food/meals/macros → @diet
   - Finance/expense related → @finance
   - Anything else → @coach (default coordinator)

4. Add to habits.md: `| [name] | @[agent] | 0 | 0 | [today] | [frequency] |`
5. Confirm: "✅ Habit added: [name] ([frequency])."

### Subcommand: `/habit done "X"`

1. Fuzzy match habit name against habits.md
2. If no match → "I don't have '[X]'. Your habits: [list]. Which one?"
3. If match found:
   - Check if already logged today → "Already logged today. 👍"
   - Update: Streak +1, Last done = today
   - Check if new Streak > Best → update Best: "🏆 NEW RECORD! [habit] — [X] days in a row!"
   - Check milestones (3, 7, 14, 21, 30, 60, 90):
     - If hit: "🎉 MILESTONE! [habit] — [X] days! Next: [next milestone]"
   - Normal log: "✅ [habit] — day [streak]. Keep going!"

### Subcommand: `/habit remove "X"`

1. Fuzzy match habit name
2. Use `AskUserQuestion`: "Sure?" → "Yes, remove" / "No, keep it"
3. If yes → remove from habits.md, confirm.

---

## Quit tracking

Cessation lives in `state/habits.md` under a `## Quit Tracking` section. Any substance or behavior — the schema is generic, the user names it.

```markdown
## Quit Tracking

| Substance | Quit date | Daily cost | Status |
|-----------|-----------|------------|--------|
| [name] | YYYY-MM-DD | [amount + currency] | active / planned |

### Milestones — [name]
| Milestone | When | Status |
|-----------|------|--------|
| 24h free | +1 day | ☐ |
| Craving peak survived | +3-6 days | ☐ |
| Sleep normalizing | +14 days | ☐ |
| Habit rewired | +66 days | ☐ |
```

Nicotine has well-documented physiological milestones worth using verbatim when the user quits smoking: 20 min heart rate normalizes · 8h CO halved · 48h taste/smell improving · 72h breathing easier · 2 weeks circulation improves · 1 month lung function +30% · 3 months circulation normal · 1 year heart disease risk halved. For other substances, ask the user or keep the generic four above — **never invent health claims**.

### Subcommand: `/habit quit`

**Step 1:** Read the Quit Tracking section.

**Step 2:** If it doesn't exist → set it up: `AskUserQuestion` for what they're quitting, quit date (or "planned"), and daily cost. Daily cost may also come from `finances.md` if the spend is already logged there. Create the section, then show the dashboard.

**Step 3:** Dashboard:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🚭 QUIT TRACKER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [substance]: [X] days free 🔥
  (or "starts [date]" if planned)

  💰 SAVED: [X × daily cost] [currency]

  🏥 LAST MILESTONE:
  ✅ [name] — [date achieved]

  ⏭️ NEXT MILESTONE:
  ☐ [name] — in [Z] days

  📊 STREAK: [current] days (best: [best])
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Step 4:** Mark newly achieved milestones, celebrate with one brief factual health note.

**Step 5:** `AskUserQuestion`: "How are you doing?" → "Good" / "Craving" / "Hard" / "Skip". On "Craving" or "Hard": acknowledge, restate money saved and the next milestone, offer a coping step. No lecture.

### Relapse handling

- NO JUDGMENT. Zero.
- "One day doesn't erase the progress. The [X] days behind you still count."
- `AskUserQuestion`: "Reset the counter?" → "Yes, start over" / "No, it was a slip — continuing" / "I need support"
- Streak uses DECAY: slip = −1 day, not a full reset (ADHD-friendly)
- Log to habits.md: `slip: [date], substance: [which], context: [if shared]`

### Ambient mode

During other skills, quit status shows as max one line: `🚭 Day [X] free from [substance]. Saved: [amount]`. Full dashboard only on explicit `/habit quit`.

---

## Context-Bus Signals

| Condition | Signal |
|-----------|--------|
| Milestone hit (7, 14, 21, 30, 60, 90) | `@coach → @boss, Type: data, Priority: info, TTL: 3 days, Content: Habit milestone: [habit] — [X] days!` |
| Streak broken (was ≥ 7 days) | `@coach → @boss, Type: insight, Priority: normal, TTL: 7 days, Content: Streak broken: [habit] after [X] days. Check if systemic.` |

## State Files
- **Read:** profile.md, habits.md (full), finances.md (only when deriving daily cost)
- **Write:** habits.md

## Rules
1. Use AskUserQuestion for all choices
2. Max 2 context-bus signals per execution
3. All reads in 1 turn (parallel I/O)
4. Fuzzy match for habit names (partial match, case-insensitive)
5. Never guilt on broken streaks — "Streaks reset. You don't."
6. Celebrate milestones enthusiastically (especially for ADHD users)
7. Personal best is ALL-TIME — never resets
8. Quit framing is always positive: what they GAINED. "Slipped", never "failed".
9. Never invent health claims or costs — read them from state or ask
10. Language matches the user's profile language
