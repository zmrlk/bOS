---
name: Export Data
description: "Export all your bOS data into a single file for backup or portability."
user_invocable: true
command: /export
---

# /export — Data Export

Creates a complete, timestamped snapshot of everything bOS knows about you. Good for backups, migration, or peace of mind.

---

## What gets exported

| Source | Included |
|--------|----------|
| `profile.md` | Full profile |
| `state/tasks.md` | Task history |
| `state/finances.md` | Financial log |
| `state/habits.md` | Habit tracking |
| `state/pipeline.md` | Leads & pipeline |
| `state/decisions.md` | Key decisions |
| `state/weekly-log.md` | Weekly reviews |
| `state/goals.md` | Goals & milestones |
| `state/daily-log.md` | Daily energy & mood log |
| `state/projects.md` | Project tracking |
| `state/context-bus.md` | Agent context signals |
| `.secrets/vault.json` | Service names + masked values (NOT raw keys) |
| Agent memory | Summary of what agents remember about you |

Files that don't exist are skipped silently.

---

## Flow

### Step 1 — Show what will be exported

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📦  EXPORT YOUR DATA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  I'll bundle everything into one file:

  ✅  profile.md              — your profile
  ✅  state/tasks.md          — tasks
  ✅  state/finances.md       — finances
  ✅  state/habits.md         — habits
  ✅  state/pipeline.md       — pipeline
  ✅  state/decisions.md      — decisions
  ✅  state/weekly-log.md     — weekly reviews
  ✅  state/goals.md          — goals
  ✅  state/daily-log.md      — daily logs
  ✅  state/projects.md       — projects
  ✅  state/context-bus.md    — agent context
  ✅  .secrets/ (names only)  — vault inventory
  ✅  Agent memory summary    — what agents know

  ⚠️  Secret VALUES are masked in the export.
  ⚠️  This export contains personal data including
  financial info, health data, and behavioral
  patterns. Store it securely.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion`:
- header: "Export"
- options: "Go ahead — create the export" / "Cancel"

### Step 2 — Build the export

Show live progress:

```
⏳ Building your export...

  📄 Profile .................. ✅
  📋 Tasks .................... ✅
  💰 Finances ................. ✅
  🔄 Habits ................... ✅
  📊 Pipeline ................. ✅
  🧭 Decisions ................ ✅
  📅 Weekly reviews ........... ✅
  🎯 Goals .................... ✅
  📊 Daily log ................ ✅
  📁 Projects ................. ✅
  🔗 Context bus .............. ✅
  🔐 Vault inventory .......... ✅
  🧠 Agent memory ............. ✅

  ✅ Export complete!
```

### Step 3 — Write the file

Output file name: `bos-export-YYYY-MM-DD.md` (using today's date)
Location: project root (same folder as CLAUDE.md)

### Step 4 — Confirm

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✅  Export created
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  📄  bos-export-[DATE].md

  This file contains everything bOS
  knows about you. Store it safely.

  ⚠️  Note: Secret values are masked.
  To restore secrets, use /vault add
  for each service.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Export file format

```markdown
# bOS Data Export
Generated: [ISO timestamp]
bOS version: [from profile.md]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## PROFILE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[full contents of profile.md]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## TASKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[full contents of state/tasks.md]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## FINANCES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[full contents of state/finances.md]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## HABITS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[full contents of state/habits.md]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## PIPELINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[full contents of state/pipeline.md]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## DECISIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[full contents of state/decisions.md]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## WEEKLY REVIEWS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[full contents of state/weekly-log.md]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## GOALS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[full contents of state/goals.md]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## DAILY LOG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[full contents of state/daily-log.md]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## PROJECTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[full contents of state/projects.md]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## CONTEXT BUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[full contents of state/context-bus.md]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## VAULT INVENTORY
(values masked — use /vault add to restore)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Services stored:
- openai (fields: api_key)
- supabase (fields: url, anon_key, service_role_key)
- [other services...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## AGENT MEMORY SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Summary of what agents remember — key facts, preferences, lessons learned]
[List the key memories per agent if accessible, or describe them in plain text]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## END OF EXPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Security notes

- Secret VALUES are always masked in the export (field names included, values replaced with `[masked]`)
- The export file contains personal data (financial info, health data, behavioral patterns) — store it securely and do not share it
- Export files are named `bos-export-*.md` and are excluded from git via `.gitignore`
- To restore secrets after an import, use `/vault add [service]` for each service

---

## Edge cases

- **File missing:** Skip it, note as "not found" in the export under that section
- **State file empty:** Include the section header with "No data yet"
- **Vault missing:** Include "Vault: empty (no secrets stored)"
- **Agent memory inaccessible:** Include "Agent memory: not accessible in this environment"
- **Export file already exists for today:** Append `-2`, `-3` etc. to the filename rather than overwriting
