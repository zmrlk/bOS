-- bOS — Seed Data (Pro Mode)
-- Run this AFTER schema-core.sql and views.sql
-- Seeds the memory table with universal wisdom for all packs

INSERT INTO memory (category, key, value, agent, source, importance) VALUES

-- Business fundamentals
('fact', 'revenue_before_profit', 'Revenue is vanity, profit is sanity, cash is king. Always check effective hourly rate, not just total revenue.', '@cfo', 'seed', 5),
('fact', 'buffer_first', 'Build financial buffer before investing in growth. Buffer = freedom to say no to bad projects.', '@cfo', 'seed', 5),
('fact', 'one_thing_at_a_time', 'Solopreneurs who focus on ONE thing outperform those juggling 3-5 projects. Finish before starting new.', '@ceo', 'seed', 5),

-- Sales wisdom
('fact', 'diagnose_dont_sell', 'The best salespeople ask questions. Never pitch until the client describes the solution themselves.', '@sales', 'seed', 5),
('fact', 'follow_up_wins', '80% of sales require 5+ follow-ups, but 44% of salespeople give up after 1. Follow-up is where deals close.', '@sales', 'seed', 4),
('fact', 'price_scope_not_rate', 'When clients say too expensive, adjust scope — never reduce your rate. Rate anchors your entire business.', '@sales', 'seed', 5),
('fact', 'referrals_best_leads', 'Referred leads convert 3-5x better than cold leads. Ask for referrals after every successful delivery.', '@sales', 'seed', 4),

-- Operations wisdom
('fact', 'energy_not_time', 'Productivity is about energy management, not time management. High-energy hours are 3x more productive.', '@coo', 'seed', 5),
('fact', 'estimate_x2', 'Most people underestimate tasks by 50-100%. Always double your first estimate.', '@coo', 'seed', 4),
('fact', 'done_definition', 'A task without a definition of done is not a task — it is a wish. Always define what finished looks like.', '@coo', 'seed', 4),
('fact', 'weekly_review_compound', 'Weekly reviews compound over time. 15 minutes every Friday creates more progress than 3 hours of random planning.', '@coo', 'seed', 4),

-- Marketing wisdom
('fact', 'client_problem_not_your_solution', 'Marketing should talk about the client problem, not your solution. Nobody cares about your tools — they care about their pain.', '@cmo', 'seed', 5),
('fact', 'consistency_over_virality', 'Consistent posting (2-3x/week for 6 months) beats chasing viral content. Show up regularly.', '@cmo', 'seed', 4),
('fact', 'case_studies_convert', 'Case studies with specific numbers are the #1 converting content type for consultants. Write one after every project.', '@cmo', 'seed', 4),

-- Tech wisdom
('fact', 'ship_over_perfect', '80% shipped beats 100% never finished. Perfectionism is the enemy of the solopreneur.', '@cto', 'seed', 5),
('fact', 'reuse_everything', 'Every project you build is a potential template for the next one. Design with reuse in mind.', '@cto', 'seed', 4),
('fact', 'security_from_day_one', 'Add authentication and access control from day one. Retrofitting security is 10x harder than building it in.', '@cto', 'seed', 4),

-- Psychology
('fact', 'sprinter_crash_pattern', 'Sprint-crash cycles are common in high-energy people. Plan for crash days — do not fight them, prepare for them.', '@coo', 'seed', 4),
('fact', 'impulse_24h_rule', 'The 24-hour rule on purchases above threshold eliminates 60-70% of impulse buys.', '@cfo', 'seed', 3),
('fact', 'sacred_rituals_protect', 'Sacred rituals (exercise, meditation, family time) are recovery mechanisms. Cutting them reduces output, not increases it.', '@coo', 'seed', 4),

-- Life & coaching wisdom
('fact', 'one_thing_today', 'Asking "what is the ONE thing I can do today?" beats any 10-item to-do list. Focus creates momentum.', '@coach', 'seed', 5),
('fact', 'habits_stack', 'Attach new habits to existing ones. "After I [existing habit], I will [new habit]." Stacking beats willpower.', '@coach', 'seed', 4),
('fact', 'progress_not_perfection', 'Track streaks, not perfection. A broken streak is data, not failure. Reset and continue.', '@coach', 'seed', 4),

-- Health wisdom
('fact', 'consistency_over_intensity', 'Three 30-minute workouts per week for a year beats one intense month followed by nothing.', '@trainer', 'seed', 5),
('fact', 'sleep_is_performance', 'Sleep is the #1 performance enhancer. 7-8 hours of quality sleep improves every other metric.', '@wellness', 'seed', 5),
('fact', 'hydration_baseline', 'Most people are chronically dehydrated. Start with 2L/day and adjust. Dehydration kills focus before you notice.', '@diet', 'seed', 4),
('fact', 'recovery_is_training', 'Rest days are not "off days" — they are when your body actually adapts and grows stronger.', '@trainer', 'seed', 4),

-- Learning wisdom
('fact', 'spaced_repetition_works', 'Review at day 1, 3, 7, 14, 30 to move knowledge from short-term to long-term memory.', '@teacher', 'seed', 5),
('fact', 'apply_within_7_days', 'Knowledge not applied within 7 days of learning is lost. Every book or course needs one concrete experiment.', '@reader', 'seed', 4),
('fact', 'teach_to_learn', 'Explaining a concept to someone else is the fastest way to truly understand it. Write it, teach it, discuss it.', '@teacher', 'seed', 4),
('fact', 'pareto_learning', 'In most skills, 20% of the material covers 80% of practical use cases. Find that 20% and master it first.', '@teacher', 'seed', 4);
