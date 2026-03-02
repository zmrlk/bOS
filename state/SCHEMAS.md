# bOS State File Schemas

> Authoritative format definitions for all state/*.md files.
> Skills and agents MUST follow these schemas when reading/writing.

## Growing File Structure (Smart Context Loading)

Growing state files (tasks.md, daily-log.md, finances.md, context-bus.md, weekly-log.md) use a 3-zone format:

```markdown
# [TITLE]

## Summary
<!-- AUTO-UPDATED -->
Active section: lines XX-YY
| Metric | Value |
| [key metrics] | [values] |

---

## Active
[current month + previous month data]

---

## Archive
[older data, moved here by maintenance]
```

**Small files** (habits.md, goals.md, decisions.md, projects.md, pipeline.md) do NOT use this format — they are read in full.

**Tier 1 (every session):** Read first 25 lines of growing files (= Summary only). Read small files in full.
**Tier 2 (on demand):** Skills read the Active section when they need details, using `offset` from Summary metadata.

**Migration:** When @boss detects a growing file without `## Summary` header → adds Summary + Active/Archive markers automatically.

---

## tasks.md

### Summary Template (first 25 lines)
```
# Tasks

## Summary
<!-- AUTO-UPDATED by @boss at session end -->
Active section: lines XX-YY
| Metric | Value |
|--------|-------|
| Today [YYYY-MM-DD] | X/Y done (Z%) |
| This week | X/Y done |
| Overdue | X tasks |
| Backlog | Y tasks |
| Avg completion 7d | Z% |

---
```

### Schema

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Date | YYYY-MM-DD | yes | When task was planned |
| Task | text | yes | Task description |
| Status | ☐/✅/⏭️ | yes | ☐ = todo, ✅ = done, ⏭️ = skipped |
| Energy | H/M/L | yes | Required energy: High/Medium/Low |
| Context | text | no | work / personal / health / learning |
| Time est. | Xmin/Xh | no | Estimated time |
| Agent | @name | no | Which agent created/owns this task |

### Format example:
```
## 2026-03-01

| Task | Status | Energy | Context | Time | Agent |
|------|--------|--------|---------|------|-------|
| Wypisz 3 potencjalnych klientów | ☐ | M | work | 30min | @sales |
| Spacer 20 min | ✅ | L | health | 20min | @trainer |
```

### Rules:
- One section per date (## YYYY-MM-DD)
- Tasks within date section as markdown table
- Carry-over: Copy ☐ tasks from yesterday to today's section
- Archive: Sections older than 2 months → state/archive/tasks-YYYY-MM.md

---

## daily-log.md

### Summary Template (first 25 lines)
```
# Daily Log

## Summary
<!-- AUTO-UPDATED by @boss at session end -->
Active section: lines XX-YY
| Metric | Value |
|--------|-------|
| Last entry | YYYY-MM-DD |
| Energy 7d avg | X.X |
| Energy trend | ↑/↓/→ |
| Sleep last 7d | X good, Y ok, Z bad |
| Exercise last 7d | X/7 days |
| Low battery days 14d | X |

---
```

### Schema

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Date | YYYY-MM-DD | yes | Log date |
| Energy AM | 1-10 | yes | Morning energy (from /morning) |
| Energy PM | 1-10 | no | Evening energy (from /evening) |
| Sleep | text | no | Sleep quality (good/ok/bad + hours) |
| Mood | text | no | Mood summary |
| Exercise | yes/no | no | Did user exercise? |
| Win | text | no | Day's biggest win |
| Notes | text | no | Free-form notes |

### Format example:
```
| Date | Energy AM | Energy PM | Sleep | Mood | Exercise | Win | Notes |
|------|-----------|-----------|-------|------|----------|-----|-------|
| 2026-03-01 | 7 | 5 | good, 7h | focused | yes | Closed deal | — |
| 2026-02-28 | 3 | 4 | bad, 5h | tired | no | Survived | Low Battery Day |
```

### Rules:
- Single table, newest entry on top
- /morning creates row with Energy AM only
- /evening UPDATES same row (adds Energy PM, Sleep, Mood, Win)
- If /evening runs without /morning entry → create full row
- Archive: Rows older than 2 months → state/archive/daily-log-YYYY-MM.md

---

## habits.md

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Habit | text | yes | Habit name |
| Owner | @agent | yes | Which agent tracks this |
| Streak | number | yes | Current consecutive days |
| Last done | YYYY-MM-DD | yes | Last completion date |
| Target | text | no | Frequency goal (daily/3x week/etc.) |

### Format example:
```
| Habit | Owner | Streak | Last done | Target |
|-------|-------|--------|-----------|--------|
| Morning workout | @trainer | 5 | 2026-03-01 | daily |
| Read 20 pages | @reader | 12 | 2026-03-01 | daily |
| Log expenses | @finance | 3 | 2026-02-28 | daily |
| Meal prep | @diet | 2 | 2026-02-27 | 2x week |
```

### Rules:
- Single table, sorted by streak (longest first)
- Streak resets to 0 if Last done > target interval
- @wellness is coordinator (primary writer), others POST updates via context-bus
- Archive: Keep active habits only. Abandoned habits (streak=0 for 30+ days) → archive note

---

## weekly-log.md

### Summary Template (first 25 lines)
```
# Weekly Log

## Summary
<!-- AUTO-UPDATED by @boss at session end -->
Active section: lines XX-YY
| Metric | Value |
|--------|-------|
| Last review | YYYY-MM-DD |
| Last completion rate | X% |
| 4-week avg | X% |
| Current week goal | [goal text] |

---
```

### Schema

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Week | YYYY-MM-DD | yes | Monday of the week |
| Week goal | text | yes | Primary focus for the week |
| Planned | number | yes | Tasks planned |
| Done | number | yes | Tasks completed |
| Rate | % | yes | Completion rate |
| Energy avg | number | no | Average energy for the week |
| Wins | text | no | Key wins |
| Lessons | text | no | What was learned |
| Next week | text | no | Carry-forward priorities |

### Format example:
```
## Week of 2026-02-24

| Field | Value |
|-------|-------|
| Week goal | Launch product landing page |
| Planned | 12 |
| Done | 9 |
| Rate | 75% |
| Energy avg | 6.2 |
| Wins | Finished landing page design, got first lead |
| Lessons | Sprints work better than marathons |
| Next week | Follow up leads, start content calendar |
```

### Rules:
- One section per week (## Week of YYYY-MM-DD)
- /plan-week creates the section with week_goal and planned tasks
- /review-week fills in done, rate, wins, lessons, next week
- /standup can append notes mid-week
- Archive: Weeks older than 2 months → state/archive/weekly-log-YYYY-MM.md

---

## pipeline.md (Business pack only)

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Company/Client | text | yes | Lead name |
| Status | text | yes | cold / warm / hot / proposal / won / lost |
| Value | currency | no | Estimated deal value |
| Next step | text | yes | What to do next |
| Deadline | YYYY-MM-DD | no | Next step deadline |
| Last contact | YYYY-MM-DD | yes | Last interaction date |
| Notes | text | no | Context |

### Format example:
```
| Client | Status | Value | Next step | Deadline | Last contact | Notes |
|--------|--------|-------|-----------|----------|--------------|-------|
| Acme Corp | proposal | $5,000 | Send revised quote | 2026-03-05 | 2026-03-01 | Need CTO approval |
| StartupXYZ | warm | — | Schedule discovery call | 2026-03-03 | 2026-02-25 | Met at conference |
```

### Rules:
- Single table sorted by status priority (hot > warm > cold)
- @sales is primary writer
- Follow-up framework: Day 0 (initial), Day 3 (follow up), Day 7, Day 14
- Archive: Won/lost entries older than 1 month → state/archive/pipeline-YYYY-MM.md

---

## finances.md

### Summary Template (first 25 lines)
```
# Finances

## Summary
<!-- AUTO-UPDATED: buffer ALWAYS immediate, rest at session end -->
Active section: lines XX-YY
| Metric | Value |
|--------|-------|
| Buffer | XX% (X PLN / Y PLN target) |
| This month spent | X PLN |
| Budget remaining | X PLN |
| Top category | [category] |
| Impulse ratio | X% (X/Y expenses) |
| Last expense | YYYY-MM-DD, X PLN, [category] |

---
```

### Format:
```
## Budget — [Month YYYY]

| Category | Budgeted | Spent | Remaining |
|----------|----------|-------|-----------|
| Housing | 3,000 | 3,000 | 0 |
| Food | 1,500 | 800 | 700 |
| Transport | 500 | 200 | 300 |
| Subscriptions | 300 | 300 | 0 |
| Discretionary | 1,000 | 450 | 550 |

## Buffer

| Field | Value |
|-------|-------|
| Target | 3 months (X PLN) |
| Current | X PLN |
| Progress | XX% |
| Monthly savings | X PLN |

## Expense Log

| Date | Amount | Category | Description | Impulse? |
|------|--------|----------|-------------|----------|
| 2026-03-01 | 150 PLN | Food | Grocery shopping | no |
```

### Rules:
- One Budget section per month
- Buffer updated monthly by @finance
- Expense Log is append-only, newest on top
- @cfo owns business section (if separate), @finance owns personal
- Archive: Completed months → state/archive/finances-YYYY-MM.md

---

## goals.md

### Format:
```
## Active Goals

| Goal | Owner | Started | Target date | Progress | Status |
|------|-------|---------|-------------|----------|--------|
| Build 3-month buffer | @finance | 2026-01-15 | 2026-06-15 | 40% | on track |
| Run 5K | @trainer | 2026-02-01 | 2026-05-01 | 20% | on track |
| Learn Python basics | @teacher | 2026-03-01 | 2026-04-15 | 0% | new |

## Completed Goals

| Goal | Owner | Completed | Duration |
|------|-------|-----------|----------|
```

### Rules:
- @coach is coordinator (primary writer)
- Other agents POST goal updates to context-bus → @coach writes
- Progress updated weekly (during /review-week or /plan-week)
- Goals with no progress for 3+ months → flag for review
- Completed goals move to Completed section

---

## decisions.md

### Format:
```
## [YYYY-MM-DD] — [Decision title]

**Decision:** [What was decided]
**Options considered:** [List of alternatives]
**Reasoning:** [Why this option]
**Owner:** @[agent who made the recommendation]
**Status:** active / reversed / superseded
**Review date:** [When to revisit, if applicable]
```

### Rules:
- @ceo is primary writer
- Newest decision on top
- Major decisions also saved to agent memory (summary)
- Never delete decisions — mark as reversed/superseded with reason

---

## projects.md (Business pack only)

### Format:
```
| Project | Client | Status | Hours est. | Hours actual | Deadline | Rate | Agent |
|---------|--------|--------|------------|--------------|----------|------|-------|
| Website redesign | Acme | active | 40h | 12h | 2026-04-01 | $100/h | @cto |
```

### Rules:
- @ceo, @coo, @cto are writers
- Hours updated weekly
- Completed projects move to archive

---

## context-bus.md

### Summary Template (first 25 lines)
```
# Context Bus

## Summary
<!-- AUTO-UPDATED by @boss at session end -->
| Metric | Value |
|--------|-------|
| Pending critical | X |
| Pending normal | X |
| Pending info | X |
| Oldest pending | YYYY-MM-DD |

---
```

### Format:
```
## [YYYY-MM-DD] @source → @target(s)
Type: insight | decision | constraint | data | calibration
Priority: critical | normal | info
TTL: [expiry date, default: 14 days]
Content: [the finding]
Status: pending | acknowledged | acted-on | expired
```

### Signal types:
- `insight` — observation, pattern, correlation
- `decision` — decision made that affects other agents
- `constraint` — hard limit discovered (budget, time, health)
- `data` — raw data update (task done, expense logged, streak milestone)
- `calibration` — updated understanding of the user that other agents should know about

### Status lifecycle:
- `pending` → signal posted, not yet seen by target agent
- `acknowledged` → target agent has seen the signal
- `acted-on` → target agent has incorporated the signal into their behavior/response
- `expired` → past TTL, awaiting archival

### Rules:
- All agents can append (never edit others' entries)
- @boss sweeps on session start: surface critical+pending, mark expired
- @boss processes `calibration` signals: updates profile.md or reposts as targeted signals
- After acting on a signal, update Status to `acted-on`
- Monthly: archive expired and acted-on entries to state/archive/context-bus-YYYY-MM.md
