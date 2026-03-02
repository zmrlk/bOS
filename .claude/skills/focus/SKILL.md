---
name: Deep Work Session
description: "Deep work session manager — pick a task, set a timer, log completion. ADHD-friendly focus tool."
user_invocable: true
command: /focus
---

# /focus — Deep Work Session

Start a focused work session with one task, one timer, one goal.

**Adapt to ADHD:** If `adhd_indicators` = yes/suspected → default to 25min Pomodoro, dopamine hooks, celebration on completion.
**Adapt to work_style:** Sprinter → intense bursts. Scattered → forced single-task. Steady → standard flow.

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → energy_pattern, work_style, adhd_indicators, peak_hours
- `state/tasks.md` (Summary + Active section) → today's undone tasks
- `state/daily-log.md` (first 25 lines — Summary) → today's energy level

### Step 2: Pick task

If user specified a task in args (e.g., `/focus write proposal`) → use that.
If no args → @coo picks the top undone task from today's list, matched to current energy:
- Energy ≤ 3 → pick lowest-energy task
- Energy 4-6 → pick medium task
- Energy ≥ 7 → pick highest-energy task

If no tasks exist → ask: "Na czym chcesz się skupić?"

### Step 3: Set duration

Use `AskUserQuestion`:
- header: "Czas sesji"
- options:
  - "🍅 25 min — Pomodoro" (description: "Krótki sprint, idealne na start")
  - "🔥 50 min — Deep work" (description: "Pełna sesja głębokiej pracy")
  - "⚡ 15 min — Quick sprint" (description: "Szybka akcja, jedno zadanie")

### Step 4: Start session

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🎯  FOCUS SESSION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Task: [task name]
  Time: [duration] min
  Rule: One task. Nothing else.

  Start now. Come back when done
  or when time is up.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 5: Completion check

When user returns, use `AskUserQuestion`:
- header: "Jak poszło?"
- options:
  - "✅ Skończyłem" (description: "Zadanie zrobione!")
  - "🔄 Postęp" (description: "Nie skończyłem, ale zrobiłem postęp")
  - "❌ Nie udało się skupić" (description: "Rozproszenia wygrały")

### Step 6: Log and celebrate

**If "Skończyłem":**
- Update tasks.md → mark task as ✅
- Log to daily-log.md Notes: "Focus session: [task] — [duration]min ✅"
- Celebration (ADHD-adapted): "BOOM! [X] min czystego focusu. 🔥"

**If "Postęp":**
- Log to daily-log.md Notes: "Focus session: [task] — [duration]min (progress)"
- "Postęp się liczy. Kontynuujesz czy przerwa?"

**If "Nie udało się":**
- Log to daily-log.md Notes: "Focus session: [task] — attempted [duration]min"
- No guilt: "Każdy ma takie dni. Spróbuj 15 min zamiast [duration]?"

Track in @coo memory: `focus_sessions_this_week: [count]`

## Context-Bus Signals

| Condition | Signal |
|-----------|--------|
| Session completed | `@coo → @coach, Type: data, Priority: info, TTL: 3 days, Content: Focus session completed: [task], [duration]min.` |
| 3+ sessions this week | `@coo → @boss, Type: data, Priority: info, TTL: 7 days, Content: Focus streak: [X] sessions this week.` |

## State Files
- **Read:** profile.md, tasks.md (S+Active), daily-log.md (S)
- **Write:** tasks.md (status), daily-log.md (notes)

## Rules
1. ONE task per session — never suggest multitasking
2. Use AskUserQuestion for all choices
3. Max 2 context-bus signals per execution
4. All reads in 1 turn (parallel I/O)
5. ADHD users: shorter default, bigger celebration
6. Never guilt on failed sessions — reframe as data
7. Track sessions in @coo memory for velocity
