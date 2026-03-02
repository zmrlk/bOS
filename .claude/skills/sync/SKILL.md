---
name: Hybrid Sync
description: "Synchronize local state files with Supabase cloud. Dual-write protocol with conflict resolution. Works offline-first."
user_invocable: true
command: /sync
---

# /sync — Hybrid Memory Sync

Local files + Cloud database = bulletproof memory. Changes sync automatically, conflicts resolved gracefully.

---

## Usage

- `/sync` or `/sync status` — show sync state per file
- `/sync push` — push local changes to Supabase
- `/sync pull` — pull remote changes to local
- `/sync full` — full bidirectional sync
- `/sync reset [file]` — force re-sync a specific file

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → system_mode, language
- Check Supabase MCP availability (attempt a simple query)

### Step 2: Mode check

- **If Supabase NOT connected:** "Sync requires Supabase. /connect supabase to set it up. Your local files work fine standalone."
- **If Supabase connected:** proceed with sync operations

---

### Subcommand: `/sync status`

Check sync state for all trackable files.

**Trackable files:**

| Local file | Supabase table | Sync direction |
|------------|---------------|----------------|
| state/tasks.md | tasks | bidirectional |
| state/daily-log.md | daily_logs | bidirectional |
| state/finances.md | expenses + finances | bidirectional |
| state/habits.md | (derived from daily_logs) | local → cloud |
| state/goals.md | (stored in memory table) | local → cloud |
| state/decisions.md | decisions | bidirectional |
| state/weekly-log.md | weekly_logs | bidirectional |
| state/pipeline.md | leads | bidirectional |
| state/projects.md | projects | bidirectional |
| state/invoices.md | invoices | bidirectional |
| state/time-log.md | time_entries | bidirectional |
| state/inbox.md | messages | bidirectional |
| state/schedules.md | schedules | bidirectional |

**Display format:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔄  SYNC STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Supabase: ✅ connected
  Last full sync: [date/time]

  ✅ tasks.md ↔ tasks — synced (2 min ago)
  ⬆️ finances.md → expenses — local ahead (3 changes)
  ⬇️ pipeline.md ← leads — remote ahead (1 change)
  ⚠️ decisions.md ↔ decisions — conflict
  ➖ habits.md — local only (no table)

  Total: [X] synced, [Y] pending, [Z] conflicts

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Status icons:**
- ✅ = synced (local and remote match)
- ⬆️ = local ahead (local changes not pushed)
- ⬇️ = remote ahead (remote changes not pulled)
- ⚠️ = conflict (both changed since last sync)
- ➖ = local only (no corresponding table)

**Sync metadata:** Each local file has `<!-- synced: YYYY-MM-DD HH:MM -->` comment.

---

### Subcommand: `/sync push`

Push all local changes to Supabase.

1. For each trackable file where local is newer than last sync:
   a. Parse local file into structured data
   b. Upsert records to Supabase table
   c. Update sync metadata: `<!-- synced: [now] -->`
   d. Log to sync_log table
2. Report: "Pushed [X] files ([Y] records) to Supabase."

**Parsing rules per file:**
- tasks.md → parse markdown tables into task rows
- finances.md → parse expense log into expense rows, budget into finances row
- pipeline.md → parse table into lead rows
- invoices.md → parse table into invoice rows
- etc.

---

### Subcommand: `/sync pull`

Pull remote changes to local files.

1. For each trackable file where remote is newer:
   a. Query Supabase table for records newer than last sync
   b. Convert to markdown format per SCHEMAS.md
   c. Merge into local file (append new, update existing)
   d. Update sync metadata
   e. Log to sync_log table
2. Report: "Pulled [X] files ([Y] records) from Supabase."

---

### Subcommand: `/sync full`

Full bidirectional sync.

1. Compare timestamps for all trackable files
2. For each file:
   - If only local changed → push
   - If only remote changed → pull
   - If both changed → conflict resolution (see below)
3. Update all sync metadata
4. Report full sync summary

---

### Subcommand: `/sync reset [file]`

Force re-sync a specific file.

1. Delete all records from the target Supabase table (for that file's data)
2. Parse entire local file
3. Insert all records to Supabase
4. Update sync metadata
5. Confirm: "[file] fully re-synced to Supabase ([X] records)."

**Warning:** This is destructive for remote data. Confirm before proceeding.

---

## Conflict Resolution

When both local and remote have changed since last sync:

### Time-based resolution:
- **< 5 minutes difference:** Last-write-wins (automatic)
- **>= 5 minutes difference:** Ask user

### User resolution:
```
⚠️ Conflict in [file]:

Local version (modified [time]):
  [preview of local changes]

Remote version (modified [time]):
  [preview of remote changes]
```

AskUserQuestion:
- "Keep local" (description: "Push local version, overwrite remote")
- "Keep remote" (description: "Pull remote version, overwrite local")
- "Merge manually" (description: "I'll review and edit the file myself")

Log resolution to sync_log: `conflict_resolution = [choice]`.

---

## Automatic Sync Triggers

| Trigger | Action | When |
|---------|--------|------|
| Session start | Quick check (compare timestamps only) | Every session |
| Session end | Batch push (all modified files) | Every session with changes |
| /sync (manual) | Full bidirectional sync | On demand |
| Monthly maintenance | Full sync + integrity check | Monthly |

### Session-start sync check (Step 1.1 in boss.md):
1. For each trackable file, compare `<!-- synced: -->` timestamp to Supabase `updated_at`
2. If remote is newer → pull silently
3. If local is newer → mark for session-end push
4. If conflict → add to nudge: "⚠️ Sync conflict in [file]. /sync to resolve."

### Session-end sync push:
1. Collect all modified files during session
2. Push changes to Supabase in one batch
3. Update sync metadata

---

## Dual-Write Protocol (for agents)

When ANY agent writes to a state file:

1. **Always write locally first** — local file is the fast, reliable source
2. **If Supabase connected** → also write to the corresponding table
3. **Update sync metadata** on the local file: `<!-- synced: [now] -->`

This happens automatically for agents using the standard write protocol. No agent needs to know about sync — it's transparent.

**Exception:** If Supabase write fails → local write still succeeds. Mark file as `local-ahead` in sync_state. Push will retry at session-end.

---

## Initial Migration (first-time sync)

When user first connects Supabase and has existing local data:

1. Detect: Supabase tables are empty BUT local files have data
2. Offer: "I have local data that can be synced to the cloud. Push everything?"
3. If yes → full push of all trackable files
4. If no → mark as local-only until user is ready

See `supabase/SETUP-SUPABASE.md` for migration instructions.

---

## State Write Protocol

- **Owner:** @boss (sync operations, sync metadata)
- **Readers:** all agents (can check sync status)
- sync_log and sync_state tables owned by @boss
