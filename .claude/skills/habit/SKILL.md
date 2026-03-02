---
name: Habit Manager
description: "Standalone habit manager — view streaks, add/remove habits, log completions. Gamified with milestones and personal bests."
user_invocable: true
command: /habit
---

# /habit — Habit Manager

Track habits, celebrate streaks, beat personal bests.

**Adapt to ADHD:** If `adhd_indicators` = yes/suspected → bigger celebrations, visual streaks, dopamine-friendly milestones.

---

## Usage

- `/habit` — show all habits with streaks
- `/habit add "X"` — add new habit
- `/habit done "X"` — mark habit done today
- `/habit remove "X"` — remove habit

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → adhd_indicators, active_packs, language
- `state/habits.md` (full, small file) → all habits, streaks, bests

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

### Subcommand: `/habit add "X"`

1. Parse habit name from args
2. Use `AskUserQuestion`:
   - header: "Częstotliwość"
   - options:
     - "Codziennie" (description: "Każdy dzień")
     - "3x w tygodniu" (description: "Co drugi dzień")
     - "2x w tygodniu" (description: "Dwa razy")
     - "1x w tygodniu" (description: "Raz w tygodniu")

3. Auto-assign owner agent:
   - Workout/exercise/training → @trainer
   - Reading/books → @reader
   - Meditation/mindfulness → @wellness
   - Finance/expense related → @finance
   - Learning/study → @teacher
   - Other → @wellness (default coordinator)

4. Add to habits.md: `| [name] | @[agent] | 0 | 0 | [today] | [frequency] |`
5. Confirm: "✅ Nawyk dodany: [name] ([frequency]). Powodzenia!"

### Subcommand: `/habit done "X"`

1. Fuzzy match habit name against habits.md
2. If no match → "Nie znalazłem '[X]'. Twoje nawyki: [list]. Który?"
3. If match found:
   - Check if already logged today → "Już zalogowane dziś. 👍"
   - Update: Streak +1, Last done = today
   - Check if new Streak > Best → update Best: "🏆 NOWY REKORD! [habit] — [X] dni z rzędu!"
   - Check milestones (3, 7, 14, 21, 30, 60, 90):
     - If hit: "🎉 MILESTONE! [habit] — [X] dni z rzędu! Następny cel: [next milestone]"
   - Normal log: "✅ [habit] — dzień [streak]. Keep going!"

### Subcommand: `/habit remove "X"`

1. Fuzzy match habit name
2. Use `AskUserQuestion`:
   - header: "Na pewno?"
   - options:
     - "Tak, usuń" (description: "Usuwam nawyk z listy")
     - "Nie, zostaw" (description: "Zachowuję nawyk")
3. If yes → remove from habits.md, confirm: "Usunięto [name]."

## Context-Bus Signals

| Condition | Signal |
|-----------|--------|
| Milestone hit (7, 14, 21, 30, 60, 90) | `@wellness → @coach, Type: data, Priority: info, TTL: 3 days, Content: Habit milestone: [habit] — [X] days!` |
| Streak broken (was ≥ 7 days) | `@wellness → @coach + @boss, Type: insight, Priority: normal, TTL: 7 days, Content: Streak broken: [habit] after [X] days. Check if systemic.` |

## State Files
- **Read:** profile.md, habits.md (full)
- **Write:** habits.md

## Rules
1. Use AskUserQuestion for all choices
2. Max 2 context-bus signals per execution
3. All reads in 1 turn (parallel I/O)
4. Fuzzy match for habit names (partial match, case-insensitive)
5. Never guilt on broken streaks — "Streaks reset. You don't."
6. Celebrate milestones enthusiastically (especially for ADHD users)
7. Personal best is ALL-TIME — never resets
8. Language matches user's profile language
