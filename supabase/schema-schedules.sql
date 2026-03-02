-- bOS v0.6.0 — Cron Schedules Schema
-- Stores scheduled skill executions

CREATE TABLE IF NOT EXISTS schedules (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    skill TEXT NOT NULL,
    cron_expression TEXT NOT NULL,
    delivery_channel TEXT NOT NULL DEFAULT 'in-app' CHECK (delivery_channel IN ('in-app', 'telegram', 'email', 'slack', 'discord')),
    is_active BOOLEAN DEFAULT true,
    last_run TIMESTAMPTZ,
    next_run TIMESTAMPTZ,
    run_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_schedules_active ON schedules(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_schedules_next_run ON schedules(next_run);

-- RLS
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "schedules_select" ON schedules FOR SELECT USING (true);
CREATE POLICY "schedules_insert" ON schedules FOR INSERT WITH CHECK (true);
CREATE POLICY "schedules_update" ON schedules FOR UPDATE USING (true);
CREATE POLICY "schedules_delete" ON schedules FOR DELETE USING (true);

-- Comments
COMMENT ON TABLE schedules IS 'bOS Cron Schedules — automated skill execution';
COMMENT ON COLUMN schedules.skill IS 'Skill command to execute (e.g., /morning, /evening, /standup)';
COMMENT ON COLUMN schedules.cron_expression IS 'Standard cron expression (minute hour day month weekday)';
COMMENT ON COLUMN schedules.delivery_channel IS 'Where to deliver result: in-app (CLI session), telegram, email, slack, discord';
COMMENT ON COLUMN schedules.next_run IS 'Calculated next execution time (for in-app fallback checking)';
