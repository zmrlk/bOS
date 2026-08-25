---
name: remind
description: "Set time-based reminders ('remind me at 5pm to call the client'). Uses ntfy for push notifications and state/reminders.md for tracking. Use whenever user needs a timed reminder. Supports absolute time, relative time, or dates."
user_invocable: true
command: /remind
tier: core
---

# /remind — Reminders

## Protocol

### Step 1: Parse reminder

From user input, extract:
- **What:** action to remind about
- **When:** time (absolute: "at 5pm", relative: "in 2h", date: "on Friday")
- **Priority:** normal (default), urgent (explicit)

### Step 2: Store reminder

Append to `state/reminders.md`:
```
| {datetime} | {what} | pending | {priority} |
```

Create file with header if missing:
```markdown
# Reminders

| When | What | Status | Priority |
|------|------|--------|----------|
```

### Step 3: Set notification

**If ntfy configured** (check `.secrets/ntfy.env`):
- For a due-now reminder, send immediately via: `curl -H "Title: bOS Reminder" -H "Tags: bell" -d "{what}" "https://ntfy.sh/{topic}"`
- For a future time, use ntfy's scheduled delivery header: `-H "At: {datetime}"` (macOS has no reliable `at` daemon)

**If no ntfy:**
- Store in reminders.md only
- Session-start hook checks for overdue reminders and surfaces them

### Step 4: Confirm

```
⏰ Reminder set: {what}
→ {when} ({relative time from now})
```

## Rules
- Parse natural time expressions: "in an hour", "tomorrow morning", "Friday at 10", "in 30 min"
- "morning" = 8:00, "afternoon" = 14:00, "evening" = 19:00
- Overdue reminders shown at session start (session-start.sh checks reminders.md)
- Completed reminders marked `done` not deleted
- AskUserQuestion for ambiguous times: "When exactly?" [In 1h] [In 2h] [Tomorrow morning]
