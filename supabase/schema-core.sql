-- bOS — Core Schema (Pro Mode)
-- These tables are used by ALL packs. Run this FIRST.
-- Documentation: supabase/SETUP-SUPABASE.md

-- ============================================
-- TASKS — Daily/weekly task board
-- Used by: all agents
-- ============================================
CREATE TABLE IF NOT EXISTS tasks (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'todo',  -- todo, in_progress, done, skipped
    energy VARCHAR(1) DEFAULT 'M',  -- H, M, L
    context VARCHAR(50),  -- work, business, personal, health, learning
    plan_date DATE,
    deadline DATE,
    done_definition TEXT,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- DAILY_LOGS — Energy & wellness tracking
-- Used by: @boss, @coach, @wellness, @coo
-- ============================================
CREATE TABLE IF NOT EXISTS daily_logs (
    id BIGSERIAL PRIMARY KEY,
    log_date DATE DEFAULT CURRENT_DATE UNIQUE,
    energy INTEGER CHECK (energy BETWEEN 1 AND 10),
    sleep_quality VARCHAR(20),  -- great, good, ok, poor, terrible
    sleep_hours DECIMAL(3,1),
    mood VARCHAR(20),  -- great, good, neutral, low, bad
    exercise BOOLEAN DEFAULT FALSE,
    sacred_ritual_done BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- DECISIONS — Go/no-go log
-- Used by: @ceo, @boss, @mentor
-- ============================================
CREATE TABLE IF NOT EXISTS decisions (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    decision VARCHAR(50),  -- go, no_go, conditional, change
    reasoning TEXT,
    score INTEGER,  -- /15 for project evaluations
    agent VARCHAR(20),  -- @ceo, @boss, @team, etc.
    related_project VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- WEEKLY_LOGS — Weekly review entries
-- Used by: @coo, @coach, @boss
-- ============================================
CREATE TABLE IF NOT EXISTS weekly_logs (
    id BIGSERIAL PRIMARY KEY,
    week_start DATE NOT NULL UNIQUE,
    week_goal TEXT,
    tasks_planned INTEGER DEFAULT 0,
    tasks_completed INTEGER DEFAULT 0,
    completion_rate DECIMAL(5,2),
    growth_hours DECIMAL(4,1),
    energy_average DECIMAL(3,1),
    wins TEXT,
    blockers TEXT,
    lesson TEXT,
    next_week_focus TEXT,
    buffer_balance DECIMAL(12,2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- EXPENSES — Individual expense tracking
-- Used by: @cfo, @finance
-- ============================================
CREATE TABLE IF NOT EXISTS expenses (
    id BIGSERIAL PRIMARY KEY,
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    category VARCHAR(100),  -- food, transport, tools, entertainment, etc.
    description VARCHAR(500),
    is_impulse BOOLEAN DEFAULT FALSE,
    expense_date DATE DEFAULT CURRENT_DATE,
    month VARCHAR(7),  -- '2026-03'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- MEMORY — Persistent agent learning
-- Used by: all agents
-- ============================================
CREATE TABLE IF NOT EXISTS memory (
    id BIGSERIAL PRIMARY KEY,
    category VARCHAR(50) NOT NULL,  -- fact, preference, lesson, idea, context, decision, note
    key VARCHAR(255) NOT NULL,
    value TEXT NOT NULL,
    agent VARCHAR(20) DEFAULT 'all',  -- @ceo, @coach, @finance, etc. or 'all'
    source VARCHAR(100),  -- interview, conversation, observation, scan
    importance INTEGER DEFAULT 3 CHECK (importance BETWEEN 1 AND 5),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- CORE INDEXES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_tasks_plan_date ON tasks(plan_date);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_expenses_month ON expenses(month);
CREATE INDEX IF NOT EXISTS idx_daily_logs_date ON daily_logs(log_date);
CREATE INDEX IF NOT EXISTS idx_memory_category ON memory(category);
CREATE INDEX IF NOT EXISTS idx_memory_agent ON memory(agent);
CREATE INDEX IF NOT EXISTS idx_memory_active ON memory(is_active);
CREATE INDEX IF NOT EXISTS idx_weekly_logs_week ON weekly_logs(week_start);

-- ============================================
-- AUTO-UPDATE TIMESTAMPS
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN
        SELECT unnest(ARRAY[
            'tasks', 'daily_logs', 'decisions', 'weekly_logs', 'memory'
        ])
    LOOP
        EXECUTE format('
            DROP TRIGGER IF EXISTS trigger_updated_at ON %I;
            CREATE TRIGGER trigger_updated_at
                BEFORE UPDATE ON %I
                FOR EACH ROW
                EXECUTE FUNCTION update_updated_at();
        ', t, t);
    END LOOP;
END;
$$;
