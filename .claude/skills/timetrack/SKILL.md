---
name: Time Tracking
description: "Track time spent on projects. Start/stop timers, log manual entries, view reports. Use when the user needs to track project hours or view time reports."
user_invocable: true
command: /timetrack
model: haiku
---

# /timetrack — Project Time Tracking

Track time spent on projects. Start/stop timers, log entries, view reports. Powered by @coo.

**Adapt to tech_comfort:** "not technical" → simple language. "I use apps" → name tools. "I code" → technical details OK.

---

## Subcommands

| Command | What it does | When to use |
|---------|-------------|------------|
| `/timetrack start [project]` | Start timer | Begin working on a project |
| `/timetrack stop` | Stop timer, log entry | Done working |
| `/timetrack log [project] [duration] [description]` | Manual entry | Retroactive logging |
| `/timetrack report` | This week/month by project | Overview |

---

## Data Sources (batch loading — 1 turn)

**Issue ALL reads in one batch:**
- `profile.md` (full) → business context
- `state/projects.md` (full) → active projects, hours estimated
- `state/time-log.md` (full) → existing entries, active timer

---

## /timetrack start [project] — Start Timer

### Protocol:
1. Batch read: profile.md, projects.md, time-log.md
2. If no project specified → `AskUserQuestion`:
   - header: "Project"
   - options: [list active projects from projects.md]
3. Check time-log.md for active timer → if one exists, ask: "Timer running for [project] since [time]. Stop it first?"
4. Record active timer in time-log.md Summary: `Active timer | [project] since [ISO timestamp]`
5. Also save to @coo agent memory: `active_timer: {project: "[name]", started: "[ISO]"}`
6. Confirm:
```
⏱️ Timer started for [project]
Started: [time]
```

---

## /timetrack stop — Stop Timer

### Protocol:
1. Read time-log.md + @coo memory for active timer
2. If no active timer → "No timer running. Use `/timetrack start [project]` to begin."
3. Calculate elapsed time (round to nearest 15 min)
4. `AskUserQuestion`:
   - header: "Description"
   - options:
     - "[auto-suggested based on project]"
     - "Custom — I'll type it"
5. Log entry to time-log.md Active section
6. Update time-log.md Summary: clear active timer, update weekly total
7. Update projects.md → Hours actual for this project
8. Confirm:
```
⏱️ Timer stopped
Project: [name]
Duration: [Xh Ym]
Logged to time-log.md + projects.md
```

---

## /timetrack log [project] [duration] [description] — Manual Entry

### Protocol:
1. If args missing → ask via AskUserQuestion (project from projects.md list, duration, description)
2. Add entry to time-log.md Active section
3. Update projects.md hours
4. Confirm: "✅ Logged [duration] for [project]: [description]"

---

## /timetrack report — Time Report

### Protocol:
1. Batch read: time-log.md, projects.md
2. Calculate:
   - This week: total hours, by project breakdown
   - This month: total hours, by project breakdown
   - Per project: actual vs estimated hours
   - Effective rate: if project has rate → calculate $/hour based on actual time

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⏱️ TIME REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  THIS WEEK
  ┌─────────────────────────────────┐
  │ Project        │ Hours │ Est.  │
  │────────────────│───────│───────│
  │ [Project A]    │ 12h   │ 20h   │
  │ [Project B]    │  5h   │ 10h   │
  │────────────────│───────│───────│
  │ Total          │ 17h   │       │
  └─────────────────────────────────┘

  EFFECTIVE RATE
  [Project A]: [rate]/h (est: [original rate]/h)
  [Project B]: [rate]/h

  MONTHLY TOTAL: [X]h
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Context-Bus Signals

After time logged:
```
@coo → @cfo, Type: data, Priority: info, TTL: 7 days
Content: [X]h logged for [project]. Total: [Y]h / [Z]h estimated.
Status: pending
```

---

## State Files
- **Read:** profile.md, projects.md, time-log.md
- **Write:** time-log.md (timer state, entries), projects.md (hours actual)

---

## Rules

1. Timer persists in time-log.md Summary AND @coo memory (survives session restarts)
2. Round durations to nearest 15 min
3. All reads in 1 batch turn
4. Use AskUserQuestion for all choices
5. Always update projects.md hours when logging time
6. Show actual vs estimated when data is available
7. Language matches user's language from profile.md
8. Max 2 context-bus signals per execution
