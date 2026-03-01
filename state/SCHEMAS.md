# bOS State File Schemas

> Authoritative format definitions for all state/*.md files.
> Skills and agents MUST follow these schemas when reading/writing.

---

## tasks.md

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

### Format:
```
## [YYYY-MM-DD] @source → @target(s)
Type: insight | decision | constraint | data
Priority: critical | normal | info
TTL: [expiry date, default: 14 days]
Content: [the finding]
Status: pending | acknowledged | expired
```

### Rules:
- All agents can append (never edit others' entries)
- @boss sweeps on session start: surface critical+pending, mark expired
- Monthly: archive expired to state/archive/context-bus-YYYY-MM.md
