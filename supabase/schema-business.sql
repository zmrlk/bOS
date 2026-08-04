-- bOS — Business Pack Schema (Pro Mode)
-- Run AFTER schema-core.sql. Only needed if Business pack is active.
-- Tables for: @ceo, @coo, @cto, @cfo, @cmo, @sales

-- ============================================
-- FINANCES — Monthly financial snapshots
-- ============================================
CREATE TABLE IF NOT EXISTS finances (
    id BIGSERIAL PRIMARY KEY,
    month VARCHAR(7) NOT NULL UNIQUE,  -- '2026-03'
    income_main DECIMAL(12,2) DEFAULT 0,
    income_new_business DECIMAL(12,2) DEFAULT 0,
    income_other DECIMAL(12,2) DEFAULT 0,
    expenses_fixed DECIMAL(12,2) DEFAULT 0,
    expenses_variable DECIMAL(12,2) DEFAULT 0,
    saved_to_buffer DECIMAL(12,2) DEFAULT 0,
    saved_to_business DECIMAL(12,2) DEFAULT 0,
    buffer_balance DECIMAL(12,2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- LEADS — Sales pipeline
-- ============================================
CREATE TABLE IF NOT EXISTS leads (
    id BIGSERIAL PRIMARY KEY,
    company VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255),
    industry VARCHAR(100),
    status VARCHAR(50) DEFAULT 'new',  -- new, contacted, talking, proposed, client, cold, lost
    estimated_value DECIMAL(12,2),
    source VARCHAR(100),  -- referral, linkedin, cold_email, inbound
    next_step TEXT,
    next_step_deadline DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- PROJECTS — Active projects
-- ============================================
CREATE TABLE IF NOT EXISTS projects (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    client VARCHAR(255),
    status VARCHAR(50) DEFAULT 'planning',  -- planning, in_progress, delivered, completed
    estimated_hours DECIMAL(6,1),
    actual_hours DECIMAL(6,1) DEFAULT 0,
    price DECIMAL(12,2),
    deadline DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- CONTACTS — CRM
-- ============================================
CREATE TABLE IF NOT EXISTS contacts (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    company VARCHAR(255),
    role VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    linkedin VARCHAR(500),
    relationship VARCHAR(50) DEFAULT 'contact',  -- contact, lead, client, partner, referrer
    last_contact DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- COMMUNICATIONS — Email/call log
-- ============================================
CREATE TABLE IF NOT EXISTS communications (
    id BIGSERIAL PRIMARY KEY,
    contact_id BIGINT REFERENCES contacts(id),
    channel VARCHAR(50),  -- email, call, linkedin, meeting
    direction VARCHAR(10),  -- inbound, outbound
    subject VARCHAR(500),
    summary TEXT,
    outcome VARCHAR(100),
    follow_up_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- SUBSCRIPTIONS — Recurring costs
-- ============================================
CREATE TABLE IF NOT EXISTS subscriptions (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    cost_monthly DECIMAL(8,2),
    currency VARCHAR(3) DEFAULT 'USD',
    category VARCHAR(100),  -- tool, service, hosting, media
    is_needed BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- INVOICES — Invoice tracking
-- ============================================
CREATE TABLE IF NOT EXISTS invoices (
    id BIGSERIAL PRIMARY KEY,
    client VARCHAR(255) NOT NULL,
    project VARCHAR(255),
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(20) DEFAULT 'draft',  -- draft, sent, paid, overdue
    issued_date DATE,
    due_date DATE,
    paid_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- TIME_ENTRIES — Hours logged
-- ============================================
CREATE TABLE IF NOT EXISTS time_entries (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT REFERENCES projects(id),
    entry_date DATE DEFAULT CURRENT_DATE,
    hours DECIMAL(4,1) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- CONTENT_CALENDAR — Content planning
-- ============================================
CREATE TABLE IF NOT EXISTS content_calendar (
    id BIGSERIAL PRIMARY KEY,
    planned_date DATE,
    platform VARCHAR(50),  -- linkedin, twitter, blog, newsletter
    topic VARCHAR(500),
    pillar VARCHAR(50),  -- before_after, how_to, personal, commentary
    status VARCHAR(20) DEFAULT 'idea',  -- idea, drafted, published
    content TEXT,
    engagement_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- BUSINESS INDEXES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_leads_status ON leads(status);
CREATE INDEX IF NOT EXISTS idx_time_entries_date ON time_entries(entry_date);
CREATE INDEX IF NOT EXISTS idx_time_entries_project ON time_entries(project_id);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);
CREATE INDEX IF NOT EXISTS idx_communications_contact ON communications(contact_id);

-- ============================================
-- BUSINESS TRIGGERS
-- ============================================
DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN
        SELECT unnest(ARRAY[
            'finances', 'leads', 'projects', 'contacts',
            'subscriptions', 'invoices', 'content_calendar'
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
