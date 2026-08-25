-- bOS — Dashboard Views (Pro Mode)
-- Run this AFTER schema-core.sql (and any pack schemas you need)

-- ============================================
-- VIEW 1: Monthly Financial Summary
-- Used by @CFO for financial overview
-- ============================================
CREATE OR REPLACE VIEW v_monthly_summary AS
SELECT
    f.month,
    f.income_main + f.income_new_business + f.income_other AS total_income,
    f.expenses_fixed + f.expenses_variable AS total_expenses,
    (f.income_main + f.income_new_business + f.income_other)
        - (f.expenses_fixed + f.expenses_variable) AS surplus,
    f.saved_to_buffer,
    f.saved_to_business,
    f.buffer_balance,
    COALESCE(e.total_expenses_logged, 0) AS expenses_logged,
    COALESCE(e.impulse_total, 0) AS impulse_spending,
    COALESCE(e.expense_categories, '{}') AS expense_breakdown
FROM finances f
LEFT JOIN (
    SELECT
        month,
        SUM(amount) AS total_expenses_logged,
        SUM(CASE WHEN is_impulse THEN amount ELSE 0 END) AS impulse_total,
        jsonb_object_agg(category, cat_total) AS expense_categories
    FROM (
        SELECT month, category, SUM(amount) AS cat_total, bool_or(is_impulse) AS is_impulse, SUM(amount) AS amount
        FROM expenses
        GROUP BY month, category
    ) sub
    GROUP BY month
) e ON f.month = e.month
ORDER BY f.month DESC;

-- ============================================
-- VIEW 2: Pipeline Summary
-- Used by @SALES for pipeline overview
-- ============================================
CREATE OR REPLACE VIEW v_pipeline_summary AS
SELECT
    status,
    COUNT(*) AS lead_count,
    COALESCE(SUM(estimated_value), 0) AS total_value,
    ARRAY_AGG(company ORDER BY updated_at DESC) AS companies
FROM leads
WHERE status NOT IN ('lost')
GROUP BY status
ORDER BY
    CASE status
        WHEN 'client' THEN 1
        WHEN 'proposed' THEN 2
        WHEN 'talking' THEN 3
        WHEN 'contacted' THEN 4
        WHEN 'new' THEN 5
        WHEN 'cold' THEN 6
    END;

-- ============================================
-- VIEW 3: Weekly Completion Rate
-- Used by @COO for accountability tracking
-- ============================================
CREATE OR REPLACE VIEW v_weekly_completion AS
SELECT
    plan_date,
    COUNT(*) AS total_tasks,
    COUNT(*) FILTER (WHERE status = 'done') AS completed,
    COUNT(*) FILTER (WHERE status = 'skipped') AS skipped,
    COUNT(*) FILTER (WHERE status IN ('todo', 'in_progress')) AS remaining,
    ROUND(
        COUNT(*) FILTER (WHERE status = 'done')::DECIMAL
        / NULLIF(COUNT(*), 0) * 100, 1
    ) AS completion_rate
FROM tasks
WHERE plan_date IS NOT NULL
GROUP BY plan_date
ORDER BY plan_date DESC;

-- ============================================
-- VIEW 4: Project Hours & Effective Rate
-- Used by @CTO and @CFO for project profitability
-- ============================================
CREATE OR REPLACE VIEW v_project_hours AS
SELECT
    p.id,
    p.name,
    p.client,
    p.status,
    p.price,
    p.estimated_hours,
    COALESCE(SUM(t.hours), 0) AS actual_hours,
    CASE
        WHEN COALESCE(SUM(t.hours), 0) > 0
        THEN ROUND(p.price / SUM(t.hours), 2)
        ELSE NULL
    END AS effective_rate,
    CASE
        WHEN p.estimated_hours > 0
        THEN ROUND(COALESCE(SUM(t.hours), 0) / p.estimated_hours * 100, 1)
        ELSE NULL
    END AS hours_used_pct
FROM projects p
LEFT JOIN time_entries t ON t.project_id = p.id
GROUP BY p.id, p.name, p.client, p.status, p.price, p.estimated_hours
ORDER BY p.updated_at DESC;
