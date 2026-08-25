---
name: Remind
description: "Set time-based reminders. 'Przypomnij mi o 17 żeby zadzwonić do [client]'. Uses ntfy for push notifications and state/reminders.md for tracking. Use whenever user needs a timed reminder. Supports absolute time, relative time, or dates."
user_invocable: true
command: /remind
tier: core
---

# /remind — Przypomnienia

## Protocol

### Step 1: Parse reminder

From user input, extract:
- **What:** action to remind about
- **When:** time (absolute: "o 17:00", relative: "za 2h", date: "w piątek")
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
- Use `at` command or calculate delay
- Send via: `curl -H "Title: bOS Reminder" -H "Tags: bell" -d "{what}" "https://ntfy.sh/{topic}"`

**If no ntfy:**
- Store in reminders.md only
- Session-start hook checks for overdue reminders and surfaces them

### Step 4: Confirm

```
⏰ Przypomnienie ustawione: {what}
→ {when} ({relative time from now})
```

## Rules
- Parse Polish time expressions: "za godzinę", "jutro rano", "w piątek o 10", "za 30 min"
- "rano" = 8:00, "po południu" = 14:00, "wieczorem" = 19:00
- Overdue reminders shown at session start (session-start.sh checks reminders.md)
- Completed reminders marked `done` not deleted
- AskUserQuestion for ambiguous times: "Kiedy dokładnie?" [Za 1h] [Za 2h] [Jutro rano]
