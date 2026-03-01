---
name: Team Standup
description: "Multi-agent standup. Each active agent gives their weekly perspective, then a synthesis. Best used Monday morning."
user_invocable: true
command: /standup
---

# Team Standup

Read `profile.md` → `active_agents`, `active_packs`, `user_type`, `tech_comfort`. Tailor the standup to user's actual agents and situation.

**Adapt to user_type:** Employee → career/work agents speak (skip pipeline/pricing). Freelancer/Business → full business standup. Student → learning-focused. Between things → coach + mentor lead.

## Protocol

### Step 1: Announce

Show token awareness note (this is a multi-agent operation):
```
🤝 TEAM STANDUP — Tydzień [date]

⏳ Zbieram raporty od Twoich agentów...
```

### Step 2: Batch data loading

Load ALL data sources in one batch of tool calls (host runs them concurrently):

**Lite mode (batch Read calls):**
- `state/tasks.md` — task completion this week
- `state/goals.md` — active goals
- `state/daily-log.md` — energy trends (last 7 days)
- `state/habits.md` — streak status
- `state/finances.md` — if Finance/Business packs active
- `state/pipeline.md` — if Business pack active
- `state/projects.md` — if Business pack active
- `state/context-bus.md` — any pending critical signals

**Pro mode (batch Supabase queries):**
Issue all relevant SELECTs in one tool-use turn: tasks, daily_logs, finances, leads, projects, memory signals.

**MCP (batch if available):**
Google Calendar + Gmail + other connectors — issue all in the same turn.

### Step 3: Agent reports (max 5 agents)

### Agent Selection Algorithm (max 5 reporting agents)
1. Read profile.md → active_agents
2. If ≤5 active agents → all report
3. If >5 active agents → select top 5 by priority:
   a. Agents with CRITICAL context-bus entries → always included
   b. Agents matching active pack for this week's goal (from weekly-log.md) → priority
   c. Agents with state file updates since last standup → included
   d. Remaining slots → fill by pack order: Business > Life > Health > Learning
4. @boss always synthesizes (doesn't count toward 5)
5. Show which agents are reporting: "Dziś raportują: @ceo, @coo, @finance, @trainer, @coach"

**Cap at 5 reporting agents** per standup. Others are available on request.

Display in order: Operations → Finance → Growth → Health → Learning → Synthesis. Generate all agent reports in a single response — no round-trips to the user between agents.

Only include agents from `profile.md → active_agents`. Skip agents that aren't active.

**Business pack agents:**

| Agent | Reports on | Data source |
|-------|-----------|-------------|
| @coo | Week plan, capacity, task completion rate | tasks.md, projects.md |
| @cfo | Budget status, buffer, pending invoices | finances.md (business) |
| @cmo | Content plan, engagement last week | pipeline.md, agent memory |
| @sales | Pipeline status, follow-ups overdue | pipeline.md |

**Life pack agents:**

| Agent | Reports on | Data source |
|-------|-----------|-------------|
| @organizer | Routine adherence, upcoming errands | tasks.md (personal), agent memory |
| @finance | Budget this week, impulse check | finances.md (personal) |
| @coach | Goal progress, motivation pulse | goals.md, habits.md |

**Health pack agents:**

| Agent | Reports on | Data source |
|-------|-----------|-------------|
| @trainer | Workouts this week, next session | habits.md |
| @wellness | Energy trend, sleep quality trend | daily-log.md |
| @diet | Nutrition adherence (if tracked) | habits.md, agent memory |

**Learning pack agents:**

| Agent | Reports on | Data source |
|-------|-----------|-------------|
| @teacher | Learning progress, study hours | goals.md, agent memory |
| @reader | Currently reading, reading streak | habits.md, agent memory |
| @mentor | Career direction pulse | goals.md, agent memory |

**Format per agent:** MAX 3 lines, data-driven, no fluff:
```
[emoji] @Agent — [topic]
  → [metric or status]
  → [1 action item for this week]
```

### Step 4: Context-bus digest

If context-bus.md has `Priority: critical` or `Priority: normal` signals pending:
```
📬 Sygnały od zespołu:
  → @source → @target: [summary]
```

### Step 5: Synthesize

The lead agent closes:
- **Business-primary user:** @ceo synthesizes
- **Life-primary user:** @coach synthesizes
- **Mixed:** @boss synthesizes

```
[Lead agent] — SYNTEZA TYGODNIA:
  → PRIORYTET: [1 most important thing this week]
  → CEL: [connection to active goal from goals.md]
  → RYZYKO: [what could derail this]
  → PIERWSZY KROK: [1 action for TODAY]
```

### Step 6: Save

**Lite mode:** Append standup summary to `state/weekly-log.md`:
```
## Standup [DATE]
Priority: [X]
Risk: [Y]
Agents reporting: [list]
```

**Pro mode:** INSERT into weekly_logs table.

## Empty State Handling (Graceful — agents introduce themselves)

If state files are empty or missing, agents give 1-line intros instead of "no data" messages:

- **tasks.md empty:** "@coo: I'm ready to help plan your week. Say /plan-week and I'll build your first plan."
- **finances.md empty:** "@cfo/@finance: I track your money. Tell me your monthly income to start, or log an expense with /expense."
- **goals.md empty:** "@coach: I'm your accountability partner. What's the one thing you want to achieve? I'll help you get there."
- **daily-log.md empty:** "@wellness: I watch your energy and sleep patterns. After a few days of /morning and /evening, I'll start spotting trends."
- **habits.md empty:** "@trainer: I'm here when you're ready to move. Tell me about your fitness, or I'll suggest a starter routine."
- **No agents have data at all:** Each reporting agent gives their 1-line intro (what they do, how to activate them). Then synthesis: "Your team is ready — they just need data. Start with /morning tomorrow and /evening tonight. After 3 days, this standup will be full of real insights."

## User Type Adaptation

- **Employee:** Skip @cmo, @sales, @cfo. Focus on @coo (work tasks), @coach (career goals), @organizer (life).
- **Student:** Skip business agents. Focus on @teacher, @reader, @coach, @organizer.
- **Freelancer/Business owner:** Full business agent roster.
- **Between things:** Focus on @coach, @mentor, @organizer, @finance.

### Step 7: Follow-up

After standup, offer contextual next actions via `AskUserQuestion`:

**header:** "Co dalej?"
**options (pick 2-3 based on standup content):**
- If an agent flagged a risk → "Porozmawiaj z @[agent] o [ryzyku]"
- If no plan exists → "Stwórz plan tygodnia (/plan-week)"
- If pipeline needs attention → "Sprawdź pipeline z @sales"
- Always → "Dzięki, to wszystko"

## Rules
- Only include agents from `active_agents` — NEVER hardcode a list
- **Max 5 agents report** per standup — prioritize by this week's activity/data volume
- Each agent: MAX 3 lines (not essays)
- Synthesis: 1 priority, 1 risk, 1 action
- Total standup should fit on ONE terminal screen
- If no plan exists → "Nie masz planu na ten tydzień. /plan-week?" as the first action
- Adapt language to user's language from profile.md
- Agent format: `[emoji] @Agent — [topic]` (em dash, not colon)
