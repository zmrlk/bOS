---
name: Log Workout
description: "Log a workout or exercise session. Quick entry for fitness tracking."
user_invocable: true
command: /workout
---

# Log Workout

## Usage
User provides: type, duration, notes.
Examples:
- `/workout gym 45min chest and triceps`
- `/workout run 30min 5k`
- `I did yoga for 20 minutes`

## Protocol

### Parse input
Extract: type (gym/run/swim/yoga/walk/home/sport/other), duration, description, date (default: today).

### Log

**Lite mode:** Append to `state/habits.md`:
```markdown
| [date] | [type] | [duration] | [description] |
```

### Respond
```
"💪 Logged: [type] — [duration] ([description])
Streak: [X days in a row]
[Encouraging note based on pattern]"
```

### Streak tracking
Count consecutive days with at least 1 workout entry.
- New streak → "Day 1. Let's build this."
- 3+ days → "3 days strong. Keep it rolling."
- 7+ days → "Full week! 🔥"
- Broken streak → "Starting fresh. Yesterday doesn't define today."
