-- bOS — Security Schema (RLS + Policies)
-- Run AFTER all other schema files.
-- Enables Row Level Security on every table and restricts all access
-- to the authenticated user only.
--
-- Execution order:
--   1. schema-core.sql
--   2. schema-business.sql    (if Business pack active)
--   3. schema-health.sql      (if Health pack active)
--   4. schema-learning.sql    (if Learning pack active)
--   5. schema-security.sql    ← this file (always last)

-- ============================================
-- HELPER: enable RLS + create authenticated-user policies
-- ============================================

-- This function enables RLS on a table and creates four policies:
--   SELECT  — authenticated users can read their own data
--   INSERT  — authenticated users can insert their own data
--   UPDATE  — authenticated users can update their own data
--   DELETE  — authenticated users can delete their own data
--
-- All policies use auth.uid() IS NOT NULL — meaning: "you must be
-- logged in." Since bOS is a single-user system, every authenticated
-- user owns all rows. If you ever go multi-tenant, add a user_id
-- column and filter by auth.uid() = user_id instead.

CREATE OR REPLACE FUNCTION _bos_enable_rls_for_table(tbl TEXT)
RETURNS VOID AS $$
BEGIN
    -- Enable RLS
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', tbl);

    -- Force RLS even for table owners (prevents accidental bypass)
    EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', tbl);

    -- SELECT policy
    EXECUTE format('
        DROP POLICY IF EXISTS "Authenticated users can read %1$s" ON %1$I;
        CREATE POLICY "Authenticated users can read %1$s"
            ON %1$I
            FOR SELECT
            TO authenticated
            USING (auth.uid() IS NOT NULL);
    ', tbl);

    -- INSERT policy
    EXECUTE format('
        DROP POLICY IF EXISTS "Authenticated users can insert %1$s" ON %1$I;
        CREATE POLICY "Authenticated users can insert %1$s"
            ON %1$I
            FOR INSERT
            TO authenticated
            WITH CHECK (auth.uid() IS NOT NULL);
    ', tbl);

    -- UPDATE policy
    EXECUTE format('
        DROP POLICY IF EXISTS "Authenticated users can update %1$s" ON %1$I;
        CREATE POLICY "Authenticated users can update %1$s"
            ON %1$I
            FOR UPDATE
            TO authenticated
            USING (auth.uid() IS NOT NULL)
            WITH CHECK (auth.uid() IS NOT NULL);
    ', tbl);

    -- DELETE policy
    EXECUTE format('
        DROP POLICY IF EXISTS "Authenticated users can delete %1$s" ON %1$I;
        CREATE POLICY "Authenticated users can delete %1$s"
            ON %1$I
            FOR DELETE
            TO authenticated
            USING (auth.uid() IS NOT NULL);
    ', tbl);

    RAISE NOTICE 'RLS enabled on table: %', tbl;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- CORE TABLES (schema-core.sql)
-- ============================================

DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOR tbl IN
        SELECT unnest(ARRAY[
            'tasks',
            'daily_logs',
            'decisions',
            'weekly_logs',
            'expenses',
            'memory'
        ])
    LOOP
        PERFORM _bos_enable_rls_for_table(tbl);
    END LOOP;
END;
$$;

-- ============================================
-- BUSINESS PACK TABLES (schema-business.sql)
-- ============================================
-- Guarded with IF EXISTS to avoid errors when
-- the Business pack has not been installed.

DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOR tbl IN
        SELECT unnest(ARRAY[
            'finances',
            'leads',
            'projects',
            'contacts',
            'communications',
            'subscriptions',
            'invoices',
            'time_entries',
            'content_calendar'
        ])
    LOOP
        -- Skip tables that don't exist (pack not installed)
        IF EXISTS (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'public'
              AND table_name = tbl
        ) THEN
            PERFORM _bos_enable_rls_for_table(tbl);
        ELSE
            RAISE NOTICE 'Skipping % — table not found (Business pack not installed)', tbl;
        END IF;
    END LOOP;
END;
$$;

-- ============================================
-- HEALTH PACK TABLES (schema-health.sql)
-- ============================================

DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOR tbl IN
        SELECT unnest(ARRAY[
            'workouts',
            'meals'
        ])
    LOOP
        IF EXISTS (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'public'
              AND table_name = tbl
        ) THEN
            PERFORM _bos_enable_rls_for_table(tbl);
        ELSE
            RAISE NOTICE 'Skipping % — table not found (Health pack not installed)', tbl;
        END IF;
    END LOOP;
END;
$$;

-- ============================================
-- LEARNING PACK TABLES (schema-learning.sql)
-- ============================================

DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOR tbl IN
        SELECT unnest(ARRAY[
            'reading_log',
            'study_sessions'
        ])
    LOOP
        IF EXISTS (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'public'
              AND table_name = tbl
        ) THEN
            PERFORM _bos_enable_rls_for_table(tbl);
        ELSE
            RAISE NOTICE 'Skipping % — table not found (Learning pack not installed)', tbl;
        END IF;
    END LOOP;
END;
$$;

-- ============================================
-- ANON ROLE — block all anonymous access
-- ============================================
-- Belt-and-suspenders: even if a policy bug slips through,
-- the anon role has no privileges on any bOS table.

DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOR tbl IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name IN (
            -- core
            'tasks', 'daily_logs', 'decisions', 'weekly_logs', 'expenses', 'memory',
            -- business
            'finances', 'leads', 'projects', 'contacts', 'communications',
            'subscriptions', 'invoices', 'time_entries', 'content_calendar',
            -- health
            'workouts', 'meals',
            -- learning
            'reading_log', 'study_sessions'
          )
    LOOP
        EXECUTE format('REVOKE ALL ON %I FROM anon', tbl);
        RAISE NOTICE 'Revoked anon access on: %', tbl;
    END LOOP;
END;
$$;

-- ============================================
-- VERIFY: show RLS status for all bOS tables
-- ============================================
-- Run this query manually to confirm everything is locked down:
--
-- SELECT
--     schemaname,
--     tablename,
--     rowsecurity AS rls_enabled,
--     CASE rowsecurity WHEN true THEN '✅' ELSE '❌' END AS status
-- FROM pg_tables
-- WHERE schemaname = 'public'
--   AND tablename IN (
--     'tasks', 'daily_logs', 'decisions', 'weekly_logs', 'expenses', 'memory',
--     'finances', 'leads', 'projects', 'contacts', 'communications',
--     'subscriptions', 'invoices', 'time_entries', 'content_calendar',
--     'workouts', 'meals', 'reading_log', 'study_sessions'
--   )
-- ORDER BY tablename;

-- ============================================
-- CLEANUP: drop helper function (optional)
-- ============================================
-- The helper function is no longer needed after setup.
-- Uncomment to remove it:
--
-- DROP FUNCTION IF EXISTS _bos_enable_rls_for_table(TEXT);
