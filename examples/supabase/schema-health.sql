-- bOS — Health Pack Schema (Pro Mode)
-- Run AFTER schema-core.sql. Only needed if Health pack is active.
-- Tables for: @trainer, @diet, @wellness

-- ============================================
-- WORKOUTS — Exercise log
-- ============================================
CREATE TABLE IF NOT EXISTS workouts (
    id BIGSERIAL PRIMARY KEY,
    workout_date DATE DEFAULT CURRENT_DATE,
    workout_type VARCHAR(100),  -- strength, cardio, mobility, sport, walk
    duration_min INTEGER,
    exercises TEXT,  -- JSON or free text: "squat 3x8@80kg, bench 3x10@60kg"
    intensity VARCHAR(20),  -- easy, moderate, hard, max
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- MEALS — Nutrition log (optional, for users who want it)
-- ============================================
CREATE TABLE IF NOT EXISTS meals (
    id BIGSERIAL PRIMARY KEY,
    meal_date DATE DEFAULT CURRENT_DATE,
    meal_type VARCHAR(20),  -- breakfast, lunch, dinner, snack
    description VARCHAR(500),
    calories INTEGER,
    protein_g INTEGER,
    water_ml INTEGER,  -- hydration tracking
    is_home_cooked BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- HEALTH INDEXES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_workouts_date ON workouts(workout_date);
CREATE INDEX IF NOT EXISTS idx_meals_date ON meals(meal_date);

-- ============================================
-- HEALTH TRIGGERS
-- ============================================
DO $$
BEGIN
    EXECUTE format('
        DROP TRIGGER IF EXISTS trigger_updated_at ON workouts;
        CREATE TRIGGER trigger_updated_at
            BEFORE UPDATE ON workouts
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at();
    ');
END;
$$;
