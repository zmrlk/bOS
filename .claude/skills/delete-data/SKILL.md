---
name: Delete My Data
description: "Delete all personal data from bOS. Resets profile, state files, and agent memory."
user_invocable: true
command: /delete-my-data
---

# /delete-my-data — Data Deletion

Wipes all personal data from bOS. This resets bOS as if you'd never set it up.

---

## What gets deleted

| Item | Action |
|------|--------|
| `profile.md` | Deleted entirely |
| `state/tasks.md` | Reset to blank template |
| `state/finances.md` | Reset to blank template |
| `state/habits.md` | Reset to blank template |
| `state/pipeline.md` | Reset to blank template |
| `state/decisions.md` | Reset to blank template |
| `state/weekly-log.md` | Reset to blank template |
| `state/goals.md` | Reset to blank template |
| `state/daily-log.md` | Reset to blank template |
| `state/projects.md` | Reset to blank template |
| `state/context-bus.md` | Reset to blank template |
| `state/.setup-progress.md` | Deleted if present |
| `state/.maintenance-log.md` | Reset to blank template |
| `state/archive/*` | Deleted |
| `state/.backup/*` | Deleted |
| `.secrets/vault.json` | Deleted (secrets wiped) |

**NOT deleted automatically:**
- Agent memory at `~/.claude/agent-memory/` — this is managed by Claude Code, outside bOS. Delete the folder manually if you want to clear it.
- Supabase data (Pro mode) — delete from your Supabase dashboard directly.

---

## Flow

### Step 1 — Show exactly what will happen

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⚠️   DELETE ALL DATA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  This will permanently delete:

  🗑️  profile.md              — your profile
  🗑️  state/tasks.md          — all tasks
  🗑️  state/finances.md       — financial log
  🗑️  state/habits.md         — habit history
  🗑️  state/pipeline.md       — all leads
  🗑️  state/decisions.md      — all decisions
  🗑️  state/weekly-log.md     — all reviews
  🗑️  state/goals.md          — all goals
  🗑️  state/daily-log.md      — daily logs
  🗑️  state/projects.md       — all projects
  🗑️  state/context-bus.md    — agent context
  🗑️  state/archive/          — archived data
  🗑️  state/.backup/          — profile backups
  🗑️  .secrets/vault.json     — all secrets

  State files will be reset to empty
  templates (not deleted, just blanked).

  ⚠️  This cannot be undone.

  NOT affected:
  • Agent memory (~/.claude/agent-memory/)
    → Delete manually if needed
  • Supabase data (if Pro mode)
    → Delete from Supabase dashboard

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 2 — Offer export first

Use `AskUserQuestion`:
- header: "Before you delete"
- options:
  - "Export first, then delete — I want a backup"
  - "Skip export — delete everything now"
  - "Actually, cancel — I changed my mind"

If "Export first" → run `/export` skill, then return to this flow after export completes.
If "Cancel" → stop immediately.

### Step 3 — Final confirmation

Use `AskUserQuestion`:
- header: "Final confirmation"
- options:
  - "Yes, permanently delete everything"
  - "Cancel — keep my data"

- If user selects "Yes, permanently delete everything" → proceed to Step 4
- If user selects "Cancel — keep my data" → "Cancelled. Your data is intact."

### Step 4 — Delete with progress

Show each deletion as it happens:

```
⏳ Deleting your data...

  🗑️  profile.md .............. ✅ deleted
  🗑️  state/tasks.md .......... ✅ reset
  🗑️  state/finances.md ....... ✅ reset
  🗑️  state/habits.md ......... ✅ reset
  🗑️  state/pipeline.md ....... ✅ reset
  🗑️  state/decisions.md ...... ✅ reset
  🗑️  state/weekly-log.md ..... ✅ reset
  🗑️  state/goals.md .......... ✅ reset
  🗑️  state/daily-log.md ...... ✅ reset
  🗑️  state/projects.md ....... ✅ reset
  🗑️  state/context-bus.md .... ✅ reset
  🗑️  state/archive/ .......... ✅ cleared
  🗑️  state/.backup/ .......... ✅ cleared
  🗑️  state/.setup-progress.md  ✅ deleted
  🗑️  .secrets/vault.json ..... ✅ deleted
```

For files that don't exist → mark as `⏭️ skipped (not found)`.

### Step 5 — Done

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✅  All data deleted
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  bOS has been reset. Your profile and
  all personal data have been removed.

  To remove agent memory:
  → Delete: ~/.claude/agent-memory/

  To remove Supabase data:
  → Go to your Supabase dashboard
  → Drop tables or delete project

  To start fresh:
  → Type /setup

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## State file reset templates

When resetting a state file (not deleting), write the following blank template:

### state/tasks.md
```markdown
# Tasks
_No tasks yet. Tell your agent what you need to do._
```

### state/finances.md
```markdown
# Finances
_No data yet. Tell @finance or @cfo about your income and expenses._
```

### state/habits.md
```markdown
# Habits
_No habits tracked yet. Tell @coach or @wellness what you want to build._
```

### state/pipeline.md
```markdown
# Pipeline
_No leads yet. Tell @sales about a prospect._
```

### state/context-bus.md
```markdown
# Context Bus
_No context entries yet._
```

### state/decisions.md
```markdown
# Decisions
_No decisions logged yet._
```

### state/weekly-log.md
```markdown
# Weekly Log
_No reviews yet. Run /review-week on Friday to start._
```

### state/goals.md
```markdown
# Goals
_No goals yet. Tell @coach or @ceo what you want to achieve._
```

### state/daily-log.md
```markdown
# Daily Log
_No entries yet. Run /evening to start logging._
```

### state/projects.md
```markdown
# Projects
_No projects yet. Tell @ceo about a new project._
```

### state/.maintenance-log.md
```markdown
# Maintenance Log
_No maintenance runs yet._
```

---

## Edge cases

- **File already doesn't exist:** Mark as `⏭️ skipped (not found)` — not an error
- **Permission denied:** Report the specific file that failed, suggest `chmod u+w [file]`
- **User confirms deletion:** Only the explicit "Yes, permanently delete everything" selection triggers deletion
- **Interrupted mid-deletion:** On next run, continue from where it left off — already-deleted files will show `skipped`
