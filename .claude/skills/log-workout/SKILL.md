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

### Before logging
Read `profile.md` for: fitness_level, preferred_activities, injuries, adhd_indicators.
- If injuries listed → check activity type is safe. Warn if risky.
- If adhd_indicators = yes → keep response short, add dopamine hook ("Quick win logged! 🎯")

### Context-Bus Signals
After logging, post to `state/context-bus.md`:
- **Workout logged:** `@trainer → @wellness, Type: data, Priority: info, TTL: 7 days, Content: "Workout: [type] [duration]", Status: pending`
- **Streak milestone (7+, 14+, 30+ days):** `@trainer → @coach, Type: data, Priority: normal, TTL: 14 days, Content: "Workout streak: [X] days! Celebrate.", Status: pending`
- **Streak broken (was 7+ days):** `@trainer → @coach + @wellness, Type: insight, Priority: normal, TTL: 7 days, Content: "Workout streak broken at [X] days. Check energy/stress.", Status: pending`

## State Files
- **Read:** state/habits.md, profile.md (fitness_level, injuries, adhd_indicators)
- **Write:** state/habits.md, state/context-bus.md
