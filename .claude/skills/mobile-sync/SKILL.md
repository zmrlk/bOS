---
name: mobile-sync
description: Auto-sync between bOS (state files) and Supabase (mobile app). Runs at session start and end. Reads mobile data, writes bOS data. Supabase = single source of truth.
---

# Mobile Sync Protocol

**MANDATORY: Run at every session start and end. No exceptions.**

## Session Start — READ from Supabase

Query these tables for data since last sync:

```sql
-- Energy (last 3 days)
SELECT value, period, logged_at FROM energy_log WHERE logged_at > now() - interval '3 days' ORDER BY logged_at DESC;

-- Tasks (open)
SELECT title, priority, completed_at FROM mobile_tasks WHERE completed_at IS NULL ORDER BY priority;

-- Habits completed today
SELECT h.name, hc.completed_at FROM habit_completions hc JOIN habits h ON h.id = hc.habit_id WHERE hc.completed_at = CURRENT_DATE;

-- Expenses (last 7 days)
SELECT kwota, kategoria, opis, created_at FROM expenses WHERE created_at > now() - interval '7 days' ORDER BY created_at DESC;

-- Water today
SELECT glasses FROM water_log WHERE date = CURRENT_DATE;

-- Sleep today
SELECT hours, quality FROM sleep_log WHERE date = CURRENT_DATE;

-- Notes (last 3 days)
SELECT content, created_at FROM notes WHERE created_at > now() - interval '3 days' ORDER BY created_at DESC;
```

Update state files with this data:
- energy → daily-log.md
- tasks completed → tasks.md
- expenses → finances.md
- habits → daily-log.md

## Session End — WRITE to Supabase

When bOS creates/completes tasks, log energy, or captures data during session:

```sql
-- New tasks
INSERT INTO mobile_tasks (title, priority) VALUES ('...', 1);

-- Energy logged during session
INSERT INTO energy_log (value, period) VALUES (7, 'pm');

-- Expenses logged via /log-expense
INSERT INTO expenses (kwota, kategoria, opis, data_wydatku, zrodlo) VALUES (50, 'jedzenie_miasto', 'opis', CURRENT_DATE, 'bos');
```

## Rules
1. **Supabase = source of truth** for shared data
2. **Never overwrite** — upsert or check before insert
3. **expenses.opis** is NOT NULL — use '-' if empty
4. **expenses.kategoria** is enum: zycie, dojazd, jedzenie_miasto, narzedzia, subskrypcje, isiko_inwestycja, impulse, inne
5. **mobile_tasks** — separate from old `tasks` table (which has PL columns)
6. **Dual-write**: bOS updates both state files AND Supabase
7. Log sync with `<!-- synced: YYYY-MM-DD HH:MM -->` in state files
8. **TASKI vs PRZYPOMNIENIA**: Leki, suplementy, powtarzające się czynności = `reminders` (NIE mobile_tasks). mobile_tasks = jednorazowe zadania (kupić coś, zrobić coś, deadline)
9. **Auto-sync na session start**: Czytaj Supabase ZANIM odpowiesz na cokolwiek. Użytkownik może wrzucić dane z telefonu między sesjami.
10. **Auto-sync na session end**: Zapisuj do Supabase wszystko co się zmieniło w sesji.
