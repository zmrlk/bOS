---
name: Cron Schedules
description: "Schedule bOS skills to run automatically. Morning briefings, evening shutdowns, standups — on autopilot via n8n cron or in-app fallback."
user_invocable: true
command: /schedule
---

# /schedule — Cron Schedules

Automate your bOS rituals. Set it, forget it, get results delivered.

---

## Usage

- `/schedule` — list all schedules with status
- `/schedule add` — create new scheduled skill (guided)
- `/schedule remove [name]` — deactivate a schedule
- `/schedule pause [name]` — pause without deleting
- `/schedule resume [name]` — resume paused schedule
- `/schedule test [name]` — run the skill now (test fire)

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → language, scheduled_skills, mobile_platform, timezone
- `state/schedules.md` (full, small file) → existing schedules
- If Pro mode → query `schedules` table instead

If `state/schedules.md` doesn't exist → create silently with schema from `state/SCHEMAS.md` (schedules.md section).

---

### Subcommand: `/schedule` (list)

**Pro mode query:**
```sql
SELECT name, skill, cron_expression, delivery_channel, is_active, last_run, next_run
FROM schedules
ORDER BY is_active DESC, next_run ASC;
```

**Lite mode:** Read `state/schedules.md`.

**Display format:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⏰  SCHEDULES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Active: [X] schedules

  1. ✅ morning — /morning @ 8:00 daily → telegram
     Last: [date] | Next: [date]

  2. ✅ evening — /evening @ 21:00 daily → telegram
     Last: [date] | Next: [date]

  3. ⏸️ standup — /standup @ 9:00 Mon → in-app (paused)
     Last: [date]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**If no schedules:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⏰  SCHEDULES — empty
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  No scheduled skills yet.

  Popular schedules:
  → /morning at 8:00 daily
  → /evening at 21:00 daily
  → /standup at 9:00 Monday

  → /schedule add to create one
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Subcommand: `/schedule add`

**Step 1:** Select skill to schedule.

AskUserQuestion:
- header: "Skill"
- options:
  - "/morning — Morning briefing" (description: "Daily energy check + priorities")
  - "/evening — Evening shutdown" (description: "Day review + tomorrow prep")
  - "/standup — Team standup" (description: "All agents report in")
  - "/home — Dashboard" (description: "Quick status overview")

If user picks "Other" → ask which skill command.

**Step 2:** Select frequency.

AskUserQuestion:
- header: "Frequency"
- options:
  - "Daily" (description: "Every day at a set time")
  - "Weekdays" (description: "Monday to Friday")
  - "Weekly" (description: "Once a week on a specific day")
  - "Custom cron" (description: "Advanced: write your own cron expression")

**Step 3:** Set time.

AskUserQuestion:
- header: "Time"
- options (based on skill):
  - For /morning: "7:00", "8:00 (Recommended)", "9:00"
  - For /evening: "20:00", "21:00 (Recommended)", "22:00"
  - For /standup: "8:00", "9:00 (Recommended)", "10:00"
  - For others: "8:00", "12:00", "18:00"

If "Custom cron" was selected → ask for cron expression (text input).

**Step 4:** Select delivery channel.

AskUserQuestion:
- header: "Deliver to"
- options:
  - "In-app (Recommended)" (description: "Shows result when you open bOS next. Free, no setup.")
  - "Telegram" (description: "Push notification to your phone. Requires n8n.")
  - "Email" (description: "Receive results via email. Requires n8n.")
  - "Slack" (description: "Post to Slack channel. Requires n8n.")

**Step 5:** Generate cron expression and save.

Build cron from selections. Examples:
- Daily 8:00 → `0 8 * * *`
- Weekdays 9:00 → `0 9 * * 1-5`
- Weekly Monday 9:00 → `0 9 * * 1`

**Pro mode:** Insert into `schedules` table.
**Lite mode:** Append to `state/schedules.md`.

**Step 6:** Setup delivery.

- **In-app:** No setup needed. @boss checks on session-start. Done.
- **Telegram/Email/Slack:** Check if n8n is connected.
  - If yes → offer to deploy the matching cron template from `templates/n8n/`
  - If no → "To deliver to [channel], you need n8n connected. /connect n8n to set it up. For now, I'll set it as in-app and you can switch later."

**Step 7:** Confirm.

```
✅ Schedule created:
  [name] — [skill] @ [time] [frequency] → [channel]

  Next run: [calculated date/time]
```

Give schedule a name: skill name by default (e.g., "morning", "evening"). If duplicate → append number.

---

### Subcommand: `/schedule remove [name]`

1. Find schedule by name
2. Confirm: "Remove schedule '[name]' ([skill] @ [time])?"
3. **Pro mode:** Delete from `schedules` table
4. **Lite mode:** Remove from `state/schedules.md`
5. Inform: "If this had an n8n workflow, deactivate it manually in n8n dashboard."

---

### Subcommand: `/schedule pause [name]` / `/schedule resume [name]`

1. Find schedule by name
2. Toggle `is_active` (Pro: UPDATE, Lite: edit schedules.md)
3. Confirm: "Schedule '[name]' [paused/resumed]."

---

### Subcommand: `/schedule test [name]`

1. Find schedule by name
2. Run the skill command immediately (invoke the skill)
3. Display result inline
4. Note: "This was a test run. Regular schedule unchanged."

---

## "In-App" Fallback (Zero-Cost Scheduling)

When `delivery_channel = 'in-app'`:

**@boss checks on session-start (Step 0.10):**
1. Load schedules (Pro: query, Lite: read schedules.md)
2. For each active in-app schedule:
   - Calculate if `next_run` has passed since last session
   - If overdue → run the skill, update `last_run`, calculate new `next_run`
3. Show result inline with session greeting

**Cron calculation (in-app):**
Parse cron expression, compare `last_run` + timezone to current time.
- If `next_run <= now` → overdue → run
- If `next_run > now` → skip

**Limitation:** In-app schedules only run when user opens bOS. If user doesn't open bOS for 3 days and has daily schedule → only the most recent execution runs (not 3 catches up). Show note: "Missed [X] scheduled runs while you were away. Running latest."

---

## Lite Mode State File

`state/schedules.md` — small file, read in full.

```markdown
# Schedules

| Name | Skill | Cron | Channel | Active | Last run | Next run |
|------|-------|------|---------|--------|----------|----------|
| morning | /morning | 0 8 * * * | telegram | yes | 2026-03-02 08:00 | 2026-03-03 08:00 |
| evening | /evening | 0 21 * * * | in-app | yes | 2026-03-01 21:00 | 2026-03-02 21:00 |
| standup | /standup | 0 9 * * 1 | in-app | paused | 2026-02-24 09:00 | — |
```

---

## State Write Protocol

- **Owner:** @boss (schedules.md and schedules table)
- **Readers:** all agents (can check if their skill is scheduled)

---

## Cross-Agent Signals

### I POST when:
- Schedule created/modified → @boss (for session-start awareness)
- Schedule test run completed → source skill's agent

### I LISTEN for:
- Timezone changes from profile.md → recalculate all next_run values
- DND hours from @wellness/@organizer → suppress in-app delivery during DND
