# bOS — Supabase Setup Guide (Pro Mode)

> This guide walks you through setting up Supabase for persistent memory and advanced tracking.
> Time: ~15 minutes. You need: a free Supabase account.

---

## Step 1: Create a Supabase Account

1. Go to [supabase.com](https://supabase.com)
2. Sign up with GitHub or email (free tier is sufficient)
3. Create a new organization (your name or project name)

## Step 2: Create a New Project

1. Click "New Project"
2. Choose your organization
3. Name it (e.g., "bos" or your own name)
4. Set a strong database password (save it somewhere safe!)
5. Choose the region closest to you
6. Click "Create new project"
7. Wait 1-2 minutes for provisioning

## Step 3: Run the Core Schema

1. In your Supabase dashboard, go to **SQL Editor** (left sidebar)
2. Click **New Query**
3. Copy the ENTIRE contents of `supabase/schema-core.sql` and paste it
4. Click **Run** (or Ctrl+Enter)
5. You should see "Success. No rows returned" — this is correct

## Step 4: Run Pack Schemas (only the packs you use)

For each active pack, create a **New Query** and run the corresponding schema:

| Pack / Feature | File | Tables added |
|------|------|-------------|
| Business | `schema-business.sql` | finances, leads, projects, contacts, communications, subscriptions, invoices, time_entries, content_calendar |
| Health | `schema-health.sql` | workouts, meals |
| Learning | `schema-learning.sql` | reading_log, study_sessions |
| Life | *(no extra tables — uses core tables)* | — |

### v0.6.0 Feature Schemas (recommended — run all)

| Feature | File | Tables added |
|---------|------|-------------|
| Unified Inbox | `schema-inbox.sql` | messages |
| Cron Schedules | `schema-schedules.sql` | schedules |
| Hybrid Sync | `schema-sync.sql` | sync_log, sync_state |

**Don't know which packs you'll use?** Run all of them. Empty tables cost nothing.

## Step 5: Create Views

1. Still in SQL Editor, create a **New Query**
2. Copy the ENTIRE contents of `supabase/views.sql` and paste it
3. Click **Run**
4. Verify by going to **Database** → **Views** — you should see 4 views

## Step 6: Seed Initial Data

1. New Query in SQL Editor
2. Copy the ENTIRE contents of `supabase/seed-data.sql` and paste it
3. Click **Run**
4. Verify: Go to **Table Editor** → **memory** — you should see seed rows

## Step 7: Get Your Project Credentials

1. Go to **Settings** → **API** (left sidebar)
2. Note these values:
   - **Project URL** (looks like `https://xxxxx.supabase.co`)
   - **Project ID** (the `xxxxx` part)
   - **anon/public key** (starts with `eyJ...`)
3. You'll need the Project ID for connecting with Claude Code

## Step 8: Connect to Claude Code

### Option A: Supabase MCP (Recommended)

If you use Claude Code with MCP (Model Context Protocol):

1. Add Supabase MCP to your Claude Code configuration
2. Use the `execute_sql` tool to query your database
3. Test with: `SELECT COUNT(*) FROM memory;`

### Option B: Manual SQL via Dashboard

If you don't have MCP set up:
1. Use the Supabase SQL Editor directly for queries
2. The AI will suggest SQL queries — run them manually in the dashboard
3. Copy results back to the conversation

## Step 9: Update Your Profile

Open `profile.md` and update:

```
| System mode | pro |
| Supabase project ID | [your project ID] |
```

## Step 10: Verify Everything Works

Run these test queries in SQL Editor:

```sql
-- Check core tables exist
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Check views exist (should return 4)
SELECT COUNT(*) FROM information_schema.views
WHERE table_schema = 'public';

-- Check seed data
SELECT COUNT(*) FROM memory WHERE is_active = true;

-- Test a view
SELECT * FROM v_weekly_completion LIMIT 5;
```

If all queries return expected results, you're ready!

---

## Schema Overview

```
schema-core.sql       → tasks, daily_logs, decisions, weekly_logs, expenses, memory
schema-business.sql   → finances, leads, projects, contacts, communications,
                        subscriptions, invoices, time_entries, content_calendar
schema-health.sql     → workouts, meals
schema-learning.sql   → reading_log, study_sessions
schema-inbox.sql      → messages (v0.6.0)
schema-schedules.sql  → schedules (v0.6.0)
schema-sync.sql       → sync_log, sync_state (v0.6.0)
schema-security.sql   → RLS policies for ALL tables (run last)
views.sql             → v_monthly_summary, v_pipeline_summary,
                        v_weekly_completion, v_project_hours
seed-data.sql         → starter wisdom for all packs
```

---

## Troubleshooting

**"relation already exists"** — Tables were already created. This is fine — the schema uses `IF NOT EXISTS`.

**"permission denied"** — Make sure you're running queries as the project owner, not with the anon key.

**Can't connect from Claude Code** — Check that:
1. Supabase MCP is installed and configured
2. Project ID is correct in the MCP settings
3. Your Supabase project is not paused (free tier pauses after 7 days of inactivity)

**Free tier limitations:**
- 500 MB database storage
- 2 GB bandwidth/month
- Project pauses after 7 days of inactivity (just resume it)
- This is MORE than enough for bOS

---

## What Pro Mode Gives You

| Feature | Lite Mode | Pro Mode |
|---------|-----------|----------|
| Task tracking | Markdown file | Database with queries |
| Financial history | Manual updates | Automatic aggregation + views |
| Pipeline management | Markdown table | Filterable, sortable, queryable |
| Memory across sessions | Agent memory only | Persistent, searchable, shared |
| Energy tracking | Weekly log only | Daily logs with trends |
| Workout tracking | Markdown habits file | Full exercise log with history |
| Reading log | None | Books, ratings, key ideas |
| Unified inbox | Local markdown | Full message history, search, filters |
| Scheduled skills | Local markdown | Persistent cron jobs, run history |
| Hybrid sync | N/A | Offline-first with automatic cloud sync |
| Dashboard views | None | 4 auto-calculated views |
| Data export | Copy-paste | SQL export, CSV, API |
