-- bOS — Learning Pack Schema (Pro Mode)
-- Run AFTER schema-core.sql. Only needed if Learning pack is active.
-- Tables for: @teacher, @mentor, @reader

-- ============================================
-- READING_LOG — Books and articles
-- ============================================
CREATE TABLE IF NOT EXISTS reading_log (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    author VARCHAR(255),
    type VARCHAR(50) DEFAULT 'book',  -- book, article, course, podcast
    status VARCHAR(20) DEFAULT 'reading',  -- to_read, reading, finished, abandoned
    started_date DATE,
    finished_date DATE,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    key_ideas TEXT,  -- 3-5 main takeaways
    applied_action TEXT,  -- what the user did with the knowledge
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- STUDY_SESSIONS — Learning time log
-- ============================================
CREATE TABLE IF NOT EXISTS study_sessions (
    id BIGSERIAL PRIMARY KEY,
    session_date DATE DEFAULT CURRENT_DATE,
    subject VARCHAR(255) NOT NULL,  -- "Spanish", "React", "Marketing"
    duration_min INTEGER NOT NULL,
    topic VARCHAR(500),  -- specific topic covered
    method VARCHAR(50),  -- reading, practice, video, flashcards, project
    difficulty VARCHAR(20),  -- easy, moderate, challenging, too_hard
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- LEARNING INDEXES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_reading_log_status ON reading_log(status);
CREATE INDEX IF NOT EXISTS idx_study_sessions_date ON study_sessions(session_date);
CREATE INDEX IF NOT EXISTS idx_study_sessions_subject ON study_sessions(subject);

-- ============================================
-- LEARNING TRIGGERS
-- ============================================
DO $$
BEGIN
    EXECUTE format('
        DROP TRIGGER IF EXISTS trigger_updated_at ON reading_log;
        CREATE TRIGGER trigger_updated_at
            BEFORE UPDATE ON reading_log
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at();
    ');
END;
$$;
